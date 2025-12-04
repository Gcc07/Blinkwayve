class_name EnemyMoveComponent
extends Node

var target: Entity = null
# Component that returns information on Enemy movement input.

var raycast: RayCast2D = null
var dash_timer: Timer = null
var should_dash: bool = false

# Return the desired direction of movement for the character
# in the range [-1, 1], where positive values indicate a desire
# to move to the right and negative values to the left.

func _ready() -> void:
	# Try to get existing RayCast2D, or create one if it doesn't exist
	if has_node("RayCast2D"):
		raycast = $RayCast2D
	else:
		raycast = RayCast2D.new()
		raycast.name = "RayCast2D"
		self.add_child(raycast)
	
	# Configure raycast
	raycast.enabled = true
	raycast.target_position = Vector2(1000, 0)  # Default range, will be updated
	raycast.collision_mask = 1  # Adjust collision mask as needed
	
	# Create dash timer
	dash_timer = Timer.new()
	dash_timer.name = "DashTimer"
	dash_timer.one_shot = true
	dash_timer.timeout.connect(_on_dash_timer_timeout)
	add_child(dash_timer)
	start_dash_timer()
	
	# Find player initially
	find_player_with_raycast()

func start_dash_timer() -> void:
	if not dash_timer:
		return
	
	# Random interval between 5-10 seconds
	var random_interval = randf_range(5.0, 10.0)
	dash_timer.wait_time = random_interval
	dash_timer.start()

func _on_dash_timer_timeout() -> void:
	should_dash = true
	# Restart timer for next dash
	start_dash_timer()

func find_player_with_raycast() -> void:
	# Get all nodes in the scene tree
	var scene_root = get_tree().root
	var player = find_player_in_tree(scene_root)
	
	if not player or not raycast:
		target = null
		return
	
	# Update raycast to point towards player
	var direction_to_player = player.global_position - get_parent().global_position
	var distance_to_player = direction_to_player.length()
	
	# Set raycast to reach the player
	raycast.target_position = direction_to_player
	raycast.force_raycast_update()
	
	# Check if raycast hits the player
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		# Check if we hit the player directly or a child of the player (like a collision shape)
		if collider is Player:
			target = collider
		elif collider.get_parent() is Player:
			target = collider.get_parent()
		else:
			# Raycast hit something else, player is behind an obstacle
			target = null
	else:
		# Raycast didn't hit anything - player might be in line of sight
		# but collision layers might not be set up, so we'll still target the player
		# This allows the enemy to track the player even if collision detection isn't perfect
		target = player

func find_player_in_tree(node: Node) -> Player:
	# Recursively search for Player node
	if node is Player:
		return node
	
	for child in node.get_children():
		var result = find_player_in_tree(child)
		if result:
			return result
	
	return null

func _physics_process(_delta: float) -> void:
	if not raycast:
		return
	
	# Continuously update raycast to track player
	if target and is_instance_valid(target):
		var direction_to_player = target.global_position - get_parent().global_position
		raycast.target_position = direction_to_player
		raycast.force_raycast_update()
		
		# Verify player is still visible via raycast
		if raycast.is_colliding():
			var collider = raycast.get_collider()
			# Check if we still have line of sight to the player
			if not (collider is Player or (collider.get_parent() is Player)):
				# Lost line of sight - obstacle in the way
				target = null
		# If raycast doesn't hit anything, we keep the target
		# (player might still be there, just collision layers might not be set up)
	else:
		# Target is invalid or null, try to find player again
		if target and not is_instance_valid(target):
			target = null
		find_player_with_raycast()

func get_movement_direction_x() -> float:
	if not target or not is_instance_valid(target):
		return 0.0
	
	var direction = Vector2(0,0)
	direction = target.global_position - get_parent().global_position
	var velocity_x = snapped(direction.normalized().x,1)
		# print(velocity_x, get_parent().name)
	return velocity_x

func get_movement_direction_y() -> float:
	if not target or not is_instance_valid(target):
		return 0.0
	
	var direction = Vector2(0,0)
	direction = target.global_position - get_parent().global_position
	var velocity_y = snapped(direction.normalized().y,1)
		# print(velocity_x, get_parent().name)
	return velocity_y
	
func get_dash() -> float:
	# Return 1.0 when dash should trigger, then reset the flag
	if should_dash:
		should_dash = false
		return 1.0
	return 0.0
