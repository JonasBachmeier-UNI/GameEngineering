extends AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func attack(direction):
	if direction == "up":
		play("AttackUp")
	elif direction == "down":
		play("AttackDown")
	elif direction == "left":
		play("AttackLeft")
	elif direction == "right":
		play("AttackRight")
