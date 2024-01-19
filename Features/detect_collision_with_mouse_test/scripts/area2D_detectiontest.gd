extends Node

func _ready():
    print(" node on scene")


func _process(delta):
    self.global_position = get_viewport().get_mouse_position()