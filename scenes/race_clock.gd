extends Control

var total_time := 0.0
var stopped = true

func _process(delta):
	if not stopped:
		total_time += delta

		var seconds = int(total_time)
		var milliseconds = int((total_time - seconds) * 100)

		$Label.text = "%02d:%02d" % [seconds, milliseconds]

func start_timer():
	stopped = false
	
func stop_timer():
	stopped = true
