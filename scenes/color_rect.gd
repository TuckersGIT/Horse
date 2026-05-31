extends ColorRect

var palette_index := 0
@onready var palette_button = $"../../UI/PaletteButton"

@export var bwomps: Array[AudioStream] = []
@onready var player = $"../../UI_Sounds"

var palettes := [
	[
		Vector3(0.10, 0.16, 0.10),
		Vector3(0.24, 0.35, 0.18),
		Vector3(0.50, 0.62, 0.30),
		Vector3(0.78, 0.84, 0.52),
	],
	[
		Vector3(0.08, 0.08, 0.12),
		Vector3(0.25, 0.20, 0.35),
		Vector3(0.55, 0.45, 0.65),
		Vector3(0.90, 0.80, 1.00),
	],
	[
		Vector3(0.153, 0.153, 0.153),
		Vector3(0.33, 0.33, 0.33),
		Vector3(0.6, 0.6, 0.6),
		Vector3(0.85, 0.85, 0.85),
	],
	[
		Vector3(0.12, 0.06, 0.04),
		Vector3(0.35, 0.16, 0.08),
		Vector3(0.70, 0.42, 0.18),
		Vector3(1.00, 0.78, 0.42),
	],
	[  
		Vector3(0.176, 0.114, 0.145),
		Vector3(0.411, 0.24, 0.33),
		Vector3(0.761, 0.443, 0.609),
		Vector3(1.00, 0.678, 0.843),
	]
]

func _ready():
	palette_button.pressed.connect(cycle_palette)
	apply_palette()

func _input(event):
	if event.is_action_pressed("cycle_palette"):
		cycle_palette()

func apply_palette():
	var p = palettes[palette_index]

	material.set_shader_parameter("c1", p[0])
	material.set_shader_parameter("c2", p[1])
	material.set_shader_parameter("c3", p[2])
	material.set_shader_parameter("c4", p[3])
	
func cycle_palette():
	player.stream = bwomps.pick_random()
	player.play()
	palette_index = (palette_index + 1) % palettes.size()
	apply_palette()
