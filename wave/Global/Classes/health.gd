class_name Health
extends Node

# Component script that controls the health of an Entity.

signal health_changed(health: float)

@export var hitbox : Hitbox
@export var max_health := 10.0
@onready var health := max_health

@onready var thing_being_attacked : Entity = get_owner()
## Weird name, but "thing_being_attacked" just applies so all entities can
## be assigned this node.

func _ready():
	if hitbox:
		hitbox.damaged.connect(on_damaged)

func on_damaged(attack: Attack):
	print("attacked: Health: ", attack.damage, " damage")
	if !thing_being_attacked.alive:
		return
	if !thing_being_attacked.can_be_damaged:
		return
	health -= attack.damage
	health_changed.emit(health)
	if attack.stuns:
		thing_being_attacked.stunned = true
	if health <= 0:
		health = 0
		thing_being_attacked.alive = false
