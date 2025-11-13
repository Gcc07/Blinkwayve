class_name Projectile
extends CharacterBody2D


@export_group("Reference Properties")

@export var hurtbox : Hurtbox
@export var timer : Timer
@export var sprite : Sprite2D
@export var collision_shape : CollisionShape2D
@export var hurtbox_shape : CollisionShape2D

## The resource containing all information about a projectile's data.
@export var projectile_resource : ProjectileResource

@onready var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var pierces_left : int
@onready var applied_initial_velocity = false

func _ready() -> void:

	initialize_data()
	initialize_color_modulation(projectile_resource.modulate_color)
	initialize_outline_color_modulation(projectile_resource.modulate_outline_color)
	init_scale(projectile_resource.scale_factor.x, projectile_resource.scale_factor.y)
	initialize_collision_and_hurtbox_shapes(projectile_resource.collision_shape, projectile_resource.hurtbox_shape)
	set_collision_size_equals_sprite(projectile_resource.collision_size_corresponds_to_sprite)
	set_hurtbox_size_equals_sprite(projectile_resource.hurtbox_size_corresponds_to_sprite)
	set_attack_sprite(projectile_resource.sprite_texture)
	
	
	initialize_projectile_frames(projectile_resource.num_of_frames)
	setup_projectile_animation()
	start_animation(projectile_resource.animation_is_continous)
	
	initialize_is_friendly(projectile_resource.is_friendly)
	start_timer()

	if hurtbox:
		hurtbox.hit_target.connect(on_target_hit)

func _process(delta: float) -> void:
	control_projectile_animations(projectile_resource.has_animation, projectile_resource.animation_is_continous)

var current_pierce_count := 0

func initialize_color_modulation(color):
	#if not color == Color(255,255,255,255):
		#sprite.modulate = color
	$Sprite2D.material.set_shader_parameter("shade_color", color)
	$Sprite2D.material.set_shader_parameter("shade_color", color)

func initialize_outline_color_modulation(color):
	$Sprite2D.material.set_shader_parameter("outline_color", color)

func initialize_is_friendly(friendly):
	if friendly:
		hurtbox.collision_mask = 2 # if friendly, set the collision mask to enemies
	else:
		hurtbox.collision_mask = 1 # if not, set the collision mask to player

func initialize_projectile_frames(num_of_frames):
	sprite.vframes = num_of_frames

func initialize_collision_and_hurtbox_shapes(collision, hurtbox):
	collision_shape.shape = projectile_resource.collision_shape
	hurtbox_shape.shape = projectile_resource.hurtbox_shape

func set_collision_size_equals_sprite(on: bool) -> void:
	var actual_sprite_height = load(projectile_resource.sprite_texture).get_height() / (projectile_resource.num_of_frames) # Returns height (accounting for animated sprite frames)
	var actual_sprite_width = load(projectile_resource.sprite_texture).get_width()
	if on:
		if collision_shape.shape.is_class("CapsuleShape2D"):
			#collision_shape.shape.set_radius(load(projectile_resource.sprite_texture).get_height()/2)
			collision_shape.shape.set_radius(actual_sprite_height/2)
			collision_shape.shape.set_height(actual_sprite_width)
			if projectile_resource.rotate_collision_shape > 0 or projectile_resource.rotate_collision_shape < 0:
				collision_shape.rotate(deg_to_rad(projectile_resource.rotate_collision_shape))
		if collision_shape.shape.is_class("CircleShape2D"):
			collision_shape.shape.set_radius(actual_sprite_width/2)
		if collision_shape.shape.is_class("RectangleShape2D"):
			collision_shape.shape.set_size(Vector2(actual_sprite_width, actual_sprite_height))
	

func set_hurtbox_size_equals_sprite(on: bool) -> void:
	var actual_sprite_height = load(projectile_resource.sprite_texture).get_height() / (projectile_resource.num_of_frames) # Returns height (accounting for animated sprite frames)
	var actual_sprite_width = load(projectile_resource.sprite_texture).get_width()
	if on:
		if hurtbox_shape.shape.is_class("CapsuleShape2D"):
			#collision_shape.shape.set_radius(load(projectile_resource.sprite_texture).get_height()/2)
			hurtbox_shape.shape.set_radius(actual_sprite_height/2)
			hurtbox_shape.shape.set_height(actual_sprite_width)
			if projectile_resource.rotate_collision_shape > 0 or projectile_resource.rotate_collision_shape < 0:
				hurtbox_shape.rotate(deg_to_rad(projectile_resource.rotate_collision_shape))
		if hurtbox_shape.shape.is_class("CircleShape2D"):
			hurtbox_shape.shape.set_radius(actual_sprite_width/2)
		if hurtbox_shape.shape.is_class("RectangleShape2D"):
			hurtbox_shape.shape.set_size(Vector2(actual_sprite_width, actual_sprite_height))

func set_attack_sprite(texture: String) -> void:
	sprite.texture = load(texture)

# This should probably get reworked. Its my current system for both initializing
# as well as controlling projectile animations without using an animation tree.
# it both uses the number of assigned frames that the projectile gives it, as
# well as the projectile time_to_live variable to create intervals where the sprite
# frame will index itself + 1. This system does not support complex animation,
# And it is also (probably) vulnerable to timing issues with different computers.

# 4/1/25 Gabe here. Yeah, it's a little scuffed, could get revamped fo sho.

func control_projectile_animations(active: bool, continous: bool):
	pass

