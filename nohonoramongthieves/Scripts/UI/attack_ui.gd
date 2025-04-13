extends Control

@onready var attacker_health_ui = $Container/VBoxContainer/Info/HBoxContainer/Attacker/Health
@onready var defender_health_ui = $Container/VBoxContainer/Info/HBoxContainer/Defender/Health
@onready var attack_button = $Container/VBoxContainer/Buttons/HBoxContainer/Attack
@onready var cancel_button = $Container/VBoxContainer/Buttons/HBoxContainer/Cancel

@onready var unit_manager = $"../../GameBoard/Units"
@onready var game_manager = $"../../GameManager"
@onready var cursor = $"../../GameBoard/Cursor"

signal cancel_attack
signal confirm_attack

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _notification(what):
	if what == NOTIFICATION_VISIBILITY_CHANGED and visible:
		attack_button.grab_focus()
	

func _on_cancel_pressed() -> void:
	emit_signal("cancel_attack")
	close_menu()

func _on_attack_pressed() -> void:
	emit_signal("confirm_attack")
	close_menu()

func close_menu() -> void:
	visible = false


func _on_show_attack_ui(attacker: Variant, defender: Variant) -> void:
	var attack_results = unit_manager.get_attack_result(attacker, defender)
	attacker_health_ui.update_health_ui(attacker.hp, attacker.max_hp)
	defender_health_ui.update_health_ui(defender.hp - attack_results, defender.max_hp)
	visible = true
	
