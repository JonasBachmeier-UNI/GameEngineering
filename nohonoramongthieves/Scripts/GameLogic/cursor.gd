extends AnimatedSprite2D

@onready var tml = $"../Map"
@onready var overlay = $"../UnitOverlay"
@onready var path_map = $"../UnitPath"
@onready var enemy_range_map = $"../EnemyRangeOverlay"
@onready var gameboard = $"../../GameBoard"
@onready var unit_manager = $"../Units"
@export var start_x = 1
@export var start_y = 1
var x_pos = start_x
var y_pos = start_y
var last_x = start_x
var last_y = start_y

var all_units
var my_units
var enemies

signal update_board
signal show_info(unit)
signal show_hovered_info(unit)
signal remove_info()
signal remove_hovered_info()
signal show_actions(selected_unit, x, y, can_move, can_attack, can_wait, can_end_turn)

var did_select_unit: bool = false
var selected_unit = null

var is_active = true
var in_menu = false

var can_select = false
var can_select_target = false
var can_select_enemy = false
var hovering_on_selected = false
var help_path = false


func _on_game_board_matrix_ready(value: Variant) -> void:
	var tml_vec = gameboard.grid_to_tml_coords(Vector2i(start_x, start_y))
	global_position = tml.map_to_local(tml_vec)
	var grid_vec = gameboard.tml_to_grid_coords(tml.local_to_map(global_position))
	x_pos = grid_vec[0]
	y_pos = grid_vec[1]
	hovering_check()
	
func _process(delta: float) -> void:
	
	if !is_active:
		return
	
	unit_move_check_routine()
	
	## Cursor Movement TODO: vielleicht nur auf erreichbare gehen dürfen (wenn unit_selected)
	movement_check_routine()
	
	enemy_overlay_routine()
	
func movement_check_routine():
	if !in_menu:
		if Input.is_action_just_pressed("ui_up"):
			move(Vector2.UP)
		elif Input.is_action_just_pressed("ui_down"):
			move(Vector2.DOWN)
		elif Input.is_action_just_pressed("ui_left"):
			move(Vector2.LEFT)
		elif Input.is_action_just_pressed("ui_right"):
			move(Vector2.RIGHT)


func enemy_overlay_routine():
	if Input.is_action_just_pressed("ui_text_completion_replace"):
		show_enemy_range()
	if Input.is_action_just_released("ui_text_completion_replace"):
		clear_enemy_range()


func unit_move_check_routine():
	if can_select:
		## TODO: select_unit() auf gewünschten Input
		# TODO: testen
		if Input.is_action_just_pressed("ui_select"):
			var unit = get_hovered_unit()
			select_unit(unit)
			#TODO: Instanciate Info Screen for selected unit here
			emit_signal("show_info", unit)
			hovering_check()
			return
		
	if did_select_unit:
		## TODO: mit gewünschten Input reset_selection aufrufen
		# TODO: testen
		if Input.is_action_just_pressed("ui_cancel"):
			emit_signal("remove_info")
			reset_selection()
	
	if hovering_on_selected:
		if Input.is_action_just_pressed("ui_select"):		
			emit_show_actions(selected_unit, null, x_pos, y_pos, last_x, last_y, false, false, true)
			return
	
	if can_select_target:
		## TODO: mit gewünschten Input unit bewegen
		if Input.is_action_just_pressed("ui_select"):		
			emit_show_actions(selected_unit, null, x_pos, y_pos, last_x, last_y, true)
			return
			
	if can_select_enemy:
		## TODO: mit gewünschten Input unit Feld angreifen lassen
		if Input.is_action_just_pressed("ui_select"):
			if help_path:
				emit_show_actions(selected_unit, get_hovered_unit(), x_pos, y_pos, last_x, last_y, false, true)
			else:
				emit_show_actions(selected_unit, get_hovered_unit(), x_pos, y_pos, x_pos, y_pos, false, true)
			return
	if Input.is_action_just_pressed("ui_select"):
		print("test")
		emit_show_actions(selected_unit, get_hovered_unit(), x_pos, y_pos, x_pos, y_pos, false, false, false, true)


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
	
	## Wenn bewegt wird, wird der Pfad gelöscht
	path_map.clear()
	
	## Positionsänderung
	global_position = tml.map_to_local(target_tile)
	last_x = x_pos
	last_y = y_pos
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
		if unit.is_enemy:
			enemies.append(unit)
		else:
			my_units.append(unit)

