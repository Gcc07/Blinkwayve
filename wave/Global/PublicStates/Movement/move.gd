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
var smoothing_speed := 5.0 # Higher = snappier, lower = smoother

func process_input(event: InputEvent) -> MovementState:
	#if Input.is_action_just_pressed('dash'):
		#return dash_state

	return null

func process_physics(delta: float) -> MovementState:
	move_dir_x = lerp(move_dir_x, get_movement_input_x(), delta * smoothing_speed)
	move_dir_y = lerp(move_dir_y, get_movement_input_y(), delta * smoothing_speed)
	# print(get_movement_input(), get_parent().get_parent().name) - Prints the axis of movement + the entity moving.
	rotate_sprite((get_movement_input_x()/10 - get_movement_input_y()/10)/delta)
	sprite.flip_h = get_movement_input_x()  > 0
	parent.velocity.x = move_dir_x * move_speed
	parent.velocity.y = move_dir_y * move_speed
	parent.move_and_slide()
	
	if move_dir_x == 0 and move_dir_y == 0 :
		return idle_state
	if parent.can_move == false:
		return idle_state
	return null

func rotate_sprite(amount: int):
	sprite.rotate(amount)
