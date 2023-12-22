#this script as its extends panelContainer is in charge of the visual representation of the inventory
#it's instantiate the slots scenes which are an array of UI elements that hold the item data or empty data if there is no item

extends PanelContainer

const Slot = preload("res://Features/Inventory/Scenes_Visual_represetentation/slot.tscn")
var inv_data = preload("res://Resources/Inventories/test_inv.tres")

var counter : int
var slot_counter : int

@onready var item_grid: GridContainer = $MarginContainer/GridContainer
@onready var availableSlotNumber : Label = $AvailableSlotNumber
@onready var controlNode : Control = $Control
@export var grabbed_slot : PanelContainer

var slot_array : Array = []

var previous_slot = null

func set_inventory_data(inventory_data: InventoryData) -> void :
	inventory_data.inventory_updated.connect(populate_idem_grid)
	populate_idem_grid(inventory_data)	

func populate_idem_grid(inventory_data: InventoryData) -> void :
	print("inventory data set")
	counter = 0
	previous_slot = null
	slot_counter = 0
	
	if counter < 18:				
		
		for child in item_grid.get_children():		
			slot_array.append(child)	
		
		for slot_data in inventory_data.slot_datas:
			
			var slot = slot_array[slot_counter]
	
			slot.set_slot_number(slot_counter)

			if slot_data != null:
				slot.set_slot_data(slot_data)

				if slot_data.item_data == null:
					counter += 1		
			elif slot_data == null:
				slot.set_slot_data(null)
				counter += 1
				

			if slot.slot_clicked.is_connected(Callable (inventory_data, "on_slot_clicked")):
				pass
			else:
				slot.slot_clicked.connect(inventory_data.on_slot_clicked)	

			slot_counter += 1
	print("counter is", counter )
	availableSlotNumber.text = str(counter-1)			
