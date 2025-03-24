extends Node

var units = []
var base_grid = []

func _ready() -> void:
	units = get_children()

func place_units(grid):
	for unit in units:
		unit.on_game_board_matrix_ready(grid)
		unit.current_pos_to_tml()


func _on_game_board_matrix_ready(value: Variant) -> void:
	base_grid = value
	place_units(value)
