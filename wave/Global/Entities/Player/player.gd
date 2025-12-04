class_name Player
extends Entity

var aim_position : Vector2 = Vector2(1, 0)

@onready
var attack_point : Node2D = $AttackPoint
@onready
var entity_sprite : Sprite2D = $Sprite2D
@onready
var move_animations: AnimationPlayer = $MoveAnimationPlayer
@onready
var action_animations: AnimationPlayer = $ActionAnimationPlayer

@onready
var movement_state_machine: Node = $MoveStateMachine
@onready
var action_state_machine: Node = $ActionStateMachine
@onready
var player_move_component = $PlayerMoveComponent
@onready
var player_action_component = $PlayerActionComponent

@onready
var num_of_dashes_available : int = 2
@onready
var hitbox = $Hitbox
@onready
var trail_particles: GPUParticles2D = $TrailParticles


func _ready() -> void:

	movement_state_machine.init(self, entity_sprite, move_animations, action_animations, player_move_component)
	action_state_machine.init(self, entity_sprite, move_animations, action_animations, player_action_component)


func _unhandled_input(event: InputEvent) -> void:

	if event is InputEventMouseMotion:
		var half_viewport = get_viewport_rect().size / 2
		aim_position = (event.position - half_viewport)

	movement_state_machine.process_input(event)
	if action_state_machine != null:
		action_state_machine.process_input(event)


func _physics_process(delta: float) -> void:

	movement_state_machine.process_physics(delta)
	if action_state_machine != null:
		action_state_machine.process_physics(delta)
	
	update_trail_emission()
	#const_wobble()


func _process(delta: float) -> void:
	# print("Movement: " + move_animations.current_animation, "       Action: " + action_animations.current_animation)
	# print("The attack is: " + attack_state_machine.current_state.name)

	movement_state_machine.process_frame(delta)
	if action_state_machine != null:
		action_state_machine.process_frame(delta)

## ----------------------------------- ##

signal damaged(attack: Attack)

func on_damaged(attack: Attack) -> void:
	damaged.emit(attack)

func on_health_changed(health: float) -> void:
	pass # Replace with function body.

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

#func const_wobble():
	#if self.velocity.x <= 80 and self.velocity.x >= -80:
		#player_sprite.rotation = 0
	#elif self.velocity.x >=  100 and player_sprite.rotation < .06:
		#player_sprite.rotation += .01 
	#elif self.velocity.x <= -100 and player_sprite.rotation > -.06:
		#player_sprite.rotation -= .01
