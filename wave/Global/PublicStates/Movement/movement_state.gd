class_name MovementState
extends State

var move_component

@export var move_speed: float = 150
## Rotation speed in radians per second. Higher = faster rotation.
@export var rotation_speed: float = 5.0
## Rotation smoothing factor. Higher = snappier, lower = smoother.
@export var rotation_smoothing: float = 8.0
## Base rotation offset in radians (useful for sprite orientation)
@export var rotation_offset: float = 0.0

var current_rotation: float = 0.0

func enter() -> void:
	# Initialize rotation from current sprite rotation to prevent jumps
	current_rotation = sprite.rotation
	if moveAnimations != null and animation_name != "": 
		moveAnimations.play(str(parent.entity_id)+"_Move_Animations/" + animation_name)

## Smoothly rotates sprite towards target angle based on movement direction
func rotate_sprite_towards_direction(move_x: float, move_y: float, delta: float) -> void:
	if move_x == 0.0 and move_y == 0.0:
		# When not moving, smoothly return to base rotation
		var target_rotation = rotation_offset
		current_rotation = lerp_angle(current_rotation, target_rotation, delta * rotation_smoothing)
		sprite.rotation = current_rotation
		return
	
	# Calculate target angle from movement direction
	var target_angle = atan2(move_y, move_x) + rotation_offset
	
	# Smoothly rotate towards target angle
	current_rotation = lerp_angle(current_rotation, target_angle, delta * rotation_smoothing)
	sprite.rotation = current_rotation

## Legacy function for backwards compatibility (deprecated)
func rotate_sprite(amount: int):
	sprite.rotate(amount)

func get_movement_input_x() -> float:
	if parent.can_move:
		return move_component.get_movement_direction_x()
	return 0.0
func get_movement_input_y() -> float:
	if parent.can_move:
		return move_component.get_movement_direction_y()
	return 0.0
