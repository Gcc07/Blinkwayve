class_name MoveState
extends MovementState

#@export
#var dash_state: State
@export
var idle_state: MovementState
@export
var dash_state: DashState

var move_dir_x := 0.0
var move_dir_y := 0.0
var smoothing_speed := 8.0 # Higher = snappier, lower = smoother

var current_speed = move_speed
var extra_speed_limit = 50
const MOVEMENT_THRESHOLD := 0.01 # Threshold for considering movement as stopped (accounts for floating point precision)

func process_input(event: InputEvent) -> MovementState:
	return null

func enter() -> void:
	parent.can_attack = true
	parent.can_dash = true
	current_speed = move_speed

func process_physics(delta: float) -> MovementState:
	# print(current_speed)
	# Speed capping and acceleration control
	var max_speed_after_acceleration = move_speed + extra_speed_limit
	if not current_speed >= max_speed_after_acceleration && get_movement_input_x() != 0 and get_movement_input_y() != 0:
		current_speed += 2

	if abs(get_movement_input_x()) < MOVEMENT_THRESHOLD and abs(get_movement_input_y()) < MOVEMENT_THRESHOLD:
		if current_speed > move_speed:
			current_speed -= 2
	
	move_dir_x = lerp(move_dir_x, get_movement_input_x(), delta * smoothing_speed)
	move_dir_y = lerp(move_dir_y, get_movement_input_y(), delta * smoothing_speed)
	# print(get_movement_input(), get_parent().get_parent().name) - Prints the axis of movement + the entity moving.
	
	# Smooth rotation based on movement direction
	rotate_sprite_towards_direction(move_dir_x, move_dir_y, delta)
	#sprite.flip_h = get_movement_input_x() > 0
	parent.velocity.x = move_dir_x * current_speed
	parent.velocity.y = move_dir_y * current_speed
	
	if parent.can_move:
		parent.move_and_slide()
	
	# Use threshold check instead of exact equality for lerped values
	if abs(move_dir_x) < MOVEMENT_THRESHOLD and abs(move_dir_y) < MOVEMENT_THRESHOLD:
		return idle_state
	if parent.can_move == false:
		return idle_state
	# Check for dash input from move_component
	if (move_component.has_method("get_dash") and move_component.get_dash() > 0):
		return dash_state
	return null
