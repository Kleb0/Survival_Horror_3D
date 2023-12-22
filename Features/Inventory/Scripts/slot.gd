#that script as its extends PanelContainer is in charge of the visual representation of a slot and its functionalities + datas
#we connect the gui_input event to signal slot_clicked, signal also connected in the inventory data and in the inventory GG script
#structure is :
# --- | SlotGD | --> | InventoryGD | --> | InventoryData |

extends PanelContainer

var hold_item_data : ItemData

@export var texture_rect: TextureRect 
@export var quantity_label: Label 
@export var slot_Index_Text : Label
@export var color_rect: ColorRect
@export var timer: Timer 
@export var originalRectColor : Color
@export var multi_slot_Rect : ColorRect

signal slot_clicked(index:int, button : int)
var threshold_distance : float = 0.1
var velocity_threshold : float = 1000

var slot_index : int = 0

func set_slot_number(index:int) -> void:
	slot_index = index
	slot_Index_Text.text = str(index)

func set_slot_data(slot_data: SlotData) -> void:

	if slot_data == null:
		texture_rect.texture = null
		quantity_label.text = ""
		tooltip_text = ""
		return

	if slot_data.item_data == null:
		texture_rect.texture = null
		quantity_label.text = ""
		tooltip_text = ""
		return
		
	else :
		quantity_label.show()		
		texture_rect.texture = slot_data.item_data.texture
		texture_rect.show()
		quantity_label.text = str(slot_data.quantity)
		tooltip_text = "%s\n%s" % [ slot_data.item_data.name, slot_data.item_data.description ]
		hold_item_data = slot_data.item_data

func _on_gui_input(event:InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT \
		and event.is_pressed():		
				slot_clicked.emit(get_index(), event.button_index)
				print(" slot clicked index is " + str(get_index()))				

			
func _on_mouse_entered() -> void:
	pass
#	change_color()

func _on_mouse_exited() -> void:
	var mouse_position = get_viewport().get_mouse_position()
	var panel_rect = get_global_rect()
	var mouse_velocity = Input.get_last_mouse_velocity()

	if mouse_velocity.length() > velocity_threshold:
		reset_color()

	if is_mouse_beyond_threshold(mouse_position, panel_rect):
		reset_color()
			
func change_color() -> void:
	color_rect.color = Color(1,1,1,0.2)	

func reset_color() -> void:
	timer.wait_time = 0.1
	timer.one_shot = true
	timer.start()
	await get_tree().create_timer(0.1).timeout	
	color_rect.color = originalRectColor

func is_mouse_beyond_threshold(mouse_position: Vector2, panel_rect: Rect2) -> bool:
	return (mouse_position.x < panel_rect.position.x - threshold_distance or
			mouse_position.y < panel_rect.position.y - threshold_distance or
			mouse_position.x > panel_rect.end.x + threshold_distance or
			mouse_position.y > panel_rect.end.y + threshold_distance)

func on_collision_detected(area: Area2D) -> void:	
	print("Collision detected with " + area.get_name())		
