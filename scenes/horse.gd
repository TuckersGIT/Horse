extends Node2D

var speed = 0.0
var state = "wait_right"
var players = []
var current = 0
var time_since_press = 0.0
var deceleration = 80

var finish_line
var finished = false
var race_started = false
var countdown_started = false

@export var clops: Array[AudioStream] = []
@export var run_texture: Texture2D
@export var slide_texture: Texture2D

@export var run_hat: Texture2D
@export var slide_hat: Texture2D



func _ready():
	players = [$Players/Clop1,$Players/Clop2,$Players/Clop3]
	finish_line = get_parent().get_node("FinishLine")
	$StartTimer.timeout.connect(start_race)
	

func _process(delta: float) -> void:
		
	time_since_press += delta
	
	if not finished and race_started:
		if time_since_press > 0.75:
			$Sprite2D.texture = slide_texture
			$Hat.texture = slide_hat
			rotation_degrees = 0
		else:
			$Sprite2D.texture = run_texture
			$Hat.texture = run_hat
	
	speed = max(speed,0)
	
	position.x += speed * delta
	position = position.round()
	
	$Camera2D.global_position = $Camera2D.global_position.round()
	
	if finished:
		speed = max(speed - speed * 3 * delta, 0) 
	else:
		speed = max(speed - deceleration * delta * max(time_since_press * 1.25 ,1), 0)
		
	
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
	if event.is_action_pressed("space") and not race_started and not countdown_started:
		countdown_started = true
		$Players/StartRace.play()
		$StartTimer.start()
		return
		
	if finished or not race_started:
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
			
func start_race():
	time_since_press = 0.0
	race_started = true
	get_parent().get_node("UI/RaceClock").start_timer()

func finish_race():
	finished = true
	rotation_degrees = 0
	
	get_parent().get_node("UI/RaceClock").stop_timer()
	var finalTime = get_parent().get_node("UI/RaceClock").get_Time()
	finalTime = floor(finalTime * 100) / 100.0
	
	$Players/HorseNoises.play()
	$Players/Popoff.play()
	
	get_parent().get_node("UI/Leaderboard").add_score(finalTime)

	
func clop():
	var c = clops[randi() % clops.size()]

	var p = players[current]
	current = (current + 1) % players.size()

	p.stream = c
	p.play()
