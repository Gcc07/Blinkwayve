class_name PlayerActionComponent
extends Node

# Return a boolean indicating if the character wants to attack

func get_action_input_as_string() -> String:
	
	if Input.is_action_just_pressed("normal_attack"):
		return "normal_attack"
	if Input.is_action_just_pressed("charge_attack"):
		return "charge_attack"
	if Input.is_action_just_pressed("parry"):
		return "parry"
	if Input.is_action_just_pressed("dash_attack"):
		return "dash_attack"
	return ""
