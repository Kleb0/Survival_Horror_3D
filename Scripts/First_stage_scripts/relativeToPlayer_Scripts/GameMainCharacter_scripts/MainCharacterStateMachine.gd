extends PlayerState

var current_player_state : PlayerState 

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		if child is PlayerState:
			current_player_state = child
			print(child.name)			
	
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

