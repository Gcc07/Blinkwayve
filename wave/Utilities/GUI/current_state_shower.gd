extends Label

func _physics_process(delta: float) -> void:
	self.text = get_parent().current_state
