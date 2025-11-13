class_name DashState
extends MovementState

func enter() -> void:
	super()
	parent.velocity.x = 0
