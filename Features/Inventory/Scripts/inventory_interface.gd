extends Control
class_name InventoryInterface

var grabbed_slot_data : SlotData

@export var timer : Timer
@onready var player_inventory : PanelContainer = $PlayerInventory
@export var grabbed_slot: PanelContainer

var canDeleteGrabedSlot : bool = false

func _ready():
	print(grabbed_slot_data)

func _physics_process(delta: float) -> void:	
	if grabbed_slot.visible:
		grabbed_slot.global_position = get_viewport().get_mouse_position() + Vector2(5, 5)
	
			
func set_player_inventory_data(inventory_data : InventoryData) -> void:	
	inventory_data.inventory_interact.connect(on_inventory_interact)
	player_inventory.set_inventory_data(inventory_data)
#	inventory_data.set_grabbed_slot.connect(set_grabbed_slot_data)

func on_inventory_interact(inventory_data: InventoryData, index: int, button: int) -> void:

	match [grabbed_slot_data, button]:
		[null, MOUSE_BUTTON_LEFT]:
			grabbed_slot_data = inventory_data.grab_slot_data(index)					
		[_, MOUSE_BUTTON_LEFT]:
			grabbed_slot_data = inventory_data.drop_slot_data(grabbed_slot_data, index)	
	
	update_grabbed_slot()

func set_grabbed_slot_data() -> void:
	print("SIGNAL TO SET GRABBED SLOT DATA RECEIVED")
	grabbed_slot_data = null

func update_grabbed_slot() -> void:

	if grabbed_slot_data:
		if grabbed_slot_data.item_data != null:
			grabbed_slot.show()	
			grabbed_slot.set_slot_data(grabbed_slot_data)
		else:
			grabbed_slot.hide()
