extends CanvasLayer

onready var twn = $Tween

signal finished

const IN_DURATION = .5
const OUT_DURATION = .7


func _input(event):
	if event.is_action_pressed("left"):
		transition_in()
	elif event.is_action_pressed("right"):
		transition_out()


func transition_in():
	$Jaw.visible = true
	
	$Jaw/Upper.rect_position.y = - $Jaw/Upper.rect_size.y
	$Jaw/Lower.rect_position.y = $Jaw.rect_size.y
	twn.interpolate_property($Jaw/Upper, "rect_position:y", null, 0, IN_DURATION,
			Tween.TRANS_QUAD, Tween.EASE_IN)
	twn.interpolate_property($Jaw/Lower, "rect_position:y", null, 0, IN_DURATION,
			Tween.TRANS_QUAD, Tween.EASE_IN)
	twn.start()
	
	yield(twn, "tween_completed")
	emit_signal("finished")


func transition_out():
	$Shark.rect_position = Vector2()
	
	$Jaw.visible = false
	
	twn.interpolate_property($Shark, "rect_position:x", null,
			$Shark.rect_size.x + $Shark/Mask.rect_size.x, OUT_DURATION,
			Tween.TRANS_LINEAR, Tween.EASE_IN)
	twn.start()
	
	yield(twn, "tween_completed")
	emit_signal("finished")
