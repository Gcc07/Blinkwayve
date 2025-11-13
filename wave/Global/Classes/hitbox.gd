class_name Hitbox 
extends Area2D

# Hitbox component - this gets hit by the Projectile's hurtbox.

signal damaged(attack: Attack)

func damage(attack: Attack):
	print("attacked: " + get_parent().entity_id +  " Hitbox")
	damaged.emit(attack)
