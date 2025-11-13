class_name PlayerMoveComponent
extends Node

# Component that returns information on Player movement input.

# Return the desired direction of movement for the character
# in the range [-1, 1], where positive values indicate a desire
# to move to the right and negative values to the left.

func get_movement_direction_x() -> float:
	var target_x = Input.get_axis("move_left", "move_right")
	return target_x

func get_movement_direction_y() -> float:
	var target_y = Input.get_axis("move_up", "move_down")
	return target_y
	
func get_dash() -> float:
	return Input.is_action_just_pressed("dash")