# Set up once in _ready()
func setup_projectile_animation():
	var animation_player = $AnimationPlayer
	var animation = Animation.new()
	var track_index = animation.add_track(Animation.TYPE_VALUE)
	
	# Adjust this path to your actual Sprite location
	animation.track_set_path(track_index, NodePath("Sprite2D:frame"))
	
	animation.length = projectile_resource.time_to_live
	animation.loop = true  
	
	# Add keyframes
	for i in range(projectile_resource.num_of_frames):
		var time = (i * projectile_resource.time_to_live) / projectile_resource.num_of_frames
		animation.track_insert_key(track_index, time, i)
	
	# Create animation library and assign
	var animation_library = AnimationLibrary.new()
	animation_library.add_animation("projectile_anim", animation)
	animation_player.add_animation_library("default", animation_library)
	
func start_animation(continuous: bool):
	var animation_player = $AnimationPlayer
	var animation = animation_player.get_animation("default/projectile_anim")

	if animation:
		if continuous:
			animation.loop_mode = Animation.LOOP_LINEAR
			animation_player.play("default/projectile_anim")
		else:
			animation.loop_mode = Animation.LOOP_NONE
			animation_player.play("default/projectile_anim")




## The code below sets the intervals at which the projectile will change frames. (If applicable.)
	#var interval_array : Array = []
	#var interval : float = projectile_resource.time_to_live / projectile_resource.num_of_frames
	#var last_appended_interval : float = -snapped(interval, .1)
	#for i in range(0 , projectile_resource.num_of_frames):
		#last_appended_interval += snapped(interval, .1)
		#interval_array.append(last_appended_interval) 
	#
	#if active && continous:
#
		#if snapped(timer.time_left, 0.0001) in interval_array:
			#sprite.frame += 1
			#if sprite.frame == projectile_resource.num_of_frames:
				#sprite.frame = 0
#
	#elif active && ! continous:
		#if snapped(timer.time_left, 0.0001) in interval_array && sprite.frame != projectile_resource.num_of_frames:
			#sprite.frame += 1
	#else:
		#pass



# Projectile physics. This controls the rotation, movement, and more of the projectile.
# Okay system right now? It could probably be better. It just checks for if the projectile
# Wants certain logic, but this could restrict the logic to a few choices in the future. Maybe
# Revamp.

func _physics_process(delta: float) -> void:
	do_rotation(delta)
	init_scale(projectile_resource.scale_factor.x, projectile_resource.scale_factor.y)
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider().name == "TileMapLayer":
			destroy_projectile()

	
	if !applied_initial_velocity:
		self.velocity.y = -300
		applied_initial_velocity = true
	
	if projectile_resource.speed > 0 && not self.is_on_floor(): # If the projectile is meant to move, and the projectile is airborne
		if self.scale.x == float(1): # If the projectile is facing right
			if projectile_resource.acceleration != 0: # If the projectile acceleration is not equal to zero (if the projectile is meant to accelerate)
				self.velocity.x = lerp(self.velocity.x, -projectile_resource.speed, delta * projectile_resource.acceleration)
			else: # If no acceleration, apply static x velocity.
				self.velocity.x =  projectile_resource.speed * -1
				#print("applying velocity: ", self.velocity.x)
		elif self.scale.x == float(-1):
			if projectile_resource.acceleration != 0:
				self.velocity.x = lerp(self.velocity.x, projectile_resource.speed, delta * projectile_resource.acceleration)
			else:
				#print("applying velocity: ", self.velocity.x)
				self.velocity.x =  projectile_resource.speed * 1
	else:
		pass
		#self.velocity.x = 0

	if projectile_resource.affected_by_gravity:
		self.velocity.y += gravity * delta
	if projectile_resource.affected_by_gravity or projectile_resource.speed > 0:
		move_and_slide()
		if self.is_on_floor():
			self.velocity.x = lerp(self.velocity.x, 0.0, 3*delta)
			
		#for i in get_slide_collision_count():
			#var collision = get_slide_collision(i)
			#print("Collided with: ", collision.get_collider().name)
			#if collision.get_collider().name == "TileMapLayer":
				#is_colliding_with_ground = true
				#
				# self.velocity.x = lerp(self.velocity.x, 0.0, 1)
				#destroy_projectile(3)
			#else: 
				#is_colliding_with_ground = false

func do_rotation(delta: float):
	if projectile_resource.spin_speed > 0: 
		if self.scale.x == float(1) or self.scale.x > 0.0:
			sprite.rotation += (-projectile_resource.spin_speed * delta)
		elif self.scale.x == float(-1) or self.scale.x < 0.0:
			sprite.rotation += (projectile_resource.spin_speed * delta)
	else:
		sprite.rotation = 0

func init_scale(incoming_scale_x, incoming_scale_y):
	self.scale.x = incoming_scale_x
	self.scale.y = incoming_scale_y

func initialize_data():
	pierces_left = projectile_resource.max_pierce

func _on_timer_timeout() -> void:
	queue_free()

func start_timer() -> void:
	timer.wait_time = projectile_resource.time_to_live
	timer.start()

func on_target_hit() -> void:
	if pierces_left != 1:
		pierces_left -= 1
	elif pierces_left == 1:
		destroy_projectile(0)

func destroy_projectile(delay: float = 0):
	if delay == 0:
		queue_free()
	else:
		var destroy_timer = Timer.new() 
		add_child(destroy_timer)
		destroy_timer.start(delay)
		destroy_timer.timeout.connect(_destroy_timer_timout)

func _destroy_timer_timout():
	queue_free()
