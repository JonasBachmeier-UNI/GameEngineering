extends AnimatedSprite2D

@onready var tml = $"../Map"
@onready var gameboard = $"../../GameBoard"
@export var start_x = 1
@export var start_y = 1
var x_pos = start_x
var y_pos = start_y
var all_units
var my_units
var enemies

var did_select_unit: bool = false
var selected_unit = null

var can_select = false
var can_select_target = false
var can_select_enemy = false


func _on_game_board_matrix_ready(value: Variant) -> void:
	var tml_vec = gameboard.grid_to_tml_coords(Vector2i(start_x, start_y))
	global_position = tml.map_to_local(tml_vec)
	update_units()
	print(get_hovered_unit())
	
func _process(delta: float) -> void:
	
	unit_move_check_routine()
	
	## Cursor Movement TODO: vielleicht nur auf erreichbare gehen dürfen (wenn unit_selected)
	movement_check_routine()
	
func movement_check_routine():
	if Input.is_action_just_pressed("ui_up"):
		move(Vector2.UP)
	elif Input.is_action_just_pressed("ui_down"):
		move(Vector2.DOWN)
	elif Input.is_action_just_pressed("ui_left"):
		move(Vector2.LEFT)
	elif Input.is_action_just_pressed("ui_right"):
		move(Vector2.RIGHT)


func unit_move_check_routine():
	if can_select:
		## TODO: select_unit() auf gewünschten Input
		# TODO: testen
		if Input.is_action_just_pressed("ui_select"):
			select_unit(get_hovered_unit())
		
	if did_select_unit:
		## TODO: mit gewünschten Input reset_selection aufrufen
		# TODO: testen
		if Input.is_action_just_pressed("ui_cancel"):
			reset_selection()
	
	if can_select_target:
		## TODO: mit gewünschten Input unit bewegen
		if Input.is_action_just_pressed("ui_select"):
			print("Einheit auf: ", selected_unit.x_coord, " ", selected_unit.y_coord, " nach: ", x_pos, " ", y_pos)
			## selected_unit geht zur aktuellen Position
			pass
			
	if can_select_enemy:
		## TODO: mit gewünschten Input unit Feld angreifen lassen
		if Input.is_action_just_pressed("ui_select"):
			print("Einheit auf: ", selected_unit.x_coord, " ", selected_unit.y_coord, " attackiert: ", x_pos, " ", y_pos)
			## selected_unit geht neben aktuelles Feld und greift an
			pass
		pass

func move(direction: Vector2):
	## Aktuelle Position auf der Tilemap
	var current_tile = tml.local_to_map(global_position)
	## Zielposition
	var target_tile = Vector2i(
		current_tile.x + direction.x,
		current_tile.y + direction.y
	)
	
	## Darf man auf diese Position
	var tile_id = tml.get_cell_source_id(target_tile)
	if tile_id != 0:
		return
	
	## Positionsänderung
	global_position = tml.map_to_local(target_tile)
	x_pos += direction.x
	y_pos += direction.y
	
	print(get_hovered_unit())
	
	
## Speichert die Position der Einheiten ab
func update_units():
	var parent = $"../Units"
	
	## Listen werden erstellt
	my_units = []
	enemies = []
	all_units = parent.get_children()
	
	## Listen werden befüllt
	for unit in all_units:
		if unit.isEnemy:
			enemies.append(unit)
		else:
			my_units.append(unit)
			
func get_hovered_unit():
	for unit in all_units:
		if unit.x_coord == x_pos and unit.y_coord == y_pos:
			return unit
	return null
	
func hovering_check():
	can_select = false
	can_select_target = false
	can_select_enemy = false
	
	var hovered = get_hovered_unit()
	if hovered == null and selected_unit == null:
		return
	
	var pos_vec = [x_pos, y_pos]
	
	## Noch keine Einheit ausgewählt
	if !did_select_unit:
		if hovered == null:
			## Leeres Feld also nichts
			return
		## Auswählbare Einheit auf Feld
		if !hovered.isEnemy:
			## Einheit Auswählbar
			can_select = true
			return
		pass
	
	## Eine Einheit ist bereits ausgewählt
	if did_select_unit:
		if selected_unit.in_move_range.has(pos_vec):
			## Unit geht Pfad und reset bools / selected units
			can_select_target = true
			return
		if selected_unit.in_attack_range.has(pos_vec):
			## Unit geht neben das Feld und greift an und reset bools / selected units
			can_select_enemy = true
			return
			
		## Nicht auswählbar
		return
	

func select_unit(unit):
	did_select_unit = true
	selected_unit = unit
	can_select = false
	
func reset_selection():
	hovering_check()
	did_select_unit = false
	selected_unit = null
