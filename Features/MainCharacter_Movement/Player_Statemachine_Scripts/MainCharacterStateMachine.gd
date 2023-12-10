extends PlayerState
class_name Player_State_Manager

var mainCharacter_animationTree : AnimationTree
var mainCharacter_AnimationPlayer : AnimationPlayer
var paramPath : String = "parameters/Blend2/blend_amount"
var blend_Value : float = 0.0
var blend_Target : float = 0.0
var blend_Speed : float = 3.0

var current_State : PlayerState
var player_states : Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():	

	mainCharacter_AnimationPlayer = get_node("/root/Test_Level/test_character_CharacterBody3D/test_character_Node3D/MainCharacter_AnimationPlayer")
	mainCharacter_animationTree = get_node("/root/Test_Level/test_character_CharacterBody3D/test_character_Node3D/MainCharacter_AnimationTree")

	for child in get_children():
		if child is PlayerState:
			player_states[child.name] = child
	
	#current state is the first state in the dictionary
	current_State = player_states[player_states.keys()[0]]


func _process(delta):
	set_Animation(delta)
	
		
func blend_states(state_a : PlayerState, state_b : PlayerState, blend_factor : float):
	blend_factor = clamp(blend_factor, 0.0, 1.0)	

	if blend_factor < 0.5:
		current_State = state_a		
	else :
		current_State = state_b	
		
	mainCharacter_animationTree.set(paramPath, blend_factor)
	
func set_Animation(delta):
	var idle_state : PlayerState = player_states["Idle"]
	var walk_state : PlayerState = player_states["Walk"]

	if get_parent().velocity == Vector3.ZERO:		
		blend_Target = 0.0 		
	else :	
		blend_Target = 1.0 

	blend_Value = lerp(blend_Value, blend_Target, blend_Speed * delta)
	blend_states(idle_state, walk_state, blend_Value)	
