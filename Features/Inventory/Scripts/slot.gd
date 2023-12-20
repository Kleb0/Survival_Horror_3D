#that script as its extends PanelContainer is in charge of the visual representation of a slot and its functionalities + datas
#we connect the gui_input event to signal slot_clicked, signal also connected in the inventory data and in the inventory GG script
#structure is :
# --- | SlotGD | --> | InventoryGD | --> | InventoryData |

extends PanelContainer


@export var texture_rect: TextureRect 
@export var quantity_label: Label 
@export var color_rect: ColorRect
@export var timer: Timer 
@export var originalRectColor : Color

signal slot_clicked(index:int, button : int)

func set_slot_data(slot_data: SlotData) -> void:
	var item_data = slot_data.item_data
	
	if slot_data == null :
		texture_rect.texture = null
		quantity_label.text = "" 
		tooltip_text =  "empty slot"	
	else :
		quantity_label.show()		
		texture_rect.texture = slot_data.item_data.texture
		quantity_label.text = str(slot_data.quantity)
		tooltip_text = "%s\n%s" % [ slot_data.item_data.name, slot_data.item_data.description ]
		

func _on_gui_input(event:InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT \
		and event.is_pressed():	
				slot_clicked.emit(get_index(), event.button_index)
				print(" slot clicked index is " + str(get_index()))
											
				color_rect.color = Color(1,1,1,0.5)	
		else:
			reset_color()
				
func reset_color() -> void:
	timer.wait_time = 0.1
	timer.one_shot = true
	timer.start()
	await get_tree().create_timer(0.1).timeout	
	color_rect.color = originalRectColor
