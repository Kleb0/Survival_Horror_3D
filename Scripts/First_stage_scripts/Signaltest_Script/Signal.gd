extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void :
	connect("mouse_entered", _testuntruc)

func _testuntruc() -> void :
	print("test reussi avec mouse entered")
