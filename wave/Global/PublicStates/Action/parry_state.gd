class_name ParryState
extends ActionState

# The State for when an Entity is parrying an attack

@export var none_state : ActionState
@export var parry_time : float = .2 # Default
@onready var parry_finished : bool = false


func enter() -> void:
	moveAnimations.active = false
	actionAnimations.active = true
	actionAnimations.play(str(parent.entity_id)+"Action/" + animation_name)
	parry_finished = false
	var parry_timer = Timer.new() 
	parry_timer.wait_time = parry_time
	parry_timer.one_shot = true 
	add_child(parry_timer)
	parry_timer.timeout.connect(_on_timer_timeout)
	parry_timer.start()
	parent.can_move = false
	parent.parrying = true
	
	

func _on_timer_timeout():
	get_child(0).queue_free()
	parry_finished = true
	parent.parrying = false


func process_physics(delta: float) -> ActionState:
	if parry_finished:
		return none_state
	else: 
		return null
