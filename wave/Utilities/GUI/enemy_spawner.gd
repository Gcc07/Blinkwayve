extends Button

var spawned_entity
@export var entity : PackedScene = preload("uid://c167mxfdcy2uo")
@export var spawn_offset : Vector2 = Vector2(200, 0)  # Offset from player position

func _ready() -> void:
	pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	if not entity:
		print("No entity scene assigned!")
		return
	
	var spawned_entity = entity.instantiate()
	
	# Get the Main scene (current scene root)
	var main_scene = get_tree().current_scene
	if not main_scene:
		print("Could not find current scene!")
		return
	
	# Find player to spawn enemy near them
	var player = main_scene.get_node_or_null("Player")
	if player:
		# Spawn enemy offset from player position
		spawned_entity.global_position = player.global_position + spawn_offset
	else:
		# Fallback: spawn at a default position
		spawned_entity.global_position = Vector2(237, 82)
	
	main_scene.add_child(spawned_entity)
	print("Spawned enemy at position: ", spawned_entity.global_position)
