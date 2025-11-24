class_name IdleState
extends MovementState
#
#@export
#var dash_state: State
@export
var dash_state : DashState
@export
var move_state: MovementState

func enter() -> void:
	super()
	moveAnimations.play("RESET")
	parent.can_dash = true
	

func process_input(event: InputEvent) -> MovementState:
	if get_movement_input_x() != 0.0:
		return move_state
	if get_movement_input_y() != 0.0:
		return move_state
	if Input.is_action_just_pressed('dash') && parent.num_of_dashes_available > 0:
		if parent.can_dash:
			return dash_state
	return null

func process_physics(delta: float) -> MovementState:
	parent.move_and_slide()

	return null
