extends Node
# Responsible for pausing and unpausing the game.
# Scripts that want to be involved with pausing/unpausing should join
# the "pause_sync" group and implement the following functions:
# 	_allow_set_pause() -> bool
# 	_on_set_pause(should_pause: bool) -> void


var _info := {}


# If all members of pause_sync allow set_pause
# to continue, then pause or unpause the game.
func set_pause(should_pause: bool, info := {}) -> void:
	if should_pause == get_tree().is_paused():
		return

	_info = info
	if not _allow_set_pause():
		return

	get_tree().call_group("pause_sync", "_on_set_pause", should_pause)
	get_tree().set_pause(should_pause)


# Return whether every member of pause_sync will allow set_pause to continue.
func _allow_set_pause() -> bool:
	for node in get_tree().get_nodes_in_group("pause_sync"):
		if not node.has_method("_allow_set_pause"):
			continue

		if not node._allow_set_pause():
			return false

	return true


# Return the info dictionary provided by the most recent caller
# of set_pause, which scripts may use as part of their
# _allow_set_pause or _on_set_pause implementations.
func get_info() -> Dictionary:
	return _info
