extends VBoxContainer

@export var unit: Unit
@onready var hp_bar =  $HPBar
@onready var current_hp_label =  $HP/CurrHP
@onready var max_hp_label =  $HP/MaxHP

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_health_ui(hp, max_hp):
	hp_bar.value = hp * 100 / max_hp
	current_hp_label.text = str(hp)
	max_hp_label.text = str(max_hp)


func _on_unit_update_health(hp: Variant, max_hp: Variant) -> void:
	update_health_ui(hp, max_hp)
