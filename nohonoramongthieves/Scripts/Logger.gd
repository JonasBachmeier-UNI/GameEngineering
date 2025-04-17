extends Node

var time

func get_time():
	time = Time.get_unix_time_from_system()

func on_select_unit(unit):
	get_time()
	var unit_id = unit.unit_id

func on_attack(attacker, defender, damage):
	get_time()

func on_unit_death(unit):
	get_time()

func on_attack_selected(unit):
	get_time()
	var unit_id = unit.unit_id

func on_wait_selected(unit):
	get_time()
	var unit_id = unit.unit_id

func on_move_selected(unit):
	get_time()
	var unit_id = unit.unit_id
