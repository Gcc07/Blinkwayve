class_name ProjectileResource
extends Resource

@export_group("Projectile Properties")
## Projectile name
@export var ID := ""
## Is the projectile static.(Does it stay by the entity that created it)
@export var stick_to_parent := false
## Is the projectile player friendly.
@export var is_friendly := true
## The amount of damage the Projectile deals.
@export var damage := 5.0
## Does the projectile stun its target?
@export var stuns := true
## The maximum amount of Entities the projectile can pierce
@export var max_pierce := 1
## Amount of time a projectile has before it dissapears.
@export var time_to_live := .1 
## Shape of the collision area.
@export var collision_shape : Shape2D
## Shape of the hurtbox area.
@export var hurtbox_shape : Shape2D
## If you want to rotate the projectile collision shape.
@export var rotate_collision_shape : float = 0
## If you want to rotate the projectile collision shape.
@export var rotate_hurtbox_shape : float = 0
## Determines if the collision size will be the size of the sprite or not
@export var collision_size_corresponds_to_sprite := true 
## Determines if the hurtbox size will be the size of the sprite or not
@export var hurtbox_size_corresponds_to_sprite := true 
## Determines if the projectile breaks upon collision with another object
@export var breaks_on_collision := false
## Determines the sprite texture of the projectilea
@export var sprite_texture := "uid://cca0o8n8lhrcp"
## Determines the number of animation frames in the projectile
@export var num_of_frames := 1
## Determines if the projectile animation will loop.
@export var animation_is_continous := false
## Determines if the projectile has an animation
@export var has_animation := false
## Determines the offset of the projectile in relation to the parent that is spawning it
@export var parent_offset = Vector2(0,0)
## Determines the scale factor of the projectile.
@export var scale_factor = Vector2(1,1)
## Determines initial velocity of a projectile
@export var initial_velocity = Vector2(0,0)
## Is the projectile affected by gravity
@export var affected_by_gravity : bool = false
## The speed of the Projectile 
@export var speed := 0.0
## The acceleration of the Projectile 
@export var acceleration := 0.0
## Projectile spin speed.
@export var spin_speed : float = 0.0
## Modulate color of the whole projectile
@export var modulate_color : Color = Color(0,0,0,0)
## Modulate outline color of projectile
@export var modulate_outline_color : Color = Color(0.106, 0.122, 0.129)
