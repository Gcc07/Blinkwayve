class_name Entity
extends CharacterBody2D

# This is the master Entity class from which all other Entities originate.
# Sort of useless rn. Implement functionality.
@export var entity_id := ""
@export var alive := true
@export var can_move := true
@export var hostile := true
@export var can_be_damaged := true
@export var stunned := false
@export var parrying := false

#@export var status_effects_array : Array = []
#
#func _process(delta: float) -> void:
	#if parrying && !status_effects_array.has("parrying"):
		#status_effects_array.append("parrying")
	#elif !parrying:
		#status_effects_array.erase("parrying")
	#print(status_effects_array)
	
