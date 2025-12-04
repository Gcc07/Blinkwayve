class_name Hurtbox
extends Area2D

# Script that controls the hurtbox of an Entity.

signal hit_target

@onready var projectile : Projectile = get_owner() # Get the owner of this 
# hurtbox, being the Projectile to which the hurtbox is assigned

func _ready() -> void:
	area_entered.connect(on_area_entered)

func on_area_entered(area: Area2D):
	if area is Hitbox:
		var hitbox : Hitbox = area as Hitbox
		# Check if this is a ring hitbox and if we're within the ring
		if hitbox.is_ring:
			if not hitbox.is_position_in_ring(global_position):
				return  # Not within the ring, don't trigger
		
		var attack := Attack.new()
		attack.damage = projectile.projectile_resource.damage
		attack.stuns = projectile.projectile_resource.stuns
		area.damage(attack)
		# print("Projectile has hit the target:" + area.get_parent().name)
		hit_target.emit()
