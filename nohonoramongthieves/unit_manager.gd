extends Node

var units = []
var base_grid = []

@onready var tml = $"../Map"
@onready var overlay = $"../UnitOverlay"

var is_unit_moving = false
var moving_unit = null
var is_ai_move = false
var attack_queued = false
var defender

signal unit_moves
signal path_completed
signal ai_move_done
signal all_units_moved

## TODO Menü passend anzeigen

@export var speed = 70

func _ready() -> void:
	get_units()


func _process(delta: float) -> void:
	execute_movement(delta)

func create_unit(unit_name, hp, dmg, defense, x, y):
	var prefab = preload("res://unit.tscn")
	var new_unit = prefab.instantiate()
	new_unit.max_hp = hp
	new_unit.hp = hp
	new_unit.dmg = dmg
	new_unit.defense = defense
	new_unit.x_coord = x
	new_unit.y_coord = y
	new_unit.unit_name = unit_name
	add_child(new_unit)
	get_units()
	update_unit_grids(base_grid)


func get_units():
	units = get_children().filter(func(unit): return unit.hp > 0)

func execute_movement(delta):
	if !is_unit_moving:
		return
	
	if moving_unit.path_follow.progress_ratio >= 1:
		is_unit_moving = false
		moving_unit.curve.clear_points()
		
		end_path_check()
		return
	
	moving_unit.path_follow.progress += speed * delta



func update_unit_grids(grid):
	for unit in units:
		unit.on_game_board_matrix_ready(grid)


func _on_game_board_matrix_ready(value: Variant) -> void:
	base_grid = value
	update_unit_grids(value)

func create_astar():
	get_units()
	for unit in units:
		unit.create_astar_for_grid()

func move_unit(unit, new_x, new_y):
	var grid_path = unit.get_path_to_destination(new_x, new_y)
	var path = unit.get_global_positions_from_path(grid_path)
	
	if len(path) < 2:
		end_path_check()
		return
	
	unit.set_path(path)
	unit.moved_count += len(path)-1
	unit.update_position(grid_path[-1][0], grid_path[-1][1])
	start_unit_movement(unit)
	create_astar()

func end_path_check():
	if attack_queued:
		unit_attack(moving_unit, defender)
		attack_queued = false
		emit_signal("path_completed")
		if is_ai_move:
			is_ai_move = false
			emit_signal("ai_move_done")
	
	else:
		emit_signal("path_completed")
		if is_ai_move:
			is_ai_move = false
			emit_signal("ai_move_done")

func start_unit_movement(unit):
	moving_unit = unit
	clear_overlay()
	is_unit_moving = true
	unit.path_follow.progress = 0
	emit_signal("unit_moves")


func enemy_ai_move(unit):
	is_ai_move = true
	ai_move(unit)


func ai_move(unit):
	unit.update_board()
	create_astar()
	var ai_data = unit.get_shortest_path_to_enemy()
	var shortest_path = ai_data[0]
	var target_unit = ai_data[1]
	
	## Kein Pfad zu einem Gegner möglich
	if target_unit == null:
		unit.wait_for_next_turn()
		is_ai_move = false
		emit_signal("ai_move_done")
		return
	
	## Eine Einheit ist angreifbar
	if len(shortest_path) <= unit.get_moves_left() + 1:
		var dest_x = shortest_path[-1][0]
		var dest_y = shortest_path[-1][1]
		move_unit(unit, dest_x, dest_y)
		queue_attack(target_unit)
		#unit_attack(unit, target_unit)
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


func queue_attack(defending_unit):
	attack_queued = true
	defender = defending_unit


func unit_attack(attacker, defender):
	var damage = attacker.dmg + attacker.dmg_bonus
	attacker.dmg_bonus = 0
	
	if damage < defender.defense:
		return
	
	defender.hp -= (damage - defender.defense)
	if defender.hp < 0:
		defender.hp = 0
	
	if defender.hp == 0:
		defender.on_death()
		check_one_side_empty()

func show_unit_range(unit):
	unit.show_range()

func clear_overlay():
	overlay.clear()


func get_enemy_range():
	var return_array = []
	for unit in units:
		if unit.is_enemy:
			for field in unit.in_move_range:
				if !return_array.has(field):
					return_array.append(field)
			for field in unit.in_attack_range:
				if !return_array.has(field):
					return_array.append(field)
	return return_array


## TODO: Signals an game manager
func check_one_side_empty():
	get_units()
	var enemies = []
	var allies = []
	
	for unit in units:
		if unit.is_enemy:
			enemies.append(unit)
		else:
			allies.append(unit)
	
	if enemies.is_empty():
		print("PLAYER WON")
	
	elif allies.is_empty():
		print("ENEMY WON")
