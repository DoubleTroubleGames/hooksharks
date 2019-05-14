extends Line2D

const AMPLITUDE = 50.0
const COILING = 10.0
const N_POINTS = 25

var freq = 10
var length
var time = .0

func _ready():
	for i in range(N_POINTS):
		add_point(Vector2())


func _draw():
	draw_circle(Vector2(), 10, Color(1, 1, 1, .5))
	draw_circle(get_local_mouse_position(), 10, Color(1, 1, 1, .5))


func _physics_process(delta):
	time += delta
	
	var mouse_pos = get_local_mouse_position()
	length = mouse_pos.length()
	
	for i in range(N_POINTS):
		set_point_position(i, Vector2(length * i / (N_POINTS - 1),
				ampl(i) * sin(i * COILING / (N_POINTS - 1) + freq * time)))
	
	update()


func ampl(i):
#	return AMPLITUDE
	return AMPLITUDE * sin(i * PI / (N_POINTS - 1))
