extends Control


func _on_BackIndicator_completed() -> void:
	Transition.transition_to("ModeSelect")
