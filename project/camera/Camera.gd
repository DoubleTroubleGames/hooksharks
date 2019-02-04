extends Camera2D

# Values of positional and rotational offsets when the screen shake is at its
# maximum
const MAX_ANGLE = 10
const MAX_OFFSET_X = 250
const MAX_OFFSET_Y = 250

# Affects how the current position of the camera affects the position in the
# next frame (0 = camera never moves, 1 = completely random shake).
const VIOLENCE = .7

# The ratio at which the screen shake decreases. It is multiplied by dt in
# process, so screen_shake goes from 1 to 0 in (1 / DEC_RATIO) seconds.
const DEC_RATIO = 1.2

# The expoent when factoring screen shake into the actual position and rotation
# offsets. Suggested value is between 2 and 3.
const EXP = 2

# A value representing current screen shake ranging from [0, 1].
var screen_shake = 0

# The actual range (also [0, 1]) that the positional and rotational offsets can
# be multiplied by.
var shake_factor = 0

func _ready():
	randomize()

func _process(delta):
	if screen_shake == 0:
		position = Vector2()
		set_process(false)
		return
	
	shake_factor = pow(screen_shake, EXP)
	
	var to_position_x = rand_range(-1, 1) * shake_factor * MAX_OFFSET_X
	var to_position_y = rand_range(-1, 1) * shake_factor * MAX_OFFSET_Y
	var to_rotation = rand_range(-1, 1) * shake_factor * MAX_ANGLE
	
	position.x = lerp(position.x, to_position_x, VIOLENCE)
	position.y = lerp(position.y, to_position_y, VIOLENCE)
	rotation_degrees = lerp(rotation_degrees, to_rotation, VIOLENCE)
	
	screen_shake = max(0, screen_shake - DEC_RATIO * delta)

func add_shake(shake):
	screen_shake = min(1, screen_shake + shake)
	set_process(true)
