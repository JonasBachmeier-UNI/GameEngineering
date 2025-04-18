extends Node

var time = Time.get_ticks_msec()
const ID_PLACEHOLDER = ""

## Format: Zeit, Event, unit1, unit2, Schaden


func get_time():
	return Time.get_ticks_msec()

func make_line(event, uid1, uid2=ID_PLACEHOLDER, dmg=0):
	get_time()
	var line = str(get_time()) + "," + event + "," + str(uid1) + "," + str(uid2) + str(dmg) + "\n"
	var f = FileAccess.open("res://Logs/logs.txt", FileAccess.READ_WRITE)
	f.seek_end()
	f.store_string(line)
	f.close()

func on_select_unit(unit):
	var unit_id = unit.unit_id
	make_line("Unit Selected", unit_id)

func on_attack(attacker, defender, damage):
	var attacker_id = attacker.unit_id
	var defender_id = defender.unit_id
	make_line("Attack", attacker_id, defender_id, damage)

func on_unit_death(attacker, defender):
	var attacker_id = attacker.unit_id
	var defender_id = defender.unit_id
	make_line("Kill", attacker_id, defender_id)

func on_attack_selected(unit):
	var unit_id = unit.unit_id
	make_line("Attack Selected", unit_id)

func on_wait_selected(unit):
	var unit_id = unit.unit_id
	make_line("Wait Selected", unit_id)

func on_move_selected(unit):
	var unit_id = unit.unit_id
	make_line("Move Selected", unit_id)
