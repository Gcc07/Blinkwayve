class_name StunnedState
extends ActionState

# The State for when an Entity is stunned from an attack.

@export var none_state : ActionState
@export var stun_time : float = .2

var stun_timer : Timer

func enter() -> void:
	super()
	
	# Create and configure timer
	stun_timer = Timer.new()
	stun_timer.wait_time = stun_time
	stun_timer.one_shot = true
	add_child(stun_timer)
	stun_timer.timeout.connect(_on_timer_timeout)
	stun_timer.start()
	
	# Set entity state
	parent.can_move = false
	parent.can_be_damaged = false
	actionAnimations.active = true
	moveAnimations.active = false
	
	# Handle visual effect if no animation
	if animation_name == "":
		actionAnimations.active = false
		sprite.material.set_shader_parameter("shade_color", Color(1.0, 1.0, 1.0))

func exit() -> void:
	# Clean up timer if still exists
	if stun_timer and is_instance_valid(stun_timer):
		stun_timer.queue_free()
		stun_timer = null
	
	# Reset visual effect if no animation was used
	if animation_name == "":
		sprite.material.set_shader_parameter("shade_color", Color(1.0, 1.0, 1.0, 0.0))
	
	# Restore entity state
	parent.can_be_damaged = true

func _on_timer_timeout():
	parent.stunned = false

func process_physics(delta: float) -> ActionState:
	if not parent.alive:
		return death_state
	
	# Check if stun has been cleared (by timer or externally)
	if not parent.stunned:
		return none_state
	
	return null
