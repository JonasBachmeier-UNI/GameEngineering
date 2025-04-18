extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_start_button_pressed() -> void:
	SceneManager.NextScene()


func _on_tutorial_button_pressed() -> void:
	$Panel.visible = true
	var tutorial_scene = load("res://scenes/UI/tutorial_menu.tscn").instantiate()
	add_child(tutorial_scene)
