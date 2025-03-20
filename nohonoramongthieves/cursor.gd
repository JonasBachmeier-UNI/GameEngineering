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

signal update_board

var did_select_unit: bool = false
var selected_unit = null

var is_active = true

var can_select = false
var can_select_target = false
var can_select_enemy = false


func _on_game_board_matrix_ready(value: Variant) -> void:
	var tml_vec = gameboard.grid_to_tml_coords(Vector2i(start_x, start_y))
	global_position = tml.map_to_local(tml_vec)
	hovering_check()
	
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
			selected_unit.move(x_pos, y_pos)
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
	
	if !is_active:
		return
	
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
	hovering_check()
	
	
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
	update_units()
	can_select = false
	can_select_target = false
	can_select_enemy = false
	
	var hovered = get_hovered_unit()
	if hovered == null and !did_select_unit:
		return
	
	var pos_vec = Vector2i(x_pos, y_pos)
	
	## Noch keine Einheit ausgewählt
	if !did_select_unit:
		if hovered == null:
			## Leeres Feld also nichts
			print("Leeres Feld")
			return
		## Auswählbare Einheit auf Feld
		if !hovered.isEnemy:
			## Einheit Auswählbar
			can_select = true
			print("Einheit Auswählbar")
			return
			
		print("Gegner nicht auswählbar")
		return
	
	## Eine Einheit ist bereits ausgewählt

	if x_pos == selected_unit.x_coord and y_pos == selected_unit.y_coord:
		print("Auf diesem Feld steht die Einheit")
		return
		pass

	## Array von Arrays zu Array von Vector2is
	# TODO: in Unit alle 2d Arrays zu Vector2i
	var test_move = []
	for i in selected_unit.in_move_range:
		test_move.append(Vector2i(i[0], i[1]))
		
	var test_attack = []
	for i in selected_unit.in_attack_range:
		test_attack.append(Vector2i(i[0], i[1]))
		
	if test_move.has(pos_vec):
		## Unit geht Pfad und reset bools / selected units
		can_select_target = true
		print("Feld erreichbar")
		return
		
	if hovered == null:
		print("nicht erreichbar / angreifbar")
		return
		
	if test_attack.has(pos_vec) and hovered.isEnemy:
		## Unit geht neben das Feld und greift an und reset bools / selected units
		can_select_enemy = true
		print("Feld angreifbar")
		return
			
	## Nicht auswählbar
	return
	

func select_unit(unit):
	print("Einheit ausgewählt")
	did_select_unit = true
	selected_unit = unit
	can_select = false
	
func reset_selection():
	print("Auswahl zurückgenommen")
	did_select_unit = false
	selected_unit = null
	hovering_check()


func _on_unit_path_completed() -> void:
	selected_unit.x_coord = x_pos
	selected_unit.y_coord = y_pos
	is_active = true
	reset_selection()
	emit_signal("update_board")
	update_units()



func _on_unit_path_started() -> void:
	is_active = false
