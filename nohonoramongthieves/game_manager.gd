extends Node

@onready var units_node = $"../GameBoard/Units"
var units = []
var player_units = []
var enemy_units = []
var turn_count = 0

func _ready() -> void:
	update_units()


func update_units():
	units = units_node.get_children()
	for unit in units:
		if unit.is_enemy:
			enemy_units.append(unit)
		else:
			player_units.append(unit)


func start_next_turn():
	turn_count += 1
	update_units()
	for unit in units:
		unit.moved_count = 0
		
	if turn_count % 2 == 0:
		## Player Turn
		pass
	else:
		## AI Turn
		pass
	
