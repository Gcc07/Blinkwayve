class_name NoneState
extends ActionState

# The State for when an Entity has no current actions.

@export_group("Action States")
@export var action_states: Array[ActionState]

var parry_state : ActionState

func enter() -> void:
	parent.can_dash = true
	parent.can_attack = true
	parent.can_move = true
	if actionAnimations != null:
		actionAnimations.active = false
	if moveAnimations != null: 
		moveAnimations.active = true

func _on_hitbox_damaged(attack: Attack):
	if attack.stuns == true:
		parent.stunned = true

func process_physics(delta: float) -> ActionState:
	for action in action_states:
		# print(get_action_input_as_string())
		# print(get_action_input_as_string(), " ", action.action_name)
		if get_action_input_as_string() == action.action_name:
			return action

	if parent.stunned:
		return stunned_state
	if not parent.alive:
		return death_state

	return null
