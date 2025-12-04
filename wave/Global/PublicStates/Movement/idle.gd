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
	# Check for dash input from either Input or move_component
	var dash_input
	if move_component.has_method("get_dash"):
		dash_input = (move_component.get_dash() > 0)
	
	if dash_input:
		# Check dash availability (for player) or just can_dash (for enemies)
		var can_use_dash = true
		if "num_of_dashes_available" in parent:
			can_use_dash = parent.num_of_dashes_available > 0
		
		if parent.can_dash and can_use_dash:
			return dash_state
	return null

func process_physics(delta: float) -> MovementState:
	parent.velocity.x = 0
	parent.velocity.y = 0
	if parent.alive and parent.can_move:
		parent.move_and_slide()
	
	# Check for dash input from either Input or move_component
	var dash_input
	if move_component.has_method("get_dash"):
		dash_input = (move_component.get_dash() > 0)
	
	if dash_input:
		# Check dash availability (for player) or just can_dash (for enemies)
		var can_use_dash = true
		if "num_of_dashes_available" in parent:
			can_use_dash = parent.num_of_dashes_available > 0
		
		if parent.can_dash and can_use_dash:
			return dash_state

	return null
