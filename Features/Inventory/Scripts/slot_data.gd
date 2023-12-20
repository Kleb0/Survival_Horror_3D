extends Resource
class_name SlotData

const max_stack_size: int  = 99

@export var item_data: ItemData
@export_range(0, max_stack_size) var quantity : int = 0

func can_fully_merge_with(other_slot_data : SlotData) -> bool:
    return item_data == other_slot_data.item_data \
        and item_data.stackable \
        and quantity + other_slot_data.quantity < max_stack_size

func fully_merge_with(other_slot_data: SlotData) -> void:
    quantity += other_slot_data.quantity
      

