extends Node

@onready var unit_manager = $"../GameBoard/Units"
@onready var cursor = $"../GameBoard/Cursor"
var units = []
var player_units = []
var enemy_units = []
var turn_count = 0
var is_player_turn = true

var enemy_move_counter = 0

signal player_turn
signal enemy_turn
signal new_turn

func _ready() -> void:
	update_units()


func _process(delta: float) -> void:
	## Kein Input möglich
	if !is_player_turn:
		return
	
	if !cursor.is_active:
		return
	
	if Input.is_action_just_pressed("ui_text_backspace"):
		cursor.reset_selection()
		start_next_turn()



func update_units():
	units = unit_manager.get_children()
	for unit in units:
		if unit.is_enemy:
			enemy_units.append(unit)
		else:
			player_units.append(unit)


## TODO: test
func ai_turn():
	if len(enemy_units) > enemy_move_counter:
		print("AI_TURN: ", enemy_move_counter)
		enemy_move_counter += 1
		unit_manager.enemy_ai_move(enemy_units[enemy_move_counter - 1])
	else:
		start_next_turn()


func start_next_turn():
	emit_signal("new_turn")
	turn_count += 1
	for unit in units:
		unit.moved_count = 0
		unit.has_moved = false
		unit.update_units()
		unit.get_cells_in_range()
		
	if turn_count % 2 == 0:
		## Player Turn
		is_player_turn = true
		emit_signal("player_turn")
	else:
		## AI Turn
		is_player_turn = false
		emit_signal("enemy_turn")
		start_ai()

func start_ai():
	enemy_move_counter = 0
	ai_turn()

func _on_units_ai_move_done() -> void:
	print("ON_DONE")
	ai_turn()


func _on_units_all_units_moved() -> void:
	if is_player_turn:
		start_next_turn()
