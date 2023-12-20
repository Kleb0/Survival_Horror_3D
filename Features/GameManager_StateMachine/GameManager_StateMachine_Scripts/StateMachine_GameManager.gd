extends Node

signal state_changed()
var current_state : State

var states : Dictionary = {}
@export var buttonEnable : Button
@export var labelText : Label

func _ready():
	
	for child in get_children():
		if child is State:
			states[child.name] = child				
	on_Game_Start()
	labelText.text = current_state.name
	

func on_Game_Start():
	#current state is the first element of the state dictionary on start which is "Normal_Mode"
	current_state = states.get(states.keys()[0])


func _on_enable_temperature_overlay_pressed():
	print("button pressed")
	if (current_state.name == "Normal_Mode"):
		buttonEnable.set_text("DISABLE \nTEMPERATURE \nOVERLAY")
		buttonEnable.alignment = HORIZONTAL_ALIGNMENT_CENTER
		current_state = states.get("Temperature_Overlay")
		labelText.text = current_state.name
		

	elif (current_state.name == "Temperature_Overlay"):
		current_state = states.get("Normal_Mode")
		buttonEnable.set_text("ENABLE \nTEMPERATURE \nOVERLAY")
		buttonEnable.alignment = HORIZONTAL_ALIGNMENT_CENTER
		labelText.text = current_state.name

	emit_signal("state_changed")	
