extends Node2D

var speed = 0.0
var state = "wait_right"
var players = []
var current = 0

@export var clops: Array[AudioStream] = []

func _ready():
	players = [$Clop1,$Clop2,$Clop3]

func _process(delta: float) -> void:
	speed = max(speed,0)
	
	position.x += speed * delta
	
	speed = max(speed - 10 * delta, 0)

	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_arrrow"):
		if state == "wait_left":
			rotation_degrees = -15
			clop()
			state = "wait_right"
		else:
			speed -= 20
			
	if event.is_action_pressed("right_arrow"):
		if state == "wait_right":
			rotation_degrees = 15
			clop()
			speed += 50
			state = "wait_left"
		else:
			speed -= 20
			
func clop():
	var c = clops[randi() % clops.size()]

	var p = players[current]
	current = (current + 1) % players.size()

	p.stream = c
	p.play()
