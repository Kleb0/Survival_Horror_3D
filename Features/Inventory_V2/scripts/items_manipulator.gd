extends Node

var shift_positions : Array 
@export var raycast2D : RayCast2D
@export var grabbed_item : TextureRect
@export var items_manager : Control
@export var slotGrid : GridContainer
@export var inventoryData : InventoryData
@export var items_parent : Control

func _process(_delta):
  if grabbed_item.visible:
    grabbed_item.position = get_viewport().get_mouse_position()

func set_item_manipulator(_inventoryData : InventoryData):
  print("manipulator ready")
  grabbed_item.hide()
  grabbed_item.get_node("Area2D/CollisionShape2D").set_deferred("disabled", true)
  

func on_mouse_over_slot():
  pass


func set_shift_available_positions(positions : Array) -> void:
  shift_positions = positions
  
  
func _input(event) -> void:
    
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
      var mouse_pos = get_viewport().get_mouse_position()       
      
      raycast2D.position = mouse_pos - Vector2(20, 20)
      raycast2D.force_raycast_update()
      var collider = raycast2D.get_collider()
      print("clicked on ", collider.get_parent().name)

      if collider != null:

         # ---- case : you clicked on an item and the grabbed item is not visible 

        if collider.get_parent().name.contains("item") and !grabbed_item.visible:

          print("clicked on ", collider.get_parent().name)
          grabbed_item.show()
          var clicked_item : Item_Instance = collider.get_parent()
          var clicked_item_data : ItemData = clicked_item.holded_data
          grabbed_item.set_item(clicked_item_data)

          for slots in clicked_item.occupied_slots:
            slots.get_node("Area2D/CollisionShape2D").disabled = false
            print("Enabled collision shape for ", slots.name)

          for pos in clicked_item.occupied_positions:
            items_manager.available_positions.append(pos)
            items_manager.occupied_positions.remove_at(items_manager.occupied_positions.find(pos))

          clicked_item.occupied_slots.clear()
          clicked_item.queue_free()     
          #  print("slot ", slots.name, " is occupied by ", clicked_item_data.name)

          #remove the clicked item from the holded inventoryData array
          for i in range(inventoryData.item_instances_array.size()):
            if inventoryData.item_instances_array[i].name == clicked_item_data.name:
              inventoryData.item_instances_array.remove_at(i)
              print("removed item ", clicked_item_data.name, " from inventoryData array")
              break

          #remove the slot from clicked_item occupied_positions
          #remove the positions corresponding to the slots from item_manager occupied_positions, non_available_positions and add these 
          #positions to the available_positions

          var iterator = 0

          while iterator < clicked_item.occupied_positions.size():

            var position_to_remove = clicked_item.occupied_positions[iterator]
            var index_to_remove = items_manager.occupied_positions.find(position_to_remove)
            var index_to_remove_non_available = items_manager.non_available_positions.find(position_to_remove)

            if index_to_remove != -1 and index_to_remove_non_available != -1 :
              items_manager.occupied_positions.remove_at(index_to_remove)
             # print("removed position ", position_to_remove, " from occupied_positions")
              items_manager.non_available_positions.remove_at(index_to_remove_non_available)
              items_manager.available_positions.append(position_to_remove)
              clicked_item.occupied_positions.remove_at(position_to_remove)
              clicked_item.occupied_slots.remove_at(index_to_remove)
            

            elif index_to_remove != -1:

              items_manager.occupied_positions.remove_at(index_to_remove)
              items_manager.available_positions.append(position_to_remove)
            #  print("removed position ", position_to_remove, " from occupied_positions")  
            iterator += 1  

          clicked_item.queue_free()


        # ---- case : you clicked on an item and the grabbed item is visible

        if grabbed_item.visible and collider.get_parent().name.contains("item"): 
          print("clicked on item while holding item so we swap them")
          var clicked_item = collider.get_parent()
          var clicked_item_data = clicked_item.holded_data
          grabbed_item.set_item(clicked_item_data)
          print("grabbed item is ", grabbed_item.holded_instance.name)

          # if the item we clicked on and the grabbed item are the same
        
      
        # ---- case : you clicked on a slot and the grabbed item is visible so you dropped the item

        elif grabbed_item.visible and collider.get_parent().name.contains("Slot"):
                    
          #duplicate the grabbed item and add it to the slot

          var clicked_slot : Slot = collider.get_parent()
          var clicked_slot_index : int = clicked_slot.slot_index
          var total_columns : int = slotGrid.columns

          #to know the number of rows in the grid
          var total_rows : int = slotGrid.get_child_count() / total_columns

          #find the column of the clicked slot
          var current_column : int = clicked_slot_index % total_columns
          var current_row : int = clicked_slot_index / total_columns
          

          if can_place_item(grabbed_item.holded_instance, clicked_slot_index, current_column, current_row,
            total_rows, total_columns, grabbed_item.holded_instance.item_wide, grabbed_item.holded_instance.item_tall):

            if grabbed_item.holded_instance.isMultipleSlot:                   
              print("place multislot item")
              place_item(grabbed_item.holded_instance, clicked_slot_index)
              assign_slots(grabbed_item.holded_instance, clicked_slot_index, grabbed_item.holded_instance.item_wide,
              grabbed_item.holded_instance.item_tall)
            
          else:
            printerr("can't place item")
        
          if grabbed_item.isMultipleSlot:
            pass

          #  items_manager.set_multi_slot_item(placed_item, clicked_slot_index, slotGrid, placed_item.item_wide, placed_item.item_tall)

        # ---- case : you clicked on a slot and the grabbed item is not visible  
        
        elif collider.get_parent().name.contains("Slot"):
          print("clicked on slot")

func can_place_item(_item : Item_Instance, _slot_index : int,
   _current_column : int, _current_row : int,
    _total_columns : int, _total_rows : int,
   _item_wide : int, _item_tall : int) -> bool:


  var checking_wide_value : int = _current_column + _item_wide
  print(" \n current column is ", _current_column, " total columns is ",
   _current_row, " item wide is ", _item_wide , " checking wide value is ", checking_wide_value)

  var checking_tall_value : int = _current_row + _item_tall
  print(" current row is ", _current_row, " total rows is ", _total_rows, 
  " item tall is ", _item_tall, " checking tall value is ", checking_tall_value)

  if checking_tall_value > _total_columns:
   return false
    
  if checking_wide_value > _total_rows:
    return false


  return true 

func place_item( _ItemInstance : Item_Instance, _Slot_index : int):

  
  var item_instance_to_place : Item_Instance = _ItemInstance.duplicate()
  item_instance_to_place.set_item(_ItemInstance.holded_data)
  item_instance_to_place.get_node("Area2D/CollisionShape2D").set_deferred("disabled", false)
  item_instance_to_place.position = slotGrid.get_child(_Slot_index).position
  items_parent.add_child(item_instance_to_place)

  grabbed_item.hide()

  pass

func assign_slots(_ItemInstance : Item_Instance, _Slot_index : int, _item_wide : int, _item_tall : int):
  for r in range(_item_tall):
    for c in range(_item_wide):
      var local_index : int = _Slot_index + r * slotGrid.get_columns() + c
      _ItemInstance.occupied_slots.append(slotGrid.get_node("Slot " + str(local_index)))
    for slots in _ItemInstance.occupied_slots:
      slots.get_node("Area2D/CollisionShape2D").disabled = true
      print("slot ", slots.name, " is occupied by ", _ItemInstance.holded_data.name)  
       