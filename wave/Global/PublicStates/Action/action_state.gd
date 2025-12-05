class_name ActionState
extends State

# These two are exported because child states will always need acess to them.
@export
var death_state : ActionState
@export
var stunned_state : ActionState
@export
var action_name : String

var action_component

func enter() -> void:
	if actionAnimations != null and animation_name != "":
		actionAnimations.active = true
		actionAnimations.play(str(parent.entity_id)+"_Action_Animations/" + animation_name)

func _on_hitbox_damaged(attack: Attack):
	# Stun is handled by Health component, no need to set it here
	pass

# Pass the inputs from the action components into the sub-states

func get_action_input_as_string() -> String:
	return action_component.get_action_input_as_string()

func spawn_fx():
	pass
	
