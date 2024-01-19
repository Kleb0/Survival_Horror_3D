extends Resource
class_name ItemData

@export var name = ""
@export_multiline var description = ""
@export var stackable: bool = false
@export var item_texture : Texture
@export var isMultipleSlot : bool = false
@export var numberofSlots : int = 0
var position_occupied : int 
var positions_occupied : Array = []
var position_in_grid : Vector2

const ORIGINAL_SIZE : int = 64
var item_size : Vector2

func set_size():
    if isMultipleSlot:
        if numberofSlots == 4 :
            pass