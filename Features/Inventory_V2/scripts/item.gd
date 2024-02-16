extends Node
class_name Item_Instance

var item_name : String
var item_texture : Texture
var new_position : Vector2
var new_size : Vector2
var item_size : Vector2
var number_of_columns : int
var number_of_rows : int
var numberofSlots : int
var isMultipleSlot : bool
var is_initialized : bool = false
var holded_data : ItemData
var holded_instance : Item_Instance

var occupied_slots : Array = []
var occupied_positions : Array = []


var item_index : int
var item_wide : int
var item_tall : int

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
		
		
func set_item(_item_data : ItemData) -> void:
	holded_data = _item_data
	item_name = _item_data.name
	holded_instance = self
	
	area2D = get_node("Area2D")
	item_texture = _item_data.item_texture
	set_texture()
	set_item_size(holded_data)
	if _item_data.isMultipleSlot:
		isMultipleSlot = true
	

func set_item_size(_item_data : ItemData) -> Vector2 :

	collision_shape = get_node("Area2D/CollisionShape2D")

	if _item_data.isMultipleSlot == false:
		item_size = SLOT_SIZE
		self.size = item_size
		collision_shape.shape = RectangleShape2D.new()
		collision_shape.shape.extents = self.size / 2
		collision_shape.position = self.size / 2		
		return item_size
	else:
		if _item_data.numberofSlots == 4 :
			numberofSlots = _item_data.numberofSlots
			item_tall = 2
			item_wide = 2
			item_size = SLOT_SIZE * 2
			number_of_columns = 2
			number_of_rows = 2
			self.size = item_size
			collision_shape.shape = RectangleShape2D.new()
			collision_shape.shape.extents = self.size / 2
			collision_shape.position = self.size / 2

		elif _item_data.numberofSlots == 8:
			numberofSlots = _item_data.numberofSlots
			item_tall = 2
			item_wide = 4
			item_size.x = SLOT_SIZE.x * 4
			item_size.y = SLOT_SIZE.y * 2
			number_of_columns = 4
			number_of_rows = 2
			self.size = item_size
			collision_shape.shape = RectangleShape2D.new()
			collision_shape.shape.extents = self.size / 2
			collision_shape.position = self.size / 2


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

