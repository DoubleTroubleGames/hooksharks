extends Node2D

const HOOK = preload('res://hook/hook.tscn')
const ROPE = preload('res://rope/rope.tscn')
const BG_SPEED = 20

onready var bg = get_node('BG')

func _ready():
	print(get_node('/root/global').scores)
	bg.scale = Vector2(OS.window_size.x/1600, OS.window_size.y/1280)
	bg.position = (bg.scale * Vector2(1600, 1280))/2
	get_node('Mirage').rect_size = OS.window_size

func _physics_process(delta):
	bg.get_node('Reflex1').position += Vector2(fmod(BG_SPEED * delta, OS.window_size.x), 0)
	bg.get_node('Reflex2').position += Vector2(fmod(BG_SPEED * delta, OS.window_size.x), 0) * 2
	bg.get_node('Reflex3').position = Vector2(bg.get_node('Reflex1').position.x - OS.window_size.x, bg.get_node('Reflex1').position.y)
	bg.get_node('Reflex4').position = Vector2(bg.get_node('Reflex2').position.x - OS.window_size.x, bg.get_node('Reflex2').position.y)

func _input(event):
	print(event.as_text())
	if event.is_action_pressed('ui_cancel'):
		print("oi")
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
