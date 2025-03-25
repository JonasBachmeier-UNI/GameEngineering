extends Control

var x_pos = 0
var y_pos = 0
var unit_selected = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _notification(what):
	if what == NOTIFICATION_VISIBILITY_CHANGED and visible:
		print("thing gets called")
		$Panel/VBoxContainer/Attack.visible = unit_selected
		$"Panel/VBoxContainer/Seperator 2".visible = unit_selected
		$Panel/VBoxContainer/Info.visible = unit_selected
		$"Panel/VBoxContainer/Seperator 3".visible = unit_selected
		$Panel/VBoxContainer.get_children()[0].grab_focus()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_move_pressed() -> void:
	var cursor = get_node("/root/Test/GameBoard/Cursor")
	cursor.selected_unit.move(x_pos, y_pos)
	$".".visible = false
	cursor.in_menu = false


func _on_attack_pressed() -> void:
	pass # Replace with function body.


func _on_info_pressed() -> void:
	pass # Replace with function body.


func _on_end_turn_pressed() -> void:
	pass # Replace with function body.
