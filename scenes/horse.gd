extends Node2D

var speed = 0.0
var state = "wait_right"
var players = []
var current = 0
var time_since_press = 0.0
var deceleration = 80

var finish_line
var finished = false

@export var clops: Array[AudioStream] = []
@export var run_texture: Texture2D
@export var slide_texture: Texture2D


func _ready():
	players = [$Clop1,$Clop2,$Clop3]
	finish_line = get_parent().get_node("FinishLine")

func _process(delta: float) -> void:
		
	time_since_press += delta
	
	if not finished:
		if time_since_press > 0.75:
			$Sprite2D.texture = slide_texture
			rotation_degrees = 0
		else:
			$Sprite2D.texture = run_texture
	
	speed = max(speed,0)
	
	position.x += speed * delta
	
	if finished:
		speed = max(speed - speed * 3 * delta, 0) 
	else:
		speed = max(speed - deceleration * delta, 0)
		
	
	if speed > 20 and not finished:
		$DustParticles.emitting = true
		var dust_scale = clamp(1.0 + speed * 0.005, 0.25, 5.0)
		$DustParticles.scale_amount_min = dust_scale * 0.3
		$DustParticles.scale_amount_max = dust_scale * 1.5
	else:
		$DustParticles.emitting = false
	
	if not finished and position.x >= finish_line.position.x:
		finish_race()
	
func _input(event: InputEvent) -> void:
	if finished:
		return
		
	if event.is_action_pressed("left_arrrow"):
		if state == "wait_left":
			rotation_degrees = -15
			clop()
			state = "wait_right"
			time_since_press = 0.0
		else:
			speed -= 40
			
	if event.is_action_pressed("right_arrow"):
		if state == "wait_right":
			rotation_degrees = 15
			clop()
			speed += 50
			state = "wait_left"
			time_since_press = 0.0
		else:
			speed -= 40
			
func finish_race():
	finished = true
	rotation_degrees = 0
	
	get_parent().get_node("UI/RaceClock").stop_timer()
	
func clop():
	var c = clops[randi() % clops.size()]

	var p = players[current]
	current = (current + 1) % players.size()

	p.stream = c
	p.play()
