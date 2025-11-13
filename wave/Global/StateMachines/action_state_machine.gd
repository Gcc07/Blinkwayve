extends Node

# Action State Machine. Controls the logic of actions of an entity. 

@export
var starting_state: ActionState
var current_state: ActionState

# Initialize the state machine by giving each child (INDIVIDUAL STATE!) a ref
# to the parent object (General Entity) it belongs to.

func init(parent: CharacterBody2D, sprite: Sprite2D, moveAnimations: 
	AnimationPlayer, actionAnimations: AnimationPlayer, action_component) -> void:
	for child in get_children():
		child.parent = parent
		child.moveAnimations = moveAnimations
		child.actionAnimations = actionAnimations
		child.action_component = action_component
		child.sprite = sprite

	# Initialize to the default state
	change_state(starting_state)

# Change to the new state by first calling any exit logic on the current state.
func change_state(new_state: ActionState) -> void:
	if current_state:
		current_state.exit()

	current_state = new_state
	current_state.enter()
	
# Pass through functions for the Entity to call,
# handling state changes as needed.

func process_physics(delta: float) -> void:
	#print(current_state)

	var new_state = current_state.process_physics(delta)
	if new_state:
		change_state(new_state)

func process_frame(delta: float) -> void:
	var new_state = current_state.process_frame(delta)
	if new_state:
		change_state(new_state)
		
func process(delta: float) -> void:
	var new_state = current_state.process_frame(delta)
	if new_state:
		change_state(new_state)

func process_input(event: InputEvent) -> void:
	var new_state = current_state.process_input(event)
	if new_state:
		change_state(new_state)
