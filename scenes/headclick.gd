extends Area2D


func _input_event(_viewport, event, _shape_idx):
		if event is InputEventMouseButton:
			if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				$"../Hat".visible = not $"../Hat".visible
				$"../../Players/HONK".play()
				
				