func get_hovered_unit():
	print(x_pos)
	print(y_pos)
	for unit in all_units:
		if unit.x_coord == x_pos and unit.y_coord == y_pos:
			return unit
	return null
	
func hovering_check():
	update_units()
	can_select = false
	can_select_target = false
	can_select_enemy = false
	hovering_on_selected = false
	help_path = false
	
	if !did_select_unit:
		overlay.clear()
	
	var hovered = get_hovered_unit()
	if hovered == null:
		emit_signal("remove_hovered_info")
	
	## Wenn die Einheit schon gezogen hat wird sie nicht mehr benutzt
	if hovered != null:
		if hovered != selected_unit:
			emit_signal("remove_hovered_info")
			emit_signal("show_hovered_info", hovered)
		else:
			hovering_on_selected = true
	
	var pos_vec = Vector2i(x_pos, y_pos)

	## Noch keine Einheit ausgewählt
	if !did_select_unit:
		if hovered == null:
			## Leeres Feld also nichts
			#print("Leeres Feld")
			return
		
		## Wenn die Einheit schon gezogen hat wird sie nicht mehr benutzt
		if hovered.has_moved:
			return
		
		## Auswählbare Einheit auf Feld
		unit_manager.show_unit_range(hovered)
		if !hovered.is_enemy:
			## Einheit Auswählbar
			can_select = true
			#print("Einheit Auswählbar")
			return
			
		#print("Gegner nicht auswählbar")
		return
	
	## Eine Einheit ist bereits ausgewählt

	if x_pos == selected_unit.x_coord and y_pos == selected_unit.y_coord:
		#print("Auf diesem Feld steht die Einheit")
		return
	
	if selected_unit.in_move_range.has(pos_vec):
		## Unit geht Pfad und reset bools / selected units
		can_select_target = true
		var path = selected_unit.get_path_to_destination(x_pos, y_pos)
		path_map.path_to_tilemap(path)
		return
		
	if hovered == null:
		emit_signal("remove_hovered_info")
		return
	
	## TODO: Vergleichsinfo anzeigen
	
	if selected_unit.in_attack_range.has(pos_vec) and hovered.is_enemy:
		## Unit geht neben das Feld und greift an und reset bools / selected units
		can_select_enemy = true
		
		var path = selected_unit.get_path_to_destination(x_pos, y_pos)
		
		if selected_unit.in_move_range.has(Vector2i(last_x, last_y)):
			path = selected_unit.get_path_to_destination(last_x, last_y)
			help_path = true
		
		path_map.path_to_tilemap(path)
		#print("Feld angreifbar")
		return
			
	## Nicht auswählbar
	return
	

func select_unit(unit):
	did_select_unit = true
	selected_unit = unit
	unit_manager.show_unit_range(selected_unit)
	can_select = false
	
func reset_selection():
	#print("Auswahl zurückgenommen")
	path_map.clear()
	if selected_unit != null:
		unit_manager.clear_overlay()
	did_select_unit = false
	selected_unit = null
	emit_signal("remove_info")
	hovering_check()

## Zwischenschritt, um das setzen der Button-verfügbarkeit zu vereinfachen
func emit_show_actions(selected_unit, target_unit, x, y, last_x, last_y, can_move=false, can_attack=false, can_wait=false, can_end_turn=false):
	in_menu = true
	emit_signal("show_actions", selected_unit, target_unit, x, y, last_x, last_y, can_move, can_attack, can_wait, can_end_turn)

func show_enemy_range():
	unit_manager.get_units()
	var fields = unit_manager.get_enemy_range()
	enemy_range_map.show_overlay_for_grid(fields)

func clear_enemy_range():
	enemy_range_map.clear()


func _on_game_manager_player_turn() -> void:
	print("PLAYER TURN")
	$"../../UI/Phase".text = "Player Turn"
	is_active = true
	visible = true
	hovering_check()


func _on_game_manager_enemy_turn() -> void:
	print("ENEMY TURN")
	$"../../UI/Phase".text = "Enemy Turn"
	is_active = false
	visible = false


func _on_units_path_completed() -> void:
	reset_selection()
	is_active = true
	emit_signal("update_board")
	update_units()


func _on_units_unit_moves() -> void:
	is_active = false


func _on_units_reset_info() -> void:
	reset_selection()
