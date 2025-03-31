extends Control

var x_pos = 0
var y_pos = 0
var unit_on_field = false
var can_move
var can_attack

var selected_unit

@onready var unit_manager = $"../../GameBoard/Units"
@onready var cursor = $"../../GameBoard/Cursor"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _notification(what):
	if what == NOTIFICATION_VISIBILITY_CHANGED and visible:
		print("thing gets called")
		print(can_move)
		$PanelContainer/VBoxContainer/Move.visible = can_move
		$PanelContainer/VBoxContainer/Attack.visible = can_attack
		for child in $PanelContainer/VBoxContainer.get_children():
			if child.visible:
				child.grab_focus()
				break

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_move_pressed() -> void:
	unit_manager.move_unit(selected_unit,x_pos, y_pos)
	visible = false
	cursor.in_menu = false


func _on_attack_pressed() -> void:
	pass # Replace with function body.


func _on_end_turn_pressed() -> void:
	pass # Replace with function body.


func _on_cursor_show_actions(selected_unit: Variant, x: Variant, y: Variant, can_move: Variant, can_attack: Variant, can_wait: Variant, can_end_turn: Variant,) -> void:
	x_pos = x
	y_pos = y
	$".".selected_unit = selected_unit
	$".".can_move = can_move
	$".".can_attack = can_attack
	visible = true
