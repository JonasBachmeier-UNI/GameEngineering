extends PanelContainer

var maxhp
var hp
var dmg
var defense

@onready var dmg_stat_label = $HBoxContainer/MarginContainer/CombatStats/ATK/Stat
@onready var def_stat_label = $HBoxContainer/MarginContainer/CombatStats/DEF/Stat

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
	maxhp = unit.max_hp
	dmg_stat_label.text = str(dmg)
	def_stat_label.text = str(defense)

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
