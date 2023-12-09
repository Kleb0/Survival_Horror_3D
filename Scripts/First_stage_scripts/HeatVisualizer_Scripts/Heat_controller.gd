extends Node

@export var heatValue : int = 1
var parentName : String
var parentMaterialFilePath : String

var materialCold : Material = load("res://HeatVisualizerSystem/mats/ColdTemp.material")
var materialHot : Material = load("res://HeatVisualizerSystem/mats/HotTemp.material")
var materialNormal : Material = load("res://HeatVisualizerSystem/mats/NormalTemp.material")
var materialOriginal : Material
var gameState : Node

# Called when the node enters the scene tree for the first time.
func _ready():

	_GetParentData()
	materialOriginal = load(parentMaterialFilePath)
	get_parent().material_override = materialOriginal	

	gameState = get_node("/root/Environnement/GameManager/StateMachine_GameManager")
	gameState.connect("state_changed", Callable(self, "_HeatVisualizerCall"))
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _HeatVisualizerCall():
	_HeatVisualizer(heatValue)

func _HeatVisualizer(heatParameter):
	
	if gameState.current_state.name == "Temperature_Overlay":
		
		if heatParameter < 0 :
			get_parent().material_override = materialCold
		elif heatParameter > 0 :
			get_parent().material_override = materialHot
		else :
			get_parent().material_override = materialNormal

	if gameState.current_state.name == "Normal_Mode":
		get_parent().material_override = materialOriginal	

	
func _GetParentData():
	parentName = get_parent().name
	parentMaterialFilePath = "res://GameObjects/" + parentName + "/" + parentName + ".material"

	
