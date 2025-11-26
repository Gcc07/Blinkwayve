extends Label

const TIMER_LIMIT = 2.0
var timer = 0.0

func _process(delta):
	timer += delta
	if timer > TIMER_LIMIT: # Prints every 2 seconds
		timer = 0.0
		self.text = ("fps: " + str(Engine.get_frames_per_second()))
