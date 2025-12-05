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
@onready var initial_scale : Vector2 = self.scale
var elapsed_time : float = 0.0
var original_shade_color_alpha : float = 1.0

func _ready() -> void:
	initialize_data()
	initialize_color_modulation(projectile_resource.modulate_color)
	initialize_outline_color_modulation(projectile_resource.modulate_outline_color)
	init_scale(projectile_resource.scale_factor.x, projectile_resource.scale_factor.y)
	set_attack_sprite(projectile_resource.sprite_texture)
	
	initialize_collision_and_hurtbox_shapes(projectile_resource.collision_shape, projectile_resource.hurtbox_shape)
	set_collision_size_equals_sprite(projectile_resource.collision_size_corresponds_to_sprite)
	set_hurtbox_size_equals_sprite(projectile_resource.hurtbox_size_corresponds_to_sprite)
	
	
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
	# Initialize sprite modulate to fully visible
	sprite.modulate = Color(1, 1, 1, 1)
	# Ensure material is local to scene (not shared resource) so fade works per-instance
	if sprite.material and sprite.material is ShaderMaterial:
		if not sprite.material.resource_local_to_scene:
			sprite.material = sprite.material.duplicate()
			sprite.material.resource_local_to_scene = true
		# Initialize shader alpha to 1.0
		sprite.material.set_shader_parameter("alpha", 1.0)
	#if not color == Color(255,255,255,255):
		#sprite.modulate = color
	$Sprite2D.material.set_shader_parameter("shade_color", color)
	$Sprite2D.material.set_shader_parameter("shade_color", color)
	# Store original shade_color alpha for fade calculations
	if sprite.material and sprite.material is ShaderMaterial:
		var shade_color = sprite.material.get_shader_parameter("shade_color")
		if shade_color is Color:
			original_shade_color_alpha = shade_color.a

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
	elapsed_time += delta
	do_rotation(delta)
	modify_scale_linearly(projectile_resource.scale_growth_rate)
	update_fade()
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider().name == "TileMapLayer":
			if projectile_resource.breaks_on_collision:
				destroy_projectile()
	
	if projectile_resource.speed > 0 && not self.is_on_floor(): # If the projectile is meant to move, and the projectile is airborne
		if self.scale.x > 0: # If the projectile is facing right
			if projectile_resource.acceleration != 0: # If the projectile acceleration is not equal to zero (if the projectile is meant to accelerate)
				self.velocity.x = lerp(self.velocity.x, -projectile_resource.speed, delta * projectile_resource.acceleration)
			else: # If no acceleration, apply static x velocity.
				self.velocity.x =  projectile_resource.speed * -1
				#print("applying velocity: ", self.velocity.x)
		elif self.scale.x < 0:
			if projectile_resource.acceleration != 0:
				self.velocity.x = lerp(self.velocity.x, projectile_resource.speed, delta * projectile_resource.acceleration)
			else:
				#print("applying velocity: ", self.velocity.x)
				self.velocity.x =  projectile_resource.speed * 1
	else:
		pass

	if projectile_resource.affected_by_gravity:
		self.velocity.y += gravity * delta
	if projectile_resource.affected_by_gravity or projectile_resource.speed > 0:
		move_and_slide()
		if self.is_on_floor():
			self.velocity.x = lerp(self.velocity.x, 0.0, delta)

## Rotate the projectile
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

