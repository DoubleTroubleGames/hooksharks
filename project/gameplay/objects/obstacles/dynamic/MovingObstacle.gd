tool
extends Node2D

# Node for moving obstacles. You need to add the Position2Ds on it to make it
# follow those points. It is recommended to add a final position that is
# equal to the starting position, to make sure that the movement is as you
# expected. If you do not wish to specify, change explicit_loop to false.

# We can add more types, continuing the Tween.TransitionType enumeration
export(int, "Linear", "Sine", "Quintic", "Quartic", "Quadratic",\
       "Exponential", "Elastic", "Cubic") var transition_type
export(int, "In", "Out", "In-Out", "Out-In") var ease_type
export(float) var duration = 1.0
export(bool) var explicit_loop = false setget define_loop_type
export(bool) var playtest = false setget test_move

export(PackedScene) var obstacle setget define_obstacle

var is_editor = Engine.is_editor_hint()


var Obstacle
var root_position = self.position
var previous_position
var moving = false

func _ready():
	print(root_position)
	# Cleanup, in case there is leftovers from playtesting
	test_check_current_nodes(1)
	
	for node in get_children():
		if node.name == "Obstacle" or node.name == "ImplicitLoop":
			node.name = "Old"
			node.queue_free()
	
	if ($Path.get_child_count() == 0):
		print("Forgot to add any positions to move on MovingObstacle!")
		if (force_terminate()):
			return
	
	if not obstacle:
		print("Forgot to add Obstacle to MovingObstacle!")
		force_terminate()
	else:
		Obstacle = obstacle.instance()
		Obstacle.set_name("Obstacle")
		add_child(Obstacle)

	if (!explicit_loop):
		var loop_end = Position2D.new()
		loop_end.position = $Path/Origin.position
		loop_end.name = "ImplicitLoop"
		$Path.add_child(loop_end)
	
	previous_position = $Path/Origin.position
	# This is done so tool mode does not activate process on its own
	set_process(!is_editor)

func _process(delta):
	if(!moving):
		move()

func move():
	moving = true
	for node in $Path.get_children():
		if node.get_name() != "Origin":
			$Tween.interpolate_property(Obstacle, "position", previous_position,\
			       node.position, duration, transition_type, ease_type)
			$Tween.start()
			yield($Tween, "tween_completed")
			previous_position = node.position
	moving = false
	
func stop():
	$Tween.stop_all()

func force_terminate():
	if (is_editor):
		set_process(false)
		return true
	else:
		queue_free()

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
	# Cannot playtest if does not have object
	if(obstacle):
		set_process(do)
		playtest = do

func define_obstacle(o):
	obstacle = o
	for node in get_children():
		if node.name == "Obstacle":
			node.name = "Old Obstacle"
			node.queue_free()
	
	if(obstacle):
		Obstacle = o.instance()
		Obstacle.set_name("Obstacle")
		add_child(Obstacle)

func test_check_current_nodes(moment):
	print(str(moment))
	for node in get_children():
		print(node.name)
		if node.get_child_count() > 0:
			for child in node.get_children():
				print(child.name)

