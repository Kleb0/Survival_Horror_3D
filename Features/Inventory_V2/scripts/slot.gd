extends PanelContainer
class_name Slot

@export var slot_Index_Text : Label
var threshold_distance : float = 0.1
var slot_position : Vector2
var slot_index : int = 0
var area_2d : Area2D
var holding_item : Item_Instance
var is_occupied : bool = false

signal mouse_over_slot

func _ready():
	area_2d = $Area2D	
	connect("mouse_entered", Callable(self, "_on_area_2d_mouse_entered"))
	

func set_slot_number(index:int) -> void:
	slot_index = index
	slot_Index_Text.text = str(index)

	var parent_grid_container = get_parent() as GridContainer

	if parent_grid_container:

		var columns = parent_grid_container.columns
		var cell_size = self.size
				
		var h_separation = parent_grid_container.get("theme_override_constants/h_separation")
		var v_separation = parent_grid_container.get("theme_override_constants/v_separation")

		var row = index / columns
		var column = index % columns

		var position_x = column * (cell_size.x + h_separation)
		var position_y = row * (cell_size.y + v_separation)

		position = Vector2(position_x, position_y)
		slot_position = position

func _on_area_2d_mouse_entered(): 
	mouse_over_slot.emit()

