extends Area2D

# Node for moving obstacles. You need to add the Position2Ds on it to make it
# follow those points. It is recommended to add a final position that is
# equal to the starting position, to make sure that the movement is as you
# expected. If you do not wish to specify, change explicit_loop to false.

# We can add more types, continuing the Tween.TransitionType enumeration
export(int, "Linear", "Sine", "Quintic", "Quartic", "Quadratic",\
       "Exponential", "Elastic", "Cubic") var transition_type
export(int, "In", "Out", "In-Out", "Out-In") var ease_type
export(float) var duration = 1.0;
export(bool) var explicit_loop = true;

func _ready():
	if (!explicit_loop):
		Path.add_
		