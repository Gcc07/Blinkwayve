class_name MovementState
extends State

var move_component

@export var move_speed: float = 150

func enter() -> void:
	if moveAnimations != null: 
		moveAnimations.play(str(parent.entity_id)+"Move/" + animation_name)
	

func get_movement_input_x() -> float:
	if parent.can_move:
		return move_component.get_movement_direction_x()
	return 0.0
func get_movement_input_y() -> float:
	if parent.can_move:
		return move_component.get_movement_direction_y()
	return 0.0
