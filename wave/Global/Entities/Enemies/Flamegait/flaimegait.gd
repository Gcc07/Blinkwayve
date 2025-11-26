class_name Flamegait
extends Enemy

@onready
var trail_particles: GPUParticles2D = $TrailParticles

signal damaged(attack: Attack)

func on_damaged(attack: Attack) -> void:
	print("Going through: Enemy")
	damaged.emit(attack)

func _physics_process(delta: float) -> void:

	super(delta)
	update_trail_emission()
	#const_wobble()

func update_trail_emission() -> void:
	if not trail_particles:
		return
	
	if not movement_state_machine:
		return
	
	var current_state = movement_state_machine.current_state
	var should_emit = false
	
	if current_state != null:
		if current_state is DashState:
			should_emit = true
	else:
		# Fallback: check velocity if state is not available
		if velocity.length() > 10.0:
			should_emit = true
	
	trail_particles.emitting = should_emit
