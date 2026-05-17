extends Control

@onready var labels = [
	$VBoxContainer/Label,
	$VBoxContainer/Label2,
	$VBoxContainer/Label3
]

var save_path := "user://leaderboard.save"

func _ready():
	update_board()

func add_score(score: float, horse_name: String):
	var scores = load_scores()

	scores.append({"time": score, "name": horse_name})
	
	scores.sort_custom(func(a,b): return a["time"] < b["time"])
	scores = scores.slice(0, 3)

	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(scores)
	file.close()

	update_board()

func load_scores() -> Array:
	if not FileAccess.file_exists(save_path):
		return []

	var file = FileAccess.open(save_path, FileAccess.READ)

	if file == null:
		return []

	if file.get_length() < 4:
		return []

	var data = file.get_var()

	if data is Array:
		return data

	return []

func update_board():
	var scores = load_scores()

	for i in range(labels.size()):
		if i < scores.size():
			labels[i].text = str(i + 1) + ". " + str(scores[i]["name"] + " - " + str(scores[i]["time"]))
		else:
			labels[i].text = str(i + 1) + ". ---"
			
