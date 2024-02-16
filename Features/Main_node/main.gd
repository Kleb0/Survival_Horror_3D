extends Node

@onready var player : CharacterBody3D = $test_character_CharacterBody3D
@onready var inventory_interface: Control = $GameUI/UI_Control/Inventory_Interface

func _ready() -> void: 
   print("pass inventory data to player inventory func main.gd")
   inventory_interface.set_inventory_data(player.player_inventory_data)
   
   # --- player is the player character body node in the scene --- #
   # --- player inventory data is the resource that holds the inventory data --- #
   # --- holds by the player as exported variable and it's passed as argument to the inventory interface --- #
