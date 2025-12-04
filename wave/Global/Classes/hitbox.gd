class_name Hitbox 
extends Area2D

# Hitbox component - this gets hit by the Projectile's hurtbox.

signal damaged(attack: Attack)

## If true, only the ring/outline of the circle will trigger hits, not the filled area
@export var is_ring : bool = false
## Inner radius of the ring (only used if is_ring is true). Objects closer than this won't trigger.
@export var ring_inner_radius : float = 0.0
## Outer radius of the ring (only used if is_ring is true). Objects further than this won't trigger.
@export var ring_outer_radius : float = 50.0

func damage(attack: Attack):
	print("attacked: " + get_parent().entity_id +  " Hitbox")
	damaged.emit(attack)

## Check if a position is within the ring (between inner and outer radius)
func is_position_in_ring(position: Vector2) -> bool:
	if not is_ring:
		return true  # If not a ring, always return true (normal behavior)
	
	var distance_from_center = global_position.distance_to(position)
	return distance_from_center >= ring_inner_radius and distance_from_center <= ring_outer_radius
