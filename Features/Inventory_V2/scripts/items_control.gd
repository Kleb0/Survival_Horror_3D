# this script is used to manage the inventory. 
# It takes a grid container and fills the node it is attached to with items

extends Control

var item_collection : Array = []
var occupied_indices : Array = []
var available_positions : Array = []
var occupied_positions : Array = []
var non_available_positions : Array = []
var positions_data : Array = []
var item_positions : Dictionary = {}
var raycast2D : RayCast2D
var item_Instance
var current_Item_To_Iterate
var item_index : int = 0
var index : int = 0
var last_item_multislot : ItemData

const item = preload("res://Features/Inventory_V2/Visual_Representation_Scenes/item.tscn")
const empty_item : ItemData = preload("res://Resources/Items/empty.tres")

const SLOT_SIZE = Vector2(64, 64)
var hasbeenFilledwithEmpty : bool = false

@export var gridContainer : GridContainer

func _ready():
	raycast2D = $RayCast2D
	raycast2D.enabled = false

#------------- Initialize part -----------------#


func initialize_items_in_inventory(inventory_data: InventoryData) -> void:
	print("set_item_collection")
	item_index 	

	available_positions.clear()
	occupied_positions.clear()
	non_available_positions.clear() 

	#get the slot positions
	for child in gridContainer.get_children():
		if child is Slot:
			positions_data.append(child.slot_position) 
			available_positions.append(child.slot_position) 

	print(" inventory size is ", inventory_data.item_instances_array.size())
	print(" amount of available positions is ", available_positions.size())		     

	#------ here we iterate through the positions obtained with the grid container ------#
	
	while index < available_positions.size():
	#	print("available_positions : ", index, " | ", available_positions[index])

		if item_index < inventory_data.item_instances_array.size():

			#~-------- in this block here here we iterate through the item instances and set their slots ------#

			var item_to_add = inventory_data.item_instances_array[item_index]
			occupied_indices.clear()

			var item_instance = item.instantiate()
			item_instance.name = item_to_add.name + " " + str(item_index)
			var item_size = item_instance.set_item_size(item_to_add)

			var slots_wide = int (ceil(item_size.x / SLOT_SIZE.x))
			var slots_tall = int (ceil(item_size.y / SLOT_SIZE.y))

			if item_to_add.isMultipleSlot:
				set_multi_slot_item(item_to_add, gridContainer, item_index, slots_wide, slots_tall)
			
			else:
				set_unique_slot_item(positions_data, occupied_positions, occupied_indices, available_positions, item_index, item_to_add)
				
			var real_positions = convert_indices_to_positions(occupied_indices)
			item_to_add.positions_occupied = real_positions
			item_positions[item_to_add.name + " " + str(item_index)] = item_to_add.positions_occupied

			
			add_item(item_instance, real_positions, item_to_add)

			item_index += 1

		else :
			index += 1

	check_for_common_positions(item_positions)

func set_multi_slot_item(_item, _gridContainer, _index, _slots_wide, _slots_tall):

	var slots_filled = 0
	var current_row = _index / _gridContainer.get_columns()
	var current_col = _index % _gridContainer.get_columns()

	while slots_filled < _item.numberofSlots:

		var start_index = current_row * _gridContainer.get_columns() + current_col
		if current_col + _slots_wide <= gridContainer.get_columns() and check_if_can_place(start_index, _slots_wide, _slots_tall):
			assign_multi_slots(start_index, _slots_wide, _slots_tall)
			slots_filled += _slots_wide * _slots_tall

		current_col += 1
		if current_col + _slots_wide > _gridContainer.get_columns():
			current_col = 0
			current_row += 1

		if slots_filled >= _item.numberofSlots:
			break	
			
func set_unique_slot_item(_positions_data, _occupied_positions, _occupied_indices, _available_positions, _index, _item)-> void :

	var local_index = _index

	while local_index < _positions_data.size():
		if _positions_data[local_index] not in _occupied_positions:
			_occupied_indices.append(local_index)
			_occupied_positions.append(_positions_data[local_index])
			_available_positions.erase(_positions_data[local_index])
			return	
		local_index += 1

func check_if_can_place(_start_index, _slots_wide, _slots_tall) -> bool :

	var start_row = _start_index / gridContainer.get_columns()

	if start_row + _slots_wide > gridContainer.get_columns():
		return false

	for r in range(_slots_tall):
		for c in range(_slots_wide):
			index = _start_index + r * gridContainer.get_columns() + c
			if index >= positions_data.size() or positions_data[index] in occupied_positions:
				return false
	return true

func assign_multi_slots(_start_index, _slots_wide, _slots_tall):
	for r in range(_slots_tall):
		for c in range(_slots_wide):
			index = _start_index + r * gridContainer.get_columns() + c
			occupied_indices.append(index)
			available_positions.erase(index)
			occupied_positions.append(positions_data[index])		
		
func convert_indices_to_positions(indices: Array) -> Array:
	var positions : Array = []
	for _index in indices:
		positions.append(positions_data[_index])
	return positions	

func set_empty_item(_index : int ) -> void:
	if hasbeenFilledwithEmpty == false:
		for pos in positions_data:
			var empty_item_instance = item.instantiate()
			empty_item_instance.set_empty(empty_item)
			empty_item_instance.tooltip_text = "%s\n%s" % [empty_item.name, empty_item.description]
			empty_item_instance.new_position = position
			empty_item_instance.set_position()
			add_child(empty_item_instance)
			_index += 1
		hasbeenFilledwithEmpty = true

		if hasbeenFilledwithEmpty == true:
			_index = 0

func add_item(item_instance, real_positions, _item) -> void:
	if real_positions.size() > 0:
		item_instance.new_position = real_positions[0]
		item_instance.set_position()
		item_instance.set_item(_item)
		add_child(item_instance)


#------------- Input and Controls -----------------#

func _input(event):

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		var mouse_pos = get_viewport().get_mouse_position()
		raycast2D.position = mouse_pos - get_global_position()
		raycast2D.enabled = true
		raycast2D.force_raycast_update()

		if raycast2D.is_colliding():
			var collider = raycast2D.get_collider()
			print("collider : ", collider)  


#------------- Check for errors -----------------#

func check_for_common_positions(_item_positions : Dictionary) -> void:
	print("check for common positions")

	var checked_positions : Dictionary = {} #Dictionary to follow checked positions

	for key in _item_positions.keys():
		var positions : Array = _item_positions[key] 

		for pos in positions:
			if pos in checked_positions:
				printerr("Conflict detected : '%s' and '%s' share following position : %s " % [checked_positions[position], key, position])				
			else:
				checked_positions[position] = key	
