extends CharacterBody3D
class_name MainCharacter

@onready var navigationAgent = $NavigationAgent3D
@export var inventory : PanelContainer
@export var player_inventory_data : InventoryData
@export var inventoryInterface : Control

var camera : Camera3D
var speed : float = 1.5
var isMoving : bool = false
var target_Position : Vector3

var previous_position : Vector3 = Vector3()
var position_check_delay : float = 0.3
var min_movement_threshold : float = 0.01
var time_since_last_check : float = 0.0
var correction_factor : float = 1.0
var proximity_threshold : float = 0.1

func _ready():
	camera = get_tree().get_nodes_in_group("Camera")[0]
	updateCameraPosition()

func _process(delta):
	if is_character_moving():
		moveToPoint(delta, speed)
		if check_if_stuck(delta):
			velocity = Vector3(0, 0, 0)
		else :
			velocity = velocity * speed		
	else:
		velocity = Vector3(0, 0, 0) 
	updateCameraPosition()
	
func _input(event):

	if event is InputEventMouseButton and event.pressed and self.visible == true:
		if Input.is_action_pressed("MoveTo"):			
			if event.pressed:
				set_direction()

	if event is InputEventKey and event.pressed:
		if Input.is_action_pressed("ToggleInventory"):

			inventoryInterface.visible = !inventoryInterface.visible
			inventory.visible = !inventory.visible			
			
			
func moveToPoint(delta, speedvalue):	
	var direction = global_position.direction_to(target_Position)  
	faceDirection(target_Position)
	velocity = direction * speedvalue
	move_and_collide(velocity * delta)	

func faceDirection(direction):
	look_at(Vector3(direction.x, global_position.y, direction.z), Vector3.UP)

func updateCameraPosition():
	var camera_offset = Vector3(0, 3, 2)  
	var camera_look_at = Vector3(0, 1, 0)   	
	camera.global_transform.origin = global_transform.origin + camera_offset
	camera.look_at(global_transform.origin + camera_look_at, Vector3.UP)

func is_character_moving() -> bool:
	var distance_to_target = global_position.distance_to(target_Position)	
	#check if we are close enough to target or if we have reached the target
	if distance_to_target < proximity_threshold or navigationAgent.is_navigation_finished():
		navigationAgent.set_target_position(Vector3.ZERO)
		return false					
	else:				
		return true

func check_if_stuck(delta) -> bool:
	time_since_last_check += delta
	var current_position = global_position
	if current_position.distance_to(previous_position) < min_movement_threshold :	
		return true		
	else:		
		previous_position = current_position
		time_since_last_check = 0.0		
		#velocity is no more zero, so we are not stuck		
		return false

func set_direction():

	var global_mouse_position = get_viewport().get_mouse_position()
	var screen_size = get_viewport().get_size()
	var margin = 50

	#set up raycast parameters
	var rayLength = 100
	var rayOrigin = camera.project_ray_origin(global_mouse_position)
	var rayEnd = rayOrigin + camera.project_ray_normal(global_mouse_position) * rayLength
	var space = get_world_3d().direct_space_state
	var rayQuery = PhysicsRayQueryParameters3D.new()
	rayQuery.from = rayOrigin
	rayQuery.to = rayEnd

	#shoot raycast and get result if intersect with something
	var rayResult = space.intersect_ray(rayQuery)

	#check if we click on a UI element
	for button in get_tree().get_nodes_in_group("UI"):
	
		if inventoryInterface.visible == true:
			if button.get_global_rect().has_point(global_mouse_position):			
				rayResult = null					
				return
	
	#if we clik on the inventory while 
	for button in get_tree().get_nodes_in_group("Inventory"):
			
		if button.get_global_rect().has_point(global_mouse_position):		
			if inventory.visible == true:			
				rayResult = null
				return
			
	#check if we click on the edge of the screen				
	if global_mouse_position.x < margin \
		or global_mouse_position.y < margin \
		or global_mouse_position.x > screen_size.x - margin \
		or global_mouse_position.y > screen_size.y - margin:
		rayResult = null
		return

	if rayResult.has("position"):
		#print("rayResult.position is " + str(rayResult.position))
		target_Position = rayResult.position
		navigationAgent.set_target_position(rayResult.position)
	
