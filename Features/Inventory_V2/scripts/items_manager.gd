# this script is used to manage the inventory. 
# It takes a grid container and fills the node it is attached to with items

extends Control

var item_collection : Array = []
var occupied_indices : Array = []
var available_positions : Array = []
var occupied_positions : Array = []
var non_available_positions : Array = []
var total_positions : Array = []
var positions_data : Array = []
var slots_in_grid : Array = []
var occupied_slots : Array = []
var item_positions : Dictionary = {}

var item_index : int = 0
var index : int = 0
var last_item_multislot : ItemData
var inventoryData : InventoryData
var item_Instance : Item_Instance
var is_initializing : bool = false

const item = preload("res://Features/Inventory_V2/Visual_Representation_Scenes/item.tscn")
const empty_item : ItemData = preload("res://Resources/Items/empty.tres")

const SLOT_SIZE = Vector2(64, 64)
var hasbeenFilledwithEmpty : bool = false

@export var gridContainer : GridContainer
@export var grabbedItem : TextureRect
@export var itemsManipulator : Control
@export var itemsParent : Control

#------------- Initialize part -----------------#

func initialize_items_in_inventory(inventory_data: InventoryData) -> void:
	print("set_item_collection")
	print("inventory data size is : ", inventory_data.item_instances_array.size())
	is_initializing = true

	available_positions.clear()
	occupied_positions.clear()
	non_available_positions.clear()
	total_positions.clear()
	positions_data.clear() 

	var slot_index : int = 0
	#get the slot positions
	for child in gridContainer.get_children():
		if child is Slot:
			child.slot_index = slot_index
			positions_data.append(child.slot_position) 
			available_positions.append(child.slot_position)
			total_positions.append(child.slot_position)
			slots_in_grid.append(child)
			child.name = "Slot " + str(slot_index)
			slot_index += 1

	itemsManipulator.set_shift_available_positions(total_positions)
	
	#------ here we iterate through the positions obtained with the grid container ------#
	
	while index < available_positions.size():
	#	print("available_positions : ", index, " | ", available_positions[index])

		if item_index < inventory_data.item_instances_array.size():

			#~-------- in this block here here we iterate through the item instances and set their slots ------#

			var itemData = inventory_data.item_instances_array[item_index]
			occupied_indices.clear()

			var item_instance = item.instantiate()
			item_instance.name = "item " + itemData.name + " " + str(item_index)
			item_instance.set_item(itemData)

			if itemData.isMultipleSlot:
				#index is calculated when we the set_multi_slot item which returns the updated index
				index = set_multi_slot_item(item_instance, index, gridContainer,
				item_instance.item_wide, item_instance.item_tall)
				
			else:
				#index is updated after we set the unique slot item
				set_unique_slot_item(item_instance, index)
				index += 1
				
			instantiate_item_in_grid(item_instance, itemData, itemsParent, occupied_indices, item_index)
			item_index += 1

		else :
			index += 1 #so that we avoid infinite loop

	#------- end of instantiation loop ------#		

	check_for_common_positions(item_positions)
	itemsManipulator.set_item_manipulator(inventory_data)
	is_initializing = false

#------- end of initialization ------#		

#------- Multislot logic ------#
	
func set_multi_slot_item(_item_instance : Item_Instance, _grid_index : int,
	 _gridContainer : GridContainer, _item_wide : int, _item_tall : int) -> int:
