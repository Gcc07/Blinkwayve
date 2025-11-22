class_name AttackState
extends ActionState

@export var allow_movement : bool = false
@export var none_state : ActionState
@export var attack_projectile_resource : ProjectileResource

#@export
#var sound : SoundEffect.SOUND_EFFECT_TYPE

@onready var finished_attack : bool = false

var projectile : PackedScene = preload("uid://be3mpsirj8rwt")

# Pass the inputs from the action components into the sub-states

func get_action_input_as_string() -> String:
	return action_component.get_attack_input()

func enter() -> void:
	parent.can_dash = false
	spawn_corresponding_projectile()
	# Overwriting the enter statements in the action state
	if not parent.hitbox.is_connected("damaged", _on_hitbox_damaged): # If the hitbox isn't connected,
		parent.hitbox.damaged.connect(_on_hitbox_damaged) # Connect it.

	parent.can_move = allow_movement
	finished_attack = false
	if moveAnimations != null and animation_name != "":
		moveAnimations.active = false
	if actionAnimations != null and animation_name != "":
		actionAnimations.active = true
		actionAnimations.play(str(parent.entity_id)+"_Action_Animations/" + animation_name)
	if animation_name == "":
		attack_finished()


func exit() -> void:
	if actionAnimations != null:
		actionAnimations.active = false

func process_physics(delta: float) -> ActionState:
	if not parent.alive:
		return death_state
	# print(self.name)
	if parent.stunned:
		return stunned_state
	if finished_attack:
		return none_state
	else:
		return null

func process(delta: float) -> ActionState:
	return null

func attack_finished():
	finished_attack = true

func spawn_corresponding_projectile():
	
	projectile.resource_local_to_scene = true
	## The instantiated projectile being spawned in the function.
	var spawned_projectile : = projectile.instantiate() # Instantiates the projectile created by player light attack.
	spawned_projectile.projectile_resource = attack_projectile_resource
	if sprite.flip_h == false: #   IF THE ENTITY IS FACING RIGHT
		spawned_projectile.projectile_resource.scale_factor.x = spawned_projectile.projectile_resource.scale_factor.x * 1
		#print("projectile scale: should be 1, is ", spawned_projectile.scale.x)
	elif sprite.flip_h == true: # IF THE ENTITY IS FACING LEFT       
		spawned_projectile.projectile_resource.scale_factor.x = spawned_projectile.projectile_resource.scale_factor.x * -1  
		#print("projectile scale: should be -1, is ", spawned_projectile.scale.x)
	#print(spawned_projectile.scale.x)
	if spawned_projectile.projectile_resource.stick_to_parent == true: # If the projectile is a slash or similarly behaving
		spawned_projectile.global_position = parent.attack_point.position + Vector2(spawned_projectile.projectile_resource.parent_offset.x * spawned_projectile.scale.x, spawned_projectile.projectile_resource.parent_offset.y)# Sets the position of the projectile
		parent.add_child(spawned_projectile)

	elif spawned_projectile.projectile_resource.stick_to_parent == false:
		spawned_projectile.global_position = parent.attack_point.global_position + Vector2(spawned_projectile.projectile_resource.parent_offset.x * spawned_projectile.scale.x, spawned_projectile.projectile_resource.parent_offset.y)# Sets the position of the projectile
		#get_tree().root.add_child(spawned_projectile) # If the projectile is moving. (like a bullet, or energy blast)
		parent.get_parent().add_child(spawned_projectile)
