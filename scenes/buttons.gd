extends Control

@export var left_unpressed: Texture2D
@export var left_pressed: Texture2D

@export var right_unpressed: Texture2D
@export var right_pressed: Texture2D

func _process(_delta: float) -> void:
	if Input.is_action_pressed("left_arrrow"):
		$"Left-Arrow".texture = left_pressed
	else:
		$"Left-Arrow".texture = left_unpressed
		
	if Input.is_action_pressed("right_arrow"):
		$"Right-Arrow".texture = right_pressed
	else:
		$"Right-Arrow".texture = right_unpressed
