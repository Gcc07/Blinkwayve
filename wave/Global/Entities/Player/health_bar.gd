class_name HealthBar
extends Node2D

# Health bar that displays above the player's head

@export var offset_y : float = -30.0  # Vertical offset above the player
@export var bar_width : float = 40.0
@export var bar_height : float = 4.0
@export var background_color : Color = Color(0.2, 0.2, 0.2, 0.8)
@export var health_color : Color = Color(0.2, 1.0, 0.2, 1.0)
@export var low_health_color : Color = Color(1.0, 0.2, 0.2, 1.0)
@export var low_health_threshold : float = 0.3  # Show red when health is below 30%

var max_health : float = 20.0
var current_health : float = 20.0
var parent_entity : Node2D

func _ready() -> void:
	# Get the parent entity 
	parent_entity = get_parent()
	
	# Set z_index to render above the entity sprite
	z_index = 10
	
	# Try to get max_health from Health component
	var health_component = parent_entity.get_node_or_null("Health")
	if health_component:
		max_health = health_component.max_health
		current_health = health_component.health
		health_component.health_changed.connect(_on_health_changed)

func _process(_delta: float) -> void:
	# Update position to follow the player (relative to parent)
	if parent_entity:
		position = Vector2(0, offset_y)
	queue_redraw()

func _draw() -> void:
	if max_health <= 0:
		return
	
	var health_ratio = current_health / max_health
	health_ratio = clamp(health_ratio, 0.0, 1.0)
	
	# Draw background (centered)
	var bg_rect = Rect2(-bar_width / 2, -bar_height / 2, bar_width, bar_height)
	draw_rect(bg_rect, background_color)
	
	# Draw health bar (centered, left-aligned fill)
	var health_width = bar_width * health_ratio
	var health_rect = Rect2(-bar_width / 2, -bar_height / 2, health_width, bar_height)
	
	# Choose color based on health level
	var color = health_color
	if health_ratio <= low_health_threshold:
		color = low_health_color
	
	draw_rect(health_rect, color)

func _on_health_changed(health: float) -> void:
	current_health = health
	queue_redraw()
