class_name DashState
extends MovementState

@export var move_state : MoveState
@export var dash_time : float = .2 # Default
@onready var dash_finished : bool = false

var move_dir_x := 0.0
var move_dir_y := 0.0
var smoothing_speed := 10.0 # Higher = snappier, lower = smoother

func enter() -> void:
	
	super()
	moveAnimations.play("RESET")
	#parent.can_attack = false
	move_dir_x = get_movement_input_x()
	move_dir_y =get_movement_input_y()
	
	parent.can_be_damaged = false
	
	parent.velocity.x = 0
	#if moveAnimations != null and animation_name != "":
		#moveAnimations.active = false
	if moveAnimations != null and animation_name != "":
		moveAnimations.active = true
		moveAnimations.play(str(parent.entity_id)+"_Move_Animations/" + animation_name)
	dash_finished = false
	
	var dash_timer = Timer.new() 
	dash_timer.wait_time = dash_time
	dash_timer.one_shot = true 
	add_child(dash_timer)
	dash_timer.timeout.connect(_on_timer_timeout)
	dash_timer.start()

func _on_timer_timeout():
	dash_finished = true
	get_child(0).queue_free()

func process_physics(delta: float) -> State:
	# Smooth rotation based on movement direction
	var smoothed_x = lerp(move_dir_x, get_movement_input_x(), delta * smoothing_speed)
	var smoothed_y = lerp(move_dir_y, get_movement_input_y(), delta * smoothing_speed)

	if get_movement_input_x() != 0 and get_movement_input_y() != 0:
		rotate_sprite_towards_direction( smoothed_x, smoothed_y, delta)

	parent.velocity.x = smoothed_x * move_speed
	parent.velocity.y = smoothed_y * move_speed
	parent.move_and_slide()
	if dash_finished:
		parent.can_be_damaged = true
		parent.can_attack = true
		return move_state
	else: 
		return null
