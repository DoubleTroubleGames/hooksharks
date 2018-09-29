extends Node2D

const HOOK = preload('res://hook/hook.tscn')

func _input(event):
	if event.is_action_pressed('ui_cancel'):
		get_tree().quit()

func create_hook(player):
	var hook = HOOK.instance()
	hook.position = player.position
	hook.shoot((get_viewport().get_mouse_position() - player.position).normalized())
	hook.player = player
	get_node('Hooks').add_child(hook)
