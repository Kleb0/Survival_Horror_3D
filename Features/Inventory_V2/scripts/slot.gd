#that script as its extends PanelContainer is in charge of the visual representation of a slot and its functionalities + datas
#we connect the gui_input event to signal slot_clicked, signal also connected in the inventory data and in the inventory GG script
#structure is :
# --- | SlotGD | --> | InventoryGD | --> | InventoryData |

extends PanelContainer
class_name Slot

@export var slot_Index_Text : Label
@export var collision_area : Area2D


var threshold_distance : float = 0.1
var velocity_threshold : float = 1000

var is_valide_slot : bool = true

var slot_position : Vector2

var slot_index : int = 0


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


func set_slot_data(slot_data: SlotData) -> void:

	if slot_data == null:
		
		tooltip_text = ""
		return

	if slot_data.item_data == null:
		
		tooltip_text = ""
		return
		
	else :
	
		tooltip_text = "%s\n%s" % [ slot_data.item_data.name, slot_data.item_data.description ]		

			
func _on_mouse_entered() -> void:
	pass
#	change_color()

func _on_mouse_exited() -> void:
	var mouse_position = get_viewport().get_mouse_position()
	var panel_rect = get_global_rect()
	var mouse_velocity = Input.get_last_mouse_velocity()

	if mouse_velocity.length() > velocity_threshold:
		pass
	#	reset_color()

	if is_mouse_beyond_threshold(mouse_position, panel_rect):
		pass
	#	reset_color()
			
#func change_color() -> void:
#	color_rect.color = Color(1,1,1,0.2)	

# func reset_color() -> void:
#	timer.wait_time = 0.1
#	timer.one_shot = true
#	timer.start()
#	await get_tree().create_timer(0.1).timeout	
#	color_rect.color = originalRectColor

func is_mouse_beyond_threshold(mouse_position: Vector2, panel_rect: Rect2) -> bool:
	return (mouse_position.x < panel_rect.position.x - threshold_distance or
			mouse_position.y < panel_rect.position.y - threshold_distance or
			mouse_position.x > panel_rect.end.x + threshold_distance or
			mouse_position.y > panel_rect.end.y + threshold_distance)
