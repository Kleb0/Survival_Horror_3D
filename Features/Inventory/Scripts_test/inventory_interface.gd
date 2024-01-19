extends Control

var grabbed_slot_data : SlotData

@export var timer : Timer
@onready var player_inventory : PanelContainer = $PlayerInventory
@export var grabbed_slot: PanelContainer

var canDeleteGrabedSlot : bool = false

func set_player_inventory_data(inventory_data : InventoryData) -> void:	
	if inventory_data !=null:
	#	inventory_data.inventory_interact.connect(on_inventory_interact)
		player_inventory.set_inventory_data(inventory_data)
#	inventory_data.set_grabbed_slot.connect(set_grabbed_slot_data)

func on_inventory_interact(inventory_data: InventoryData, index: int, button: int) -> void:

	if inventory_data != null:
		match [grabbed_slot_data, button]:
			[null, MOUSE_BUTTON_LEFT]:
				grabbed_slot_data = inventory_data.grab_slot_data(index)				
			[_, MOUSE_BUTTON_LEFT]:
				grabbed_slot_data = inventory_data.drop_slot_data(grabbed_slot_data, index)
			


func set_grabbed_slot_data() -> void:
	print("SIGNAL TO SET GRABBED SLOT DATA RECEIVED")
	grabbed_slot_data = null

