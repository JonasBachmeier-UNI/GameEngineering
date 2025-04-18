extends Node

var max_hp
var unit_name
var hp
var dmg
var defense

signal update_health(hp, maxhp)

@onready var dmg_stat_label = $MarginContainer/HBoxContainer/Stats/CombatStats/ATK/Stat
@onready var def_stat_label = $MarginContainer/HBoxContainer/Stats/CombatStats/DEF/Stat
@onready var name_label = $MarginContainer/HBoxContainer/Stats/CombatStats/Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dmg_stat_label.text = str(dmg)
	def_stat_label.text = str(defense)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_stats(unit):
	dmg = unit.dmg
	defense = unit.defense
	hp = unit.hp
	max_hp = unit.max_hp
	unit_name = unit.unit_name
	dmg_stat_label.text = str(dmg)
	def_stat_label.text = str(defense)
	name_label.text = unit_name
	emit_signal("update_health", hp, max_hp)

func add_border():
	var style_box: StyleBoxFlat = $".".get_theme_stylebox("panel")
	style_box.border_width_right = 2
	style_box.border_color = Color.BLACK
	$".".add_theme_stylebox_override("panel", style_box)

func remove_border():
	var style_box: StyleBoxFlat = $".".get_theme_stylebox("panel")
	style_box.border_width_right = 0
	style_box.border_color = Color.TRANSPARENT
	$".".add_theme_stylebox_override("panel", style_box)
