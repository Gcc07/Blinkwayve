class_name Enemy
extends Entity

@onready
var attack_point = $AttackPoint

@onready
var hitbox : Hitbox = $Hitbox
@onready
var enemy_sprite : Sprite2D = $Sprite2D
@onready
var move_animations: AnimationPlayer = $MoveAnimationPlayer
@onready
var action_animations: AnimationPlayer = $ActionAnimationPlayer

@onready
var movement_state_machine: Node = $MoveStateMachine
@onready
var action_state_machine: Node = $ActionStateMachine
@onready
var enemy_move_component : Node = $EnemyMoveComponent
@onready
var enemy_action_component : Node = $EnemyActionComponent

@export_group("Enemy AI Properties")
@export
var AI_notice_radius := 60.0
@export 
var AI_pursue_radius := 100.0

@export var hostile := true

func _ready() -> void:

	movement_state_machine.init(self, enemy_sprite, move_animations, action_animations, enemy_move_component)
	action_state_machine.init(self, enemy_sprite, move_animations, action_animations, enemy_action_component)


func _unhandled_input(event: InputEvent) -> void:

	movement_state_machine.process_input(event)
	action_state_machine.process_input(event)


func _physics_process(delta: float) -> void:

	movement_state_machine.process_physics(delta)
	action_state_machine.process_physics(delta)
	#const_wobble()


func _process(delta: float) -> void:

	# print("Movement: " + move_animations.current_animation, "       Action: " + action_animations.current_animation)
	# print("The attack is: " + attack_state_machine.current_state.name)

	movement_state_machine.process_frame(delta)
	action_state_machine.process_frame(delta)
