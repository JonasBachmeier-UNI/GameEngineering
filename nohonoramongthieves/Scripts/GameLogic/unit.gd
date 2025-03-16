extends Path2D

const ID_CONVERT_MULT = 100
const ENEMY_POSITION_VALUE = 500

## TODO: wenn man gegangen ist kann man nix mehr machen

## Teamzuweisung
@export var isEnemy: bool
## Geschwindigkeit auf Pfad
@export var speed := 300.0

@export var x_coord: int
@export var y_coord: int

var grid
var astar = AStar2D.new()

## Gameplay 
@export var hp:= 10
@export var dmg := 3
@export var defense := 1
# Reichweite der Einheit
@export var move_range := 2

# Tiles, die erreicht werden können
# Startfeld drin?
var in_move_range = []
# Tiles, die angegriffen werden können
var in_attack_range = []

func _ready() -> void:
	pass
	


func _on_game_board_matrix_ready(value: Variant) -> void:
	grid = value
	## TODO:
	# Koordinaten der Gegner mit ENEMY_POSITION_VALUE belegen
	# Verbündete auf 999
	print_grid()
	astar = create_astar_for_grid()
	print(astar.get_point_path(101, 505))
	

func get_cells_in_range(cur_x, cur_y):
	
	# überprüfen, wie weit man gehen kann
	var move_count = 0
	var check_next = [[[cur_x, cur_y]]]
	
	in_move_range.append([cur_x, cur_y])
	# schon geprüfte Felder
	var checked = []
	
	while move_count <= move_range:
		
		# Alle im nächsten Zug erreichbare Felder
		var next_batch = []
		
		for element in check_next[move_count]:

			var x_check = element[0]
			var y_check = element[1]
			
			checked.append([x_check, y_check])
		
			var temp = get_possible_moves(x_check, y_check, move_count)
			var reachable_temp = temp[0]
			var attackable_temp = temp[1]
		
			for c in reachable_temp:
				if !checked.has(c):
					in_move_range.append(c)
					next_batch.append(c)
		
			for c in attackable_temp:
				if !checked.has(c) and !in_move_range.has(c):
					in_attack_range.append(c)
		
		check_next.append(next_batch)
		move_count += 1


#	## Testing
#	for c in in_move_range:
#		set_grid_value(c[0], c[1], 2)
#
#		
#	for c in in_attack_range:
#		set_grid_value(c[0], c[1], 3)
#
#		
#	set_grid_value(cur_x, cur_y, 0)
#		
#	for x in grid:
#		print(x)
	

func get_possible_moves(x, y, move_count):
	
	var reachable_neighbours = []
	var attackable_neighbours = []
	
	if move_count > move_range:
		return [reachable_neighbours, attackable_neighbours]


	var max_y = len(grid)
	var max_x = len(grid[0])

	## Ein Feld unter dem untersuchten existiert
	if y > 0:
		## Das untere Feld ist erreichbar
		var grid_value = get_grid_value(x, y-1)
		if (grid_value + move_count) <= move_range:
			reachable_neighbours.append([x, y-1])
		## Das untere Feld ist nicht erreichbar, aber keine Wand
		# Enemy = 500, Wand = 999, Loch = 1000
		elif grid_value < 999:
			attackable_neighbours.append([x, y-1])
		
	## Ein Feld über dem untersuchten existiert
	if y < max_y-1:
		## Das obere Feld ist erreichbar
		var grid_value = get_grid_value(x, y+1)
		if (grid_value + move_count) <= move_range:
			reachable_neighbours.append([x, y+1])
		## Das obere Feld ist nicht erreichbar, aber keine Wand
		# Enemy = 500, Wand = 999, Loch = 1000
		elif grid_value < 999:
			attackable_neighbours.append([x, y+1])
	
	## Ein Feld links neben dem untersuchten existiert
	if x > 0:
		var grid_value = get_grid_value(x-1, y)
		## Das linke Feld ist erreichbar
		if (grid_value + move_count) <= move_range:
			reachable_neighbours.append([x-1, y])
		## Das linke Feld ist nicht erreichbar, aber keine Wand
		# Enemy = 500, Wand = 999, Loch = 1000
		elif grid_value < 999:
			attackable_neighbours.append([x-1, y])
	
	## Ein Feld links neben dem untersuchten existiert
	if x < max_x - 1:
		## Das rechte Feld ist erreichbar
		var grid_value = get_grid_value(x+1, y)
		if (grid_value + move_count) <= move_range:
			reachable_neighbours.append([x+1, y])
		## Das rechte Feld ist nicht erreichbar, aber keine Wand
		# Enemy = 500, Wand = 999, Loch = 1000
		elif grid_value < 999:
			attackable_neighbours.append([x+1, y])

	return [reachable_neighbours, attackable_neighbours]
	

func get_path_to_destination(end_x: int, end_y: int):
	
	var destination = [end_x, end_y]
	
	# nicht erreichbar
	if !in_attack_range.has(destination) and !in_move_range.has(destination):
		return []
	
	# Wenn nur durch Attacke erreichbar
	if in_attack_range.has(destination):
		# kürzesten Pfad zu Nachbar
		return []
		
	# in movement range
	var id_start = coordinate_to_id(x_coord, y_coord)
	var id_end = coordinate_to_id(end_x, end_y)
	var id_path = astar.get_point_path(id_start, id_end)
	var coord_path = []
	for id in id_path:
		coord_path.append(id_to_coordinate(id))
	return coord_path



func get_grid_value(x, y):
	return grid[y][x]
	
func set_grid_value(x, y, value):
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

			if x < x_max+1:
				var id_n = coordinate_to_id(x+1, y)
				astar.connect_points(id, id_n)
				
	return astar


	
func coordinate_to_id(x, y):
	return x*ID_CONVERT_MULT + y
	
func id_to_coordinate(coord):
	
	var y = coord % ID_CONVERT_MULT
	var x = (coord - y) / ID_CONVERT_MULT
	return [x, y]
