extends Control

@onready var inventoryModel : PanelContainer = $Inventory_Model


func set_inventory_data(inventory_data : InventoryData) -> void:	
  if inventory_data !=null:
    pass
    inventoryModel.set_inventory_data(inventory_data)