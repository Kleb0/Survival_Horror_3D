#this script as its extends panelContainer is in charge of the visual representation of the inventory
#it's instantiate the slots scenes which are an array of UI elements that hold the item data or empty data if there is no item

extends PanelContainer

const Slot = preload("res://Features/Inventory/Scenes_Visual_represetentation/slot.tscn")
var inv_data = preload("res://Resources/Inventories/test_inv.tres")
var counter : int

@onready var item_grid: GridContainer = $MarginContainer/GridContainer
@onready var availableSlotNumber : Label = $AvailableSlotNumber

func set_inventory_data(inventory_data: InventoryData) -> void :
	inventory_data.inventory_updated.connect(populate_idem_grid)
	populate_idem_grid(inventory_data)	


func populate_idem_grid(inventory_data: InventoryData) -> void :
	print("inventory data set")
	counter = 0
	if counter < 18:				
		
		for child in item_grid.get_children():    
			child.queue_free()
		
		for slot_data in inventory_data.slot_datas:	
			var slot = Slot.instantiate()
			item_grid.add_child(slot)

			slot.slot_clicked.connect(inventory_data.on_slot_clicked)

			if slot_data:	
				slot.set_slot_data(slot_data)
			
			if slot_data == null:			
				counter += 1
		availableSlotNumber.text = str(counter)			

	else :	
		print("inventory is empty")
		
