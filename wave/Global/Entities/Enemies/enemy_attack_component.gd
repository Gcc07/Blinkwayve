class_name EnemyActionComponent
extends Node

# Return a boolean indicating if the character wants to attack
var normal_attack_timer: Timer = null
var should_normal_attack: bool = false

func _ready(): 
	# Create dash timer
	normal_attack_timer = Timer.new()
	normal_attack_timer.name = "AttackTimer"
	normal_attack_timer.one_shot = true
	normal_attack_timer.timeout.connect(_normal_attack_timer_timeout)
	add_child(normal_attack_timer)
	start_normal_attack_timer()

func get_action_input_as_string() -> String:
	if should_normal_attack:
		should_normal_attack = false
		return "normal_attack"
	return ""

func start_normal_attack_timer() -> void:
	if not normal_attack_timer:
		return
	# Random interval between 5-10 seconds
	var random_interval = randf_range(2.0, 5.0)
	normal_attack_timer.wait_time = random_interval
	normal_attack_timer.start()

func _normal_attack_timer_timeout() -> void:
	should_normal_attack = true
	# Restart timer for next dash
	start_normal_attack_timer()
