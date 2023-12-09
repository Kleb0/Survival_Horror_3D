extends Node

var rotation_speed : float = 1
var translation_range : Vector2 = Vector2(0.0, 0.7)
var translation_speed : float = 3.0

var tween
var is_moving_up : bool = true

var start_position : Vector3
var target_position : Vector3

var callable

# Called when the node enters the scene tree for the first time.
func _ready():
	tween = create_tween()
	start_position = self.position
	print("start_position at ready is: ", start_position)
	print("target position is at ready: ", target_position)
	callable = Callable(self, "on_tween_completed")
	tween.connect("finished", callable)
	start_tween_animation()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.rotation.y += rotation_speed * delta

func start_tween_animation():
	if (is_moving_up):	
		target_position = start_position + Vector3(0.0, translation_range.y, 0.0)
	else:
		target_position = start_position
		
	tween.tween_property(self, "position", target_position, translation_speed)

func on_tween_completed():
	tween.stop()
	#kill the tween
	tween.kill()
	tween = create_tween()
	target_position = start_position
	tween.connect("finished", callable)
	is_moving_up = !is_moving_up
	start_tween_animation()
