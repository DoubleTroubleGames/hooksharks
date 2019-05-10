tool
extends Area2D

# Node for moving obstacles. You need to add the Position2Ds on it to make it
# follow those points. It is recommended to add a final position that is
# equal to the starting position, to make sure that the movement is as you
# expected. If you do not wish to specify, change explicit_loop to false.

# We can add more types, continuing the Tween.TransitionType enumeration
export(int, "Linear", "Sine", "Quintic", "Quartic", "Quadratic",\
       "Exponential", "Elastic", "Cubic") var transition_type
export(int, "In", "Out", "In-Out", "Out-In") var ease_type
export(float) var duration = 1.0
export(bool) var explicit_loop = true setget define_loop_type
export(bool) var playtest = false setget test_move

var root_position = self.position
var previous_position
var moving = false

func _ready():
	if ($Path.get_child_count() == 0):
		print("Forgot to add any positions to move on MovingObstacle!")
		queue_free()
	if (!explicit_loop):
		var loop_end = Position2D.new()
		loop_end.position = $Path/Origin.position
		loop_end.name = "ImplicitLoop"
		$Path.add_child(loop_end)
	previous_position = $Path/Origin.position
	# This is done so tool mode does not activate process on its own
	set_process(!Engine.is_editor_hint())

func _process(delta):
	if(!moving):
		move()

func move():
	moving = true
	for node in $Path.get_children():
		if node.get_name() != "Origin":
			$Tween.interpolate_property(self, "position", real_position(previous_position),\
			       real_position(node.position), duration, transition_type, ease_type)
			$Tween.start()
			yield($Tween, "tween_completed")
			previous_position = node.position
	moving = false
	
func real_position(p):
	return p + root_position





func define_loop_type(explicit):
	if (explicit):
		for node in $Path.get_children():
			if node.name == "ImplicitLoop":
				$Path.remove_child(node)
	else:
		var loop_end = Position2D.new()
		loop_end.position = $Path/Origin.position
		loop_end.name = "ImplicitLoop"
		$Path.add_child(loop_end)
	explicit_loop = explicit

func test_move(do):
	print(do)
	set_process(do)
	playtest = do

