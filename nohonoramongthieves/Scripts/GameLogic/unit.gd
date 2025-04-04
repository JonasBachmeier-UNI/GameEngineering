class_name Unit
extends Path2D

const ID_CONVERT_MULT = 100
const ENEMY_POSITION_VALUE = 500

@onready var tml = $"../../Map"
@onready var overlay = $"../../UnitOverlay"
@onready var gameboard = $"../../../GameBoard"
@onready var path_follow = $"PathFollow2D"


## wenn true dann wird dem Pfad gefolgt
var is_moving = false


## Teamzuweisung
@export var is_enemy: bool
## Geschwindigkeit auf Pfad
@export var speed := 100.0

@export var unit_name: String

@export var x_coord: int
@export var y_coord: int

## TODO: wenn man gegangen ist kann man nix mehr machen
var has_moved = false

var grid
## TODO: Grid wird nach jedem Zug auf dieser Basis generiert (Signal)
# update_board() nach jedem Zug aufrufen
var base_grid
var astar = AStar2D.new()

## Alle Child-Nodes von Unit
var units

## Gameplay 
@export var max_hp:= 10
var hp
@export var dmg := 3
var dmg_bonus = 0
@export var defense := 1
# Reichweite der Einheit
@export var move_range := 2
var moved_count = 0

# Tiles, die erreicht werden können
# Startfeld drin?
var in_move_range = []
# Tiles, die angegriffen werden können
var in_attack_range = []

func _ready() -> void:
	hp = max_hp
	path_follow.loop = false
	update_units()
	pass


## Alle "Sibling Nodes"
func update_units():
	units = get_parent().get_children().filter(func(node): return node != self)
	

## Setzt die Einheit auf die Map
func current_pos_to_tml():
	var gb_pos = Vector2i(x_coord, y_coord)
	var tml_pos = gameboard.grid_to_tml_coords(gb_pos)
	global_position = tml.map_to_local(tml_pos)


## TODO: aufrufen wenn hp < 0
## Löscht komplette Node bei besiegen der Node
func on_death():
	queue_free()


func on_game_board_matrix_ready(value: Variant) -> void:
	base_grid = value.duplicate(true)
	grid = value
	current_pos_to_tml()
	## TODO:
	# Koordinaten der Gegner mit ENEMY_POSITION_VALUE belegen
	# Verbündete auf 999
	update_board()
	get_cells_in_range()
	astar = create_astar_for_grid()
	

## Setzt Gegner und Verbündete auf das Grid
func update_board():
	grid = base_grid.duplicate(true)
	var enemy_positions = []
	var ally_positions = []
	
	for unit in units:
		var x_test = unit.x_coord
		var y_test = unit.y_coord
		var test_position = Vector2i(x_test, y_test)
		if unit.is_enemy != self.is_enemy:
			enemy_positions.append(test_position)
		else:
			ally_positions.append(test_position)
	for enemy_position in enemy_positions:
		set_grid_value(enemy_position[0], enemy_position[1], ENEMY_POSITION_VALUE)
		
	for ally_position in ally_positions:
		set_grid_value(ally_position[0], ally_position[1], 999)
		
	astar = create_astar_for_grid()



func get_cells_in_range():
	
	update_units()
	update_board()
	
	in_move_range = []
	in_attack_range = []
	
	# überprüfen, wie weit man gehen kann
	var move_count = 0
	var x_test = x_coord
	var y_test = y_coord
	var check_next = [[Vector2i(x_test, y_test)]]
	
	in_move_range.append(Vector2i(x_test, y_test))
	# schon geprüfte Felder
	var checked = []
	while move_count <= move_range - moved_count:
		
		# Alle im nächsten Zug erreichbare Felder
		var next_batch = []
		
		for element in check_next[move_count]:

			var x_check = element[0]
			var y_check = element[1]
			
			checked.append(Vector2i(x_check, y_check))
		
			var temp = get_possible_moves(x_check, y_check, move_count)
			var reachable_temp = temp[0]
			var attackable_temp = temp[1]
		
			for c in reachable_temp:
				if !checked.has(c):
					in_move_range.append(c)
					next_batch.append(c)
		
			for c in attackable_temp:
				if !checked.has(c) and !in_move_range.has(c) and !in_attack_range.has(c):
					in_attack_range.append(c)
		
		
		check_next.append(next_batch)
		move_count += 1