#modulo allow us to know at which column we are in the grid container 
	
	var total_columns :int = _gridContainer.get_columns()
	var start_row :int = int(_grid_index / total_columns)
		
	var start_col :int = _grid_index % total_columns
	var slots_filled :int = 0

	while slots_filled < _item_instance.numberofSlots:
		
		if start_col + _item_wide <= total_columns:

			var item_startpos_in_grid : int = start_row * total_columns + start_col

			var can_place_multislot_item : bool = can_place(item_startpos_in_grid, _item_wide,
			 _item_tall, total_columns)
		
			if can_place_multislot_item :
				assign_multi_slots(_item_instance, item_startpos_in_grid, _item_wide, _item_tall)			
				slots_filled += _item_wide * _item_tall

			#in this case, we assume that the func will be called by item manipulator when we'll drop the item in the grid
			#if the item cannot be placed it will return an error message
			#initialization and manipulation are two different phases
			#if we are not in the initialization phase, we can print the error message

		#	if can_place_multislot_item == false and is_initializing == false:
		#		printerr("Cannot place item : ", _item_instance.name, " at position : ", item_startpos_in_grid, 
		#		" slot is already occupied or item is out of grid bounds")	

		start_col = (start_col + 1) % total_columns
		if start_col == 0:
			start_row += 1		

		if slots_filled >= _item_instance.numberofSlots:
			break
	
	return _grid_index
			
func assign_multi_slots( _item_instance, _item_startpos_in_grid, _item_wide, _item_tall):
	for r in range(_item_tall):
		for c in range(_item_wide):
			var local_index = _item_startpos_in_grid + r * gridContainer.get_columns() + c
			_item_instance.occupied_slots.append(gridContainer.get_node("Slot " + str(local_index)))
			occupied_indices.append(local_index)
			available_positions.erase(positions_data[local_index])
			occupied_positions.append(positions_data[local_index])
			_item_instance.occupied_positions.append(positions_data[local_index])

	for slots in _item_instance.occupied_slots:
		slots.get_node("Area2D/CollisionShape2D").disabled = true

#this function checks if the item can be fitted in the grid container
func can_place(_slots_index_to_add : int, _item_wide: int, _item_tall : int, _total_columns : int) -> bool :
	
	var current_row : int = _slots_index_to_add / _total_columns
	if current_row + _item_wide > _total_columns:
		return false

	#calculate the current column
	var current_col : int = _slots_index_to_add % _total_columns
	if current_col + _item_tall > _total_columns:
		return false
		

	for r in range(_item_tall):
		for c in range(_item_wide):
			index = _slots_index_to_add + r * _total_columns + c
			if index >= positions_data.size() or positions_data[index] in occupied_positions :					
				return false	
			for i in range(occupied_indices.size()):
				if index == occupied_indices[i]:
					return false
	return true

#------- Unique slot logic ------#
			
	
func set_unique_slot_item(_item_instance : Item_Instance, _item_pos_in_grid : int)-> void :

	var local_index : int = _item_pos_in_grid

	while local_index < positions_data.size():
		if positions_data[local_index]  in  available_positions:
			available_positions.erase(positions_data[local_index])
			occupied_positions.append(positions_data[local_index])
			occupied_indices.append(local_index)
			_item_instance.occupied_slots.append(gridContainer.get_node("Slot " + str(local_index)))
			for slots in _item_instance.occupied_slots:
				slots.get_node("Area2D/CollisionShape2D").disabled = true
			_item_instance.occupied_positions.append(positions_data[local_index])
			return	
		local_index += 1

#----- item adding logic -----#

func instantiate_item_in_grid(_item_instance : Item_Instance, _itemData : ItemData, _itemsParent : Control,
	 _occupied_indices : Array, _item_index : int):

	var real_positions = convert_indices_to_positions(_occupied_indices)
	item_positions[_itemData.name + " " + str(item_index)] = _item_instance.occupied_positions
	place_item(_item_instance, _itemData, _itemsParent, real_positions)

func place_item(_item_instance : Item_Instance, _itemData : ItemData, _itemsParent : Control , _real_positions : Array) -> void:

	if _real_positions.size() > 0:

		_item_instance.new_position = _real_positions[0]
		_item_instance.set_position()
		_itemsParent.add_child(_item_instance)


#--- convert positions and check for common positions ---#

#this function returns the positions of the item in the grid container
func convert_indices_to_positions(_indices: Array) -> Array:
	var positions : Array = []
	for _index in _indices:
		positions.append(positions_data[_index])
	return positions	


#this functions checks if positions are shared between items and print an error if it is the case		
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