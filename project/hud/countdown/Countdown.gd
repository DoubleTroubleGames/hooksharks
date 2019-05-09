extends CanvasLayer

onready var ready_label = $CenterContainer/Ready
onready var go_label = $CenterContainer/Go

signal go_shown

func _ready():
	pass


func start_countdown(stage_name = null, laps_number = null):
	if stage_name:
		$StageName.text = stage_name
		if laps_number:
			$StageName/Laps.text = "laps: " + str(laps_number)
		else:
			$StageName/Laps.text = ""
	$AnimationPlayer.play("countdown")


# Called in AnimationPlayer "countdown" animation
func go():
	emit_signal("go_shown")
