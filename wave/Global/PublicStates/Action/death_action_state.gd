class_name DeathState
extends AttackState

func enter() -> void:
	parent.velocity.x = 0
	parent.velocity.y = 0

	parent.can_move = false
	parent.can_attack = false
	if immediate_projectiles:
		spawn_corresponding_projectiles()

	moveAnimations.active = false
	if actionAnimations != null and animation_name != "":
		actionAnimations.active = true
		actionAnimations.play(str(parent.entity_id)+"_Action_Animations/" + animation_name)

func process_physics(delta: float) -> ActionState:
	# only return null after death.
	return null

func kill():
	parent.queue_free()
