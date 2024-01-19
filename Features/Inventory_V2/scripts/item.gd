extends Node
class_name Item_Instance

var item_name : String
var item_texture : Texture
var new_position : Vector2
var new_size : Vector2
var item_size : Vector2
var number_of_columns : int
var number_of_rows 
var numberofSlots : int
var is_initialized : bool = false

const empty_item : ItemData = preload("res://Resources/Items/empty.tres")

var collision_shape : CollisionShape2D
var area2D : Area2D

const SLOT_SIZE = Vector2(64, 64)
	
func set_empty(new_item_data : ItemData) -> void:
	item_name = new_item_data.name

	collision_shape = get_node("Area2D/CollisionShape2D")
	item_texture = empty_item.item_texture 
	set_texture()
	collision_shape.disabled = true
		
		
func set_item(new_item_data : ItemData) -> void:

	item_name = new_item_data.name
	collision_shape = get_node("Area2D/CollisionShape2D")
	area2D = get_node("Area2D")
	area2D.name = item_name
	item_texture = new_item_data.item_texture
	set_texture()
	
	if new_item_data.isMultipleSlot:

		if new_item_data.numberofSlots == 4:
			new_size = SLOT_SIZE * 2	
			self.size = new_size
			collision_shape.shape = RectangleShape2D.new()
			collision_shape.shape.extents = new_size / 2
			collision_shape.position = new_size / 2

func set_item_size(item_data : ItemData) -> Vector2 :


	if item_data.isMultipleSlot:
		if item_data.numberofSlots == 4 :
			item_size = SLOT_SIZE * 2
			number_of_columns = 2
			number_of_rows = 2
		return item_size
	else:
		item_size = SLOT_SIZE
		return item_size				


			
func set_texture() -> void:
	self.texture = item_texture

func set_position() -> void:
	self.position = new_position

func set_slot_count(item_data : ItemData):
	print("func called")
	if item_data.isMultipleSlot:
		numberofSlots = item_data.numberofSlots
	else:
		numberofSlots = 1

