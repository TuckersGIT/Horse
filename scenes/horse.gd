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

var first_words = load_word_list("res://assets/Names/first.txt")
var second_words = load_word_list("res://assets/Names/second.txt")
var horse_name := ""

var carrot_scene = preload("res://scenes/carrot.tscn")
var carrot = null
var num_eated = 0
@onready var horse_noises = $Players/HorseNoises
@export var neigh_sound: AudioStream
@export var crunch_sound: Array[AudioStream] = []
@export var explode_sound: AudioStream
var is_exploded = false

func _ready():
	players = [$Players/Clop1,$Players/Clop2,$Players/Clop3]
	finish_line = get_parent().get_node("FinishLine")
	$StartTimer.timeout.connect(start_race)
	horse_name = nameTag()
	
func _process(delta: float) -> void:
	
	if carrot != null:
		carrot.global_position = get_global_mouse_position()
		
	time_since_press += delta
	
	if not finished and race_started:
		if time_since_press > 0.75:
			$Sprite2D.texture = slide_texture
			$Sprite2D/Hat.texture = slide_hat
			$Sprite2D.rotation_degrees = 0
		else:
			$Sprite2D.texture = run_texture
			$Sprite2D/Hat.texture = run_hat
	
	speed = max(speed,0)
	
	position.x += speed * delta
	position = position.round()
	
	$Camera2D.global_position = $Camera2D.global_position.round()
	
	if finished:
		speed = max(speed - speed * 3 * delta, 0) 
	else:
		speed = max(speed - deceleration * delta * max(time_since_press * 1.25 ,1), 0)
		
	
	if speed > 20 and not finished:
		$Sprite2D/DustParticles.emitting = true
		var dust_scale = clamp(1.0 + speed * 0.005, 0.25, 5.0)
		$Sprite2D/DustParticles.scale_amount_min = dust_scale * 0.3
		$Sprite2D/DustParticles.scale_amount_max = dust_scale * 1.5
	else:
		$Sprite2D/DustParticles.emitting = false
	
	if not finished and position.x >= finish_line.position.x:
		finish_race()
	
func _input(event: InputEvent) -> void:
	
	#if event is InputEventKey and event.echo:
		#return
	
	if is_exploded:
		return
	
	if event.is_action_pressed("Carrot"):
		if carrot == null:
			carrot = carrot_scene.instantiate()
			get_tree().current_scene.add_child(carrot)
			carrot.global_position = get_global_mouse_position()
	
	if event.is_action_pressed("space") and not race_started and not countdown_started:
		countdown_started = true
		$Players/StartRace.play()
		$StartTimer.start()
		return
	
	if event.is_action_pressed("space") and finished:
		get_parent().get_node("UI/Leaderboard").hide_board()
		

		
	if finished or not race_started:
		return
		
	if event.is_action_pressed("left_arrrow"):
		if state == "wait_left":
			$Sprite2D.rotation_degrees = -15
			clop()
			state = "wait_right"
			time_since_press = 0.0
		else:
			speed -= 40
			
	if event.is_action_pressed("right_arrow"):
		if state == "wait_right":
			$Sprite2D.rotation_degrees = 15
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
	$Sprite2D.rotation_degrees = 0
	
	get_parent().get_node("UI/RaceClock").stop_timer()
	var finalTime = get_parent().get_node("UI/RaceClock").get_Time()
	finalTime = floor(finalTime * 100) / 100.0
	
	play_horse_noise(neigh_sound)
	$Players/Popoff.play()
	
	get_parent().get_node("UI/Leaderboard").add_score(finalTime, horse_name)
	
	await get_tree().create_timer(1).timeout
	get_parent().get_node("UI/Leaderboard").visible = true
	
func clop():
	var c = clops[randi() % clops.size()]

	var p = players[current]
	current = (current + 1) % players.size()

	p.stream = c
	p.play()

func load_word_list(path: String) -> Array:
	var file = FileAccess.open(path, FileAccess.READ)
	
	if file == null:
		return []
		
	var text = file.get_as_text()
	
	return text.split("\n", false)
	
func generate_name() -> String:
	var first = first_words.pick_random().strip_edges()
	var second = second_words.pick_random().strip_edges()
	
	return (first + " " + second)
	
func nameTag() -> String:
	var new_name = generate_name()
	$NameTag/Name.text = new_name
	var label = $NameTag/Name
	var panel = $NameTag/Panel
	
	var text_size = label.get_theme_font("font").get_string_size(
		label.text,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		label.get_theme_font_size("font_size")
	)
	
	label.size = text_size
	panel.size = text_size + Vector2(16,8)

	label.position.x = -label.size.x / 2.0
	panel.position.x = label.position.x - 8
	panel.position.y = label.position.y - 4

	return new_name
	

func _on_mouth_area_entered(area: Area2D) -> void:
	if area.name == "carrot":
		var particles = area.get_node("CPUParticles2D")
		
		particles.reparent(get_tree().current_scene)
		particles.global_position = $Sprite2D/Mouth/CollisionShape2D.global_position + Vector2(0,17)
		particles.emitting = true
		
		area.queue_free()
		num_eated += 1
		
		play_horse_noise(crunch_sound)
		carrot = null
		
		if num_eated >= 10:
			var explosion = $CPUParticles2D
			$Sprite2D.visible = false
			$NameTag.visible = false
			is_exploded = true
			speed = 0.0
			play_horse_noise(explode_sound)
			explosion.emitting = true
			get_parent().get_node("UI/RaceClock").stop_timer()
			get_parent().get_node("UI/RaceClock").dq()
		
		await particles.finished
		particles.queue_free()
		
func play_horse_noise(sound):
	if sound is Array:
		horse_noises.stream = sound.pick_random()
	else:
		horse_noises.stream = sound
	
	horse_noises.play()
		
