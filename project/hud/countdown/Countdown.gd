extends CanvasLayer

onready var ready_label = $CenterContainer/Ready
onready var go_label = $CenterContainer/Go

signal go_shown

func _ready():
	pass


func start_countdown():
	$AnimationPlayer.play("countdown")


# Called in AnimationPlayer "countdown" animation
func go():
	emit_signal("go_shown")
