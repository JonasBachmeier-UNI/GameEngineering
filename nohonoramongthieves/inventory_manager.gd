extends Node

var inventory = []
const POTION_HEALING_VALUE = 10
const DAMAGE_BONUS_VALUE = 2

enum ITEM {POTION, STEROIDS}

func _ready() -> void:
	# test()
	pass

func test():
	var unit_manager = $"../GameBoard/Units"
	var test_unit = $"../GameBoard/Units/Unit"
	print(test_unit)
	add_to_inventory(ITEM.POTION)
	add_to_inventory(ITEM.STEROIDS)
	add_to_inventory(ITEM.POTION)
	print(test_unit.hp)
	test_unit.hp -= 5
	print(test_unit.hp)
	use_item(ITEM.POTION, test_unit)
	print(test_unit.hp)
	
	var test_unit_2 = $"../GameBoard/Units/Unit2"
	print("VOR A1 ", test_unit_2.hp)
	unit_manager.unit_attack(test_unit, test_unit_2)
	print("NACH A1 ", test_unit_2.hp)
	test_unit_2.hp = test_unit_2.max_hp
	use_item(ITEM.STEROIDS, test_unit)
	unit_manager.unit_attack(test_unit, test_unit_2)
	print("NACH A2 ", test_unit_2.hp)

func add_to_inventory(item: ITEM):
	inventory.append(item)


func remove_item(item: ITEM):
	inventory.erase(item)


func use_item(item: ITEM, unit):
	## item nicht im Inventar
	if !inventory.has(item):
		return
	match item:
		ITEM.POTION:
			unit.heal_self(POTION_HEALING_VALUE)
		ITEM.STEROIDS:
			unit.gain_damage_for_next_turn(DAMAGE_BONUS_VALUE)
	remove_item(item)
