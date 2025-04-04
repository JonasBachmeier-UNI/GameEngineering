extends Control

var x_pos = 0
var y_pos = 0
var last_x = 0
var last_y = 0
var unit_on_field = false
var can_move
var can_attack
var can_wait
var can_end_turn

var selected_unit
var target_unit

signal show_attack_ui(attacker, defender)

@onready var buttons = $PanelContainer/VBoxContainer.get_children()

@onready var unit_manager = $"../../GameBoard/Units"
@onready var game_manager = $"../../GameManager"
@onready var cursor = $"../../GameBoard/Cursor"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _notification(what):
	if what == NOTIFICATION_VISIBILITY_CHANGED and visible:
		$PanelContainer/VBoxContainer/Move.visible = can_move
		$PanelContainer/VBoxContainer/Attack.visible = can_attack
		$PanelContainer/VBoxContainer/Wait.visible = can_wait
		$PanelContainer/VBoxContainer/End_Turn.visible = can_attack
		focus_button()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	pass


func _on_move_pressed():
	unit_manager.move_unit(selected_unit, x_pos, y_pos)
	close_menu()


func _on_attack_pressed():
	emit_signal("show_attack_ui", selected_unit, target_unit)
	disable_buttons()

func _on_attack_confirmed():
	unit_manager.queue_attack(target_unit)
	unit_manager.move_unit(selected_unit, last_x, last_y)
	#unit_manager.end_path_check()
	enable_buttons()
	close_menu()

func _on_cancel_attack():
	enable_buttons()

func _on_wait_pressed():
	unit_manager.unit_wait(selected_unit)
	close_menu()

func _on_end_turn_pressed():
	game_manager.start_next_turn()
	close_menu()

func _on_cancel_pressed():
	close_menu()

func _on_cursor_show_actions(selected_unit, target_unit, x, y, last_x, last_y, can_move, can_attack, can_wait, can_end_turn):
	x_pos = x
	y_pos = y
	$".".last_x = last_x
	$".".last_y = last_y
	$".".selected_unit = selected_unit
	$".".target_unit = target_unit
	$".".can_move = can_move
	$".".can_attack = can_attack
	$".".can_wait = can_wait
	$".".can_end_turn = can_end_turn
	visible = true

func close_menu() -> void:
	visible = false
	cursor.in_menu = false

func disable_buttons():
	for button in buttons:
		if button is Control:
			button.disabled = true

func enable_buttons():
	for button in buttons:
		if button is Control:
			button.disabled = false
	focus_button()

func focus_button():
	for button in buttons:
			if button.visible:
				button.grab_focus()
				break
