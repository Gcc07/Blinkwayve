extends Label

func _physics_process(delta: float) -> void:
	var parent = get_parent()
	var current_action_state
	var current_movement_state
	var children = get_parent().get_children()
	for child in children:
		if child is MovementStateMachine:
			current_movement_state = child
		if child is ActionStateMachine:
			current_action_state = child
	var action_name = current_action_state.current_state.name if current_action_state and current_action_state.current_state else "null"
	var movement_name = current_movement_state.current_state.name if current_movement_state and current_movement_state.current_state else "null"
	var entity_damageable : String
	self.text = "current action: " + action_name + "\n" + "current movement: " + movement_name + "\n" + entity_damageable
