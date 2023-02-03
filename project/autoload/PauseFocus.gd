extends Node
# Automatically pauses/unpauses the game based on window focus.


var _is_in_tree := false


func _enter_tree():
	_is_in_tree = true


func _exit_tree():
	_is_in_tree = false


func _notification(what):
	if not _is_in_tree:
		return

	match what:
		NOTIFICATION_WM_FOCUS_IN:
			# Setting unpause_priority to -1 tells other scripts that
			# PauseFocus' unpause attempt should be treated as lower priority
			# than the default (0).
			PauseManager.set_pause(false, {"unpause_priority": -1})

		NOTIFICATION_WM_FOCUS_OUT:
			PauseManager.set_pause(true)
