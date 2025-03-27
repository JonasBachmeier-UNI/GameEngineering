extends Node

var units = []
var base_grid = []

@onready var tml = $"../Map"
@onready var overlay = $"../UnitOverlay"

var is_unit_moving = false
var moving_unit = null
var is_ai_move = false
signal unit_moves
signal path_completed
signal ai_move_done
signal all_units_moved

## TODO Menü passend anzeigen

@export var speed = 70

func _ready() -> void:
	units = get_children()


func _process(delta: float) -> void:
	execute_movement(delta)


func execute_movement(delta):
	if !is_unit_moving:
		return
	
	if moving_unit.path_follow.progress_ratio >= 1:
		is_unit_moving = false
		moving_unit.curve.clear_points()
		emit_signal("path_completed")
		if is_ai_move:
			is_ai_move = false
			emit_signal("ai_move_done")
		return
	
	moving_unit.path_follow.progress += speed * delta



func update_unit_grids(grid):
	for unit in units:
		unit.on_game_board_matrix_ready(grid)


func _on_game_board_matrix_ready(value: Variant) -> void:
	base_grid = value
	update_unit_grids(value)

func create_astar():
	for unit in units:
		unit.create_astar_for_grid()

func move_unit(unit, new_x, new_y):
	var grid_path = unit.get_path_to_destination(new_x, new_y)
	var path = unit.get_global_positions_from_path(grid_path)
	unit.set_path(path)
	unit.moved_count += len(path)-1
	unit.update_position(grid_path[-1][0], grid_path[-1][1])
	start_unit_movement(unit)
	create_astar()

func start_unit_movement(unit):
	moving_unit = unit
	clear_overlay()
	is_unit_moving = true
	unit.path_follow.progress = 0
	emit_signal("unit_moves")


func enemy_ai_move(unit):
	ai_move(unit)
	is_ai_move = true


func ai_move(unit):
	unit.update_board()
	var ai_data = unit.get_shortest_path_to_enemy()
	var shortest_path = ai_data[0]
	var target_unit = ai_data[1]
	
	## Kein Pfad zu einem Gegner möglich
	if len(shortest_path) <= 1:
		unit.wait_for_next_turn()
		emit_signal("ai_move_done")
		return
	
	## Eine Einheit ist angreifbar
	if len(shortest_path) <= unit.get_moves_left() + 1:
		var new_x = shortest_path[-1][0]
		var new_y = shortest_path[-1][1]
		move_unit(unit, new_x, new_y)
		unit_attack(unit, target_unit)
		return
	
	## Keine Einheit ist angreifbar
	var new_x_y = shortest_path[unit.get_moves_left()]
	var new_x = new_x_y[0]
	var new_y = new_x_y[1]
	move_unit(unit, new_x, new_y)
	unit.wait_for_next_turn()


func unit_wait(unit):
	unit.wait_for_next_turn()


## TODO: passend einbauen
func check_all_units_moved():
	if is_ai_move:
		return
	for unit in units:
		if !unit.is_enemy and !unit.has_moved:
			return
	emit_signal("all_units_moved")


func unit_attack(attacker, defender):
	attacker.attack_unit(defender)

func show_unit_range(unit):
	unit.show_range()

func clear_overlay():
	overlay.clear()