func get_possible_moves(x, y, move_count):
	
	var reachable_neighbours = []
	var attackable_neighbours = []
	
	if move_count > move_range - moved_count:
		return [reachable_neighbours, attackable_neighbours]


	var max_y = len(grid)
	var max_x = len(grid[0])

	## Ein Feld unter dem untersuchten existiert
	if y > 0:
		## Das untere Feld ist erreichbar
		var grid_value = get_grid_value(x, y-1)
		if (grid_value + move_count) <= move_range - moved_count:
			reachable_neighbours.append(Vector2i(x, y-1))
		## Das untere Feld ist nicht erreichbar, aber keine Wand
		# Enemy = 500, Wand = 999, Loch = 1000
		elif grid_value < 999:
			attackable_neighbours.append(Vector2i(x, y-1))
		
	## Ein Feld über dem untersuchten existiert
	if y < max_y-1:
		## Das obere Feld ist erreichbar
		var grid_value = get_grid_value(x, y+1)
		if (grid_value + move_count) <= move_range - moved_count:
			reachable_neighbours.append(Vector2i(x, y+1))
		## Das obere Feld ist nicht erreichbar, aber keine Wand
		# Enemy = 500, Wand = 999, Loch = 1000
		elif grid_value < 999:
			attackable_neighbours.append(Vector2i(x, y+1))
	
	## Ein Feld links neben dem untersuchten existiert
	if x > 0:
		var grid_value = get_grid_value(x-1, y)
		## Das linke Feld ist erreichbar
		if (grid_value + move_count) <= move_range - moved_count:
			reachable_neighbours.append(Vector2i(x-1, y))
		## Das linke Feld ist nicht erreichbar, aber keine Wand
		# Enemy = 500, Wand = 999, Loch = 1000
		elif grid_value < 999:
			attackable_neighbours.append(Vector2i(x-1, y))
	
	## Ein Feld links neben dem untersuchten existiert
	if x < max_x - 1:
		## Das rechte Feld ist erreichbar
		var grid_value = get_grid_value(x+1, y)
		if (grid_value + move_count) <= move_range - moved_count:
			reachable_neighbours.append(Vector2i(x+1, y))
		## Das rechte Feld ist nicht erreichbar, aber keine Wand
		# Enemy = 500, Wand = 999, Loch = 1000
		elif grid_value < 999:
			attackable_neighbours.append(Vector2i(x+1, y))

	return [reachable_neighbours, attackable_neighbours]
	

func get_path_to_destination(end_x: int, end_y: int):
	
	var destination = Vector2i(end_x, end_y)
	get_cells_in_range()
	# nicht erreichbar
	if !in_attack_range.has(destination) and !in_move_range.has(destination):
		return []
	
	# Wenn nur durch Attacke erreichbar und keine Gegner auf Feld
	if in_attack_range.has(destination) and get_grid_value(end_x, end_y) != ENEMY_POSITION_VALUE:
		return []
		
	# in movement range oder Gegner angreifbar
	var id_start = coordinate_to_id(x_coord, y_coord)
	var id_end = coordinate_to_id(end_x, end_y)
	var coord_path = astar.get_point_path(id_start, id_end)
	
	# Gegner auf dem Endfeld --> Pfad wird um 1 gekürzt
	if in_attack_range.has(destination):
		coord_path = coord_path.slice(0, len(coord_path)-1)
	
	return coord_path



func get_grid_value(x, y):
	if y > len(grid) or y < 0 or x > len(grid[0]) or x < 0:
		return
	return grid[y][x]
	
func set_grid_value(x, y, value):
	if y > len(grid) or y < 0 or x > len(grid[0]) or x < 0:
		return
	grid[y][x] = value

	
func print_grid():
	for x in grid:
		print(x)


