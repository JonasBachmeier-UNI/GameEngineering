extends Node

@onready var units_node = $"../GameBoard/Units"
var units = []
var player_units = []
var enemy_units = []
var turn_count = 0
var is_player_turn = true

signal player_turn
signal enemy_turn
signal new_turn

func _ready() -> void:
	update_units()


func _process(delta: float) -> void:
	## Kein Input möglich
	if !is_player_turn:
		start_next_turn()
		return
		
	if Input.is_action_just_pressed("ui_text_backspace"):
		start_next_turn()



func update_units():
	units = units_node.get_children()
	for unit in units:
		if unit.is_enemy:
			enemy_units.append(unit)
		else:
			player_units.append(unit)


## TODO: test
func ai_turn():
	for unit in enemy_units:
		unit.ai_move()
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
		pass
	else:
		## AI Turn
		is_player_turn = false
		emit_signal("enemy_turn")
		ai_turn()
		pass
