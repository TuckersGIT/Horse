extends Control

@onready var fill_mask = $FillMask
@onready var background = $Background
@onready var horse_icon = $HorseIcon
@onready var fill = $FillMask/Fill

var finish_line
var horse
var start_x

func _ready():
	horse = get_tree().current_scene.get_node("Horse")
	finish_line = get_tree().current_scene.get_node("FinishLine")
	start_x = horse.global_position.x

func _process(_delta: float) -> void:
	if horse == null or finish_line == null:
		return

	var progress = inverse_lerp(
		start_x,
		finish_line.global_position.x,
		horse.global_position.x
	)

	progress = clamp(progress, 0.0, 1.0)

	var bar_height = background.size.y
	var new_height = bar_height * progress

	fill_mask.position.y = background.position.y + bar_height - new_height
	fill_mask.size.y = new_height

	fill.position.y = -fill_mask.position.y + background.position.y

	horse_icon.position.y = lerp(
		background.position.y + bar_height - horse_icon.size.y,
		background.position.y - horse_icon.size.y / 2.0  + 15,
		progress
	)
