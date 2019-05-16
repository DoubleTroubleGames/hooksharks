extends Line2D

onready var twn = $Tween

const FORCE = 500
const MAX_COILING = 10.0
const MAX_LENGTH = 800.0
const N_POINTS = 25

var hook = null
var player = null
var coiling = 0.0
var freq = 10
var length
var max_amplitude = 50.0
var time = 0

func _ready():
	for i in range(N_POINTS):
		add_point(Vector2())


func _physics_process(delta):
	time += delta
	
	if not player or not hook:
		return
	
	var angle = Vector2(cos(player.sprite.rotation), sin(player.sprite.rotation))
	position = player.position + player.rider_offset * angle
	rotation_degrees = rad2deg(hook.position.angle_to_point(position))
	
	length = (hook.position - position).length()
	
	coiling = min(1, length / MAX_LENGTH) * MAX_COILING
	
	for i in range(N_POINTS):
		set_point_position(i, Vector2(length * i / (N_POINTS - 1),
				ampl(i) * sin(i * coiling / (N_POINTS - 1) + freq * time)))


func ampl(i):
	return max_amplitude * sin(i * PI / (N_POINTS - 1))


func straighten(blink = true):
	twn.interpolate_property(self, "max_amplitude", null, 0, .05,
			Tween.TRANS_BACK, Tween.EASE_IN)
	if blink:
		twn.interpolate_property(self, "modulate", Color(1, 1, 1), Color(3, 3, 3),
				.02, Tween.TRANS_LINEAR, Tween.EASE_IN)
		twn.interpolate_property(self, "modulate", Color(3, 3, 3), Color(1, 1, 1),
				.5, Tween.TRANS_LINEAR, Tween.EASE_IN, .02)
	twn.start()


func get_applying_force():
	return (hook.position - position).normalized() * FORCE
