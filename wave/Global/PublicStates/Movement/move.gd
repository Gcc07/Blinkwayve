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

func process_input(event: InputEvent) -> MovementState:
	#if Input.is_action_just_pressed('dash'):
		#return dash_state
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

	if get_movement_input_x() == 0 and get_movement_input_y() == 0:
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
	parent.move_and_slide()
	
	if move_dir_x == 0 and move_dir_y == 0 :
		return idle_state
	if parent.can_move == false:
		return idle_state
	# Check for dash input from either Input or move_component
	if (move_component.has_method("get_dash") and move_component.get_dash() > 0):
		return dash_state
	return null
