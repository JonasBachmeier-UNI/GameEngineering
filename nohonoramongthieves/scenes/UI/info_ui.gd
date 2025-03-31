extends Control

var selected_unit
var selected_unit_ui = load("res://scenes/UI/unit_info.tscn").instantiate()
var hovered_unit
var hovered_unit_ui = load("res://scenes/UI/unit_info.tscn").instantiate()
var container

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	container = $PanelContainer/OuterContainer
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_cursor_show_hovered_info(unit: Variant) -> void:
	if unit.get_instance_id() != selected_unit:
		hovered_unit = unit.get_instance_id()
		container.remove_child(hovered_unit_ui)
		container.add_child(hovered_unit_ui)
		hovered_unit_ui.update_stats(unit)
		if selected_unit != null:
			selected_unit_ui.add_border()

func _on_cursor_show_info(unit: Variant) -> void:
	selected_unit = unit.get_instance_id()
	selected_unit_ui.dmg = unit.dmg 
	selected_unit_ui.defense = unit.defense
	container.add_child(selected_unit_ui)
	container.remove_child(hovered_unit_ui)

func _on_cursor_remove_info() -> void:
	selected_unit = null
	container.remove_child(selected_unit_ui)
	
func _on_cursor_remove_hovered_info() -> void:
	hovered_unit = null
	selected_unit_ui.remove_border()
	container.remove_child(hovered_unit_ui)
