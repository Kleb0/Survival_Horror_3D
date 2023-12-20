extends Node

@onready var player : CharacterBody3D = $test_character_CharacterBody3D
@onready var inventory_interface: Control = $GameUI/Control/MarginContainer/InventoryInterface

func _ready() -> void: 
   print("pass inventory data to player inventory func main.gd")
   inventory_interface.set_player_inventory_data(player.player_inventory_data)
