#this script as its extends panelContainer is in charge of the visual representation of the inventory
#it's instantiate the slots scenes which are an array of UI elements that hold the item data or empty data if there is no item

extends PanelContainer

var counter : int
var slot_counter : int

@onready var item_grid: GridContainer = $MarginContainer/GridContainer
@onready var availableSlotNumber : Label = $AvailableSlotNumber
@onready var controlNode : Control = $Control
@onready var items_control : Control = $MarginContainer/Items_Controller


var slot_array : Array = []


func set_inventory_data(inventory_data: InventoryData) -> void :
	set_slot_grid()	
	items_control.initialize_items_in_inventory(inventory_data)


func set_slot_grid() -> void :
	print("inventory data set")
	counter = 0
	slot_counter = 0
	
	if counter < 18:				
		
		for child in item_grid.get_children():		
			slot_array.append(child)	

			var slot = slot_array[slot_counter]
	
			slot.set_slot_number(slot_counter)

			if slot_array[slot_counter].is_valide_slot :
				counter += 1
			

			slot_counter += 1
			
	availableSlotNumber.text = str(counter)			