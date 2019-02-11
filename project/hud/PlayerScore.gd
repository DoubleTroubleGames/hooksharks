extends VBoxContainer

signal marker_animation_ended()

onready var markers = $ScoreMarkers.get_children()
onready var tween = $Tween

const DURATION = .3
const MAX_ROTATION = 20
const SFX_DELAY = .2

export(Texture) var portrait_texture

var score = 0

func _ready():
	assert(SFX_DELAY < DURATION)
	
	$Portrait.texture = portrait_texture
	
	for m in markers:
		m.rotation_degrees = rand_range(-MAX_ROTATION, MAX_ROTATION)


func set_score(s):
	score = s
	for i in range(score):
		markers[i].visible = true


func marker_animation():
	var marker = markers[score]
	marker.modulate.a = 0
	marker.scale = Vector2(2, 2)
	marker.visible = true
	
	tween.interpolate_property(marker, "modulate:a", null, 1, DURATION,
			Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(marker, "scale", null, Vector2(1, 1), DURATION,
			Tween.TRANS_BACK, Tween.EASE_OUT)
	tween.start()
	
	yield(get_tree().create_timer(SFX_DELAY), "timeout")
	$ScoreSFX.play()
	
	yield(tween, "tween_completed")
	emit_signal("marker_animation_ended")
