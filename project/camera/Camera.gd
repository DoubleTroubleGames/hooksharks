extends Camera2D

# Values of positional and rotational offsets when the screen shake is at its
# maximum
const MAX_ANGLE = 15
const MAX_OFFSET_X = 250
const MAX_OFFSET_Y = 250

# The ratio at which the screen shake decreases. It is multiplied by dt in
# process, so screen_shake goes from 1 to 0 in (1 / DEC_RATIO) seconds.
const DEC_RATIO = 1.5

# The expoent when factoring screen shake into the actual position and rotation
# offsets. Suggested value is between 2 and 3.
const EXP = 2

# A value representing current screen shake ranging from [0, 1].
var screen_shake = 0

# The actual range (also [0, 1]) that the positional and rotational offsets can
# be multiplied by.
var shake_factor = 1

var target = null


func _ready():
	randomize()

func _physics_process(delta):
	if target:
		position = target.position

func _process(delta):
	shake_factor = pow(screen_shake, EXP)
	
	position.x = rand_range(-1, 1) * shake_factor * MAX_OFFSET_X
	position.y = rand_range(-1, 1) * shake_factor * MAX_OFFSET_Y
	rotation_degrees = rand_range(-1, 1) * shake_factor * MAX_ANGLE
	
	screen_shake = max(0, screen_shake - DEC_RATIO * delta)

func add_shake(shake):
	screen_shake = min(1, screen_shake + shake)
