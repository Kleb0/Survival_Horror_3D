extends CharacterBody3D
class_name MainCharacter

@onready var navigationAgent = $NavigationAgent3D

var camera : Camera3D
var speed : float = 1.5
var isMoving : bool = false
var target_Position : Vector3

var previous_position : Vector3 = Vector3()
var position_check_delay : float = 0.3
var min_movement_threshold : float = 0.01
var time_since_last_check : float = 0.0


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

	var global_mouse_position = get_viewport().get_mouse_position()
	var screen_size = get_viewport().get_size()
	var margin = 50

	if event is InputEventMouseButton and event.pressed:
		if Input.is_action_pressed("MoveTo"):
			print("Button Left Mouse pressed")
			if event.pressed:			

				print("Func reached line 46")
				#first check if we are clicking on a button

				for button in get_tree().get_nodes_in_group("UI"):

					if button.get_global_rect().has_point(global_mouse_position):
						return
					elif global_mouse_position.x < margin or global_mouse_position.y < margin or global_mouse_position.x > screen_size.x - margin or global_mouse_position.y > screen_size.y - margin:
						print("mouse out of bounds")
						return	

				#if not clicking on a button, then move to the clicked position	

					else:
						print("Func reached line 60")
						
						#now we need to check if we are clicking on a 3d object
						var rayLength = 100
						var rayOrigin = camera.project_ray_origin(global_mouse_position)
						var rayEnd = rayOrigin + camera.project_ray_normal(global_mouse_position) * rayLength
						var space = get_world_3d().direct_space_state
						var rayQuery = PhysicsRayQueryParameters3D.new()
						rayQuery.from = rayOrigin
						rayQuery.to = rayEnd
						var rayResult = space.intersect_ray(rayQuery)
						target_Position = rayResult.position
						navigationAgent.set_target_position(rayResult.position)																			
						print(" navigation agent target position is " + str(navigationAgent.get_target_position()))
						print(self.name + " position is :" + str(self.global_position.y))	
						
						# check if we hit something
						#if rayResult.has("position"):
												
						#else:
							#print("no hit")
							#return	

func moveToPoint(delta, speed):	
	var direction = global_position.direction_to(target_Position)
	faceDirection(target_Position)
	velocity = direction * speed
	move_and_collide(velocity * delta)
	

func faceDirection(direction):
	look_at(Vector3(direction.x, global_position.y, direction.z), Vector3.UP)

func updateCameraPosition():
	var camera_offset = Vector3(0, 3, 2)  
	var camera_look_at = Vector3(0, 1, 0)   	
	camera.global_transform.origin = global_transform.origin + camera_offset
	camera.look_at(global_transform.origin + camera_look_at, Vector3.UP)

func is_character_moving() -> bool:
	if navigationAgent.is_navigation_finished():	
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