## Modifies the scale of the projectile 
## If scale_curve is set, uses curve-based scaling. Otherwise uses linear growth_rate.
func modify_scale_linearly(growth_rate):
	if projectile_resource.scale_curve != null and projectile_resource.time_to_live > 0:
		# Use curve-based scaling
		var normalized_time = elapsed_time / projectile_resource.time_to_live
		normalized_time = clamp(normalized_time, 0.0, 1.0)
		
		# Sample the curve - ensure it returns a valid value
		var scale_multiplier = projectile_resource.scale_curve.sample(normalized_time)
		if scale_multiplier <= 0:
			scale_multiplier = 0.001  # Prevent zero or negative scale
		
		# Apply scale multiplier to initial scale factor
		var base_scale_x = abs(projectile_resource.scale_factor.x)
		var base_scale_y = abs(projectile_resource.scale_factor.y)
		
		var new_scale_x = base_scale_x * scale_multiplier
		var new_scale_y = base_scale_y * scale_multiplier
		
		# Preserve sign of scale.x for direction (use scale_factor to determine sign)
		if projectile_resource.scale_factor.x < 0:
			self.scale.x = -new_scale_x
		else:
			self.scale.x = new_scale_x
		self.scale.y = new_scale_y
	else:
		# Use linear growth rate (original method)
		if self.scale.x < 0:
			self.scale.x -= growth_rate/100
		else:
			self.scale.x += growth_rate/100
		self.scale.y += growth_rate/100
	
## Updates the projectile's alpha/opacity based on fade settings using modulate
func update_fade() -> void:
	var alpha: float = 1.0
	
	if projectile_resource.fade_curve != null and projectile_resource.time_to_live > 0:
		# Use curve-based fading
		var normalized_time = elapsed_time / projectile_resource.time_to_live
		normalized_time = clamp(normalized_time, 0.0, 1.0)
		alpha = projectile_resource.fade_curve.sample(normalized_time)
		alpha = clamp(alpha, 0.0, 1.0)
		# Debug output
		# print("Fade curve - Normalized time: ", normalized_time, " Alpha: ", alpha)
	elif projectile_resource.fade_start_time > 0.0 and elapsed_time >= projectile_resource.fade_start_time:
		# Use simple linear fade
		var fade_progress = (elapsed_time - projectile_resource.fade_start_time) / projectile_resource.fade_duration
		fade_progress = clamp(fade_progress, 0.0, 1.0)
		alpha = 1.0 - fade_progress  # Fade from 1.0 to 0.0
		# print("Fade linear - Progress: ", fade_progress, " Alpha: ", alpha)
	
	# Set sprite modulate to fade (fully transparent when alpha is 0)
	# Create new color to ensure the change takes effect
	var new_modulate = Color(1, 1, 1, alpha)  # Use white with alpha to preserve shader colors
	sprite.modulate = new_modulate
	
	# Set shader parameters for fade
	if sprite.material and sprite.material is ShaderMaterial:
		# Set shader alpha parameter (the one we added to the shader)
		# This is the main fade control - it multiplies the final COLOR.a
		sprite.material.set_shader_parameter("alpha", alpha)
		
		# Set shader shade_color alpha to fade gradually (matches fade alpha)
		var current_shade_color = sprite.material.get_shader_parameter("shade_color")
		if current_shade_color is Color:
			var new_shade_color = current_shade_color
			# Fade the shader shade_color alpha gradually to match the fade
			# Use original alpha multiplied by fade alpha to preserve the original blend strength
			new_shade_color.a = original_shade_color_alpha * alpha
			sprite.material.set_shader_parameter("shade_color", new_shade_color)

## Initializes excess data for the projectile
func initialize_data():
	pierces_left = projectile_resource.max_pierce

## When the projectile dies, get rid of it
func _on_timer_timeout() -> void:
	queue_free()
	
## Create ttl timer
func start_timer() -> void:
	timer.wait_time = projectile_resource.time_to_live
	timer.start()

## On target hit, implement functionality
func on_target_hit() -> void:
	if pierces_left != 1:
		pierces_left -= 1
	elif pierces_left == 1:
		if projectile_resource.breaks_on_collision:
			destroy_projectile(0)

## On projectile destruction 
func destroy_projectile(delay: float = 0):
	if delay == 0:
		queue_free()
	else:
		var destroy_timer = Timer.new() 
		add_child(destroy_timer)
		destroy_timer.start(delay)
		destroy_timer.timeout.connect(_destroy_timer_timout)

## On projectile destruction
func _destroy_timer_timout():
	queue_free()
