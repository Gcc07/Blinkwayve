class_name StunnedState
extends ActionState

# The State for when an Entity is stunned from an attack.

@export var none_state : ActionState
@export var stun_time : float = .2

@onready var stun_timer = Timer.new() 

func enter() -> void:
	super()
	stun_timer.start()
	parent.can_move = false
	parent.can_be_damaged = false
	actionAnimations.active = true
	moveAnimations.active = false
	if animation_name == "":
		actionAnimations.active = false
		sprite.material.set_shader_parameter("shade_color", Color(1.0, 1.0, 1.0))

func _ready(): 
	stun_timer.wait_time = stun_time
	stun_timer.one_shot = true 
	add_child(stun_timer)
	stun_timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout():
	parent.stunned = false

func process_physics(delta: float) -> ActionState:
	if not parent.alive:
		return death_state
	if not parent.stunned:
		if animation_name == "":
			sprite.material.set_shader_parameter("shade_color", Color(1.0, 1.0, 1.0, 0.0))
			actionAnimations.active = true
		parent.can_be_damaged = true
		return none_state
	else: 
		return null