func create_astar_for_grid():
	
	## Hier Gegner und Verbündetenposition ins Grid eintragen
	
	var y_max = len(grid)
	var x_max = len(grid[0])
	
	## Punkte werden mit Gewichtung auf a* gelegt
	for y in range(y_max):
		for x in range(x_max):
			var id = coordinate_to_id(x, y)
			astar.add_point(id, Vector2(x, y), get_grid_value(x, y))
	
	## Verbindungen zwischen Punkten werden gemacht
	for y in range(y_max):
		for x in range(x_max):
			var id = coordinate_to_id(x, y)
			
			if y > 0:
				var id_n = coordinate_to_id(x, y-1)
				astar.connect_points(id, id_n)
				
			if y < y_max-1:
				var id_n = coordinate_to_id(x, y+1)
				astar.connect_points(id, id_n)
				
			if x > 0:
				var id_n = coordinate_to_id(x-1, y)
				astar.connect_points(id, id_n)

			if x < x_max-1:
				var id_n = coordinate_to_id(x+1, y)
				astar.connect_points(id, id_n)
				
	return astar



func get_global_positions_from_path(path):
	var gbs = []
	for point in path:
		var tml_pos = gameboard.grid_to_tml_coords(point)
		gbs.append(tml.map_to_local(tml_pos) - global_position)
	return gbs


func set_path(points):
	curve.clear_points()
	for point in points:
		curve.add_point(point)



func update_position(new_x, new_y):
	x_coord = new_x
	y_coord = new_y


func get_shortest_path_to_enemy():
	update_units()
	update_board()
	var shortest_path = []
	var target_unit = null
	var id = coordinate_to_id(x_coord, y_coord)
	for unit in units:
		## AKTUELLER BUG: Einheit ohne HP wird noch angezeigt, aber in KI deswegen nicht mehr verfolgt
		if unit.is_enemy != is_enemy and unit.hp > 0:
			var enemy_id = coordinate_to_id(unit.x_coord, unit.y_coord)
			var path_to_unit = astar.get_point_path(id, enemy_id)
			if shortest_path.is_empty()  or len(shortest_path) > len(path_to_unit):
				target_unit = unit
				shortest_path = path_to_unit
	
	if len(shortest_path) < 2:
		return [shortest_path, target_unit]
	var last_field_x = shortest_path[-1][0]
	var last_field_y = shortest_path[-1][1]
	var field_unreachable = get_grid_value(last_field_x, last_field_y) >= ENEMY_POSITION_VALUE
	while field_unreachable:
		if len(shortest_path) <= 1:
			return [shortest_path, target_unit]
		shortest_path = shortest_path.slice(0, len(shortest_path)-1)
		last_field_x = shortest_path[-1][0]
		last_field_y = shortest_path[-1][1]
		field_unreachable = get_grid_value(last_field_x, last_field_y) >= ENEMY_POSITION_VALUE
	
	return [shortest_path, target_unit]

func get_moves_left():
	return move_range - moved_count


func wait_for_next_turn():
	has_moved = true


func is_next_to_enemy():
	if get_grid_value(x_coord + 1, y_coord) == ENEMY_POSITION_VALUE:
		return true
	if get_grid_value(x_coord - 1, y_coord) == ENEMY_POSITION_VALUE:
		return true
	if get_grid_value(x_coord, y_coord + 1) == ENEMY_POSITION_VALUE:
		return true
	if get_grid_value(x_coord, y_coord - 1) == ENEMY_POSITION_VALUE:
		return true
	return false

func is_next_to_unit(unit):
	if unit.x_coord == x_coord and unit.y_coord == y_coord + 1:
		return true
	if unit.x_coord == x_coord and unit.y_coord == y_coord - 1:
		return true
	if unit.x_coord == x_coord + 1 and unit.y_coord == y_coord:
		return true
	if unit.x_coord == x_coord - 1 and unit.y_coord == y_coord:
		return true
	return false


func heal_self(healed_hp):
	hp += healed_hp
	if hp > max_hp:
		hp = max_hp

func gain_damage_for_next_turn(bonus):
	dmg_bonus = bonus

func show_range():
	get_cells_in_range()
	for point in in_attack_range:
		var tile = gameboard.grid_to_tml_coords(Vector2i(point[0], point[1]))
		overlay.set_cell(tile, 1, Vector2i(0, 0))
		
	for point in in_move_range:
		var tile = gameboard.grid_to_tml_coords(Vector2i(point[0], point[1]))
		overlay.set_cell(tile, 0, Vector2i(0, 0))

func clear_overlay():
	overlay.clear()


func coordinate_to_id(x, y):
	return x*ID_CONVERT_MULT + y
	
func id_to_coordinate(coord):
	
	var y = coord % ID_CONVERT_MULT
	var x = (coord - y) / ID_CONVERT_MULT
	return [x, y]
