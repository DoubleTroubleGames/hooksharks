extends Node2D

const HOOK = preload('res://hook/hook.tscn')
const ROPE = preload('res://rope/rope.tscn')

func _ready():
	get_tree().paused = false
	var bg = get_node('BG')
	print(get_node('/root/global').scores)
	bg.scale = Vector2(OS.window_size.x/1600, OS.window_size.y/1280)
	bg.position = (bg.scale * Vector2(1600, 1280))/2
	bg.get_node('Reflex1/AnimationPlayer').play('anim')
	bg.get_node('Reflex2/AnimationPlayer').play('anim')

func _input(event):
	if event.is_action_pressed('ui_cancel'):
		get_tree().quit()

func create_hook(player, dir):
	var hook = HOOK.instance()
	hook.position = player.position
	hook.shoot(dir.normalized())
	hook.player = player
	get_node('Hooks').add_child(hook)
	var rope = ROPE.instance()
	rope.add_point(player.position)
	rope.add_point(player.position)
	rope.player = player
	rope.hook = hook
	hook.rope = rope
	get_node('Ropes').add_child(rope)
	return hook
