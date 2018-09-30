extends Node2D

const HOOK = preload('res://hook/hook.tscn')
const ROPE = preload('res://rope/rope.tscn')
const BG_SPEED = 20

onready var blink = $Blink
onready var bg = get_node('BG')
onready var camera = $Camera2D
onready var hud = $HUD

func _ready():
	bg.visible = true
	bg.scale = Vector2(OS.window_size.x/1600, OS.window_size.y/1280) * 1.2
	bg.position = OS.window_size / 2
	get_node('Mirage').rect_size = OS.window_size

func _physics_process(delta):
	bg.get_node('Reflex1').position += Vector2(fmod(BG_SPEED * delta, OS.window_size.x), 0)
	bg.get_node('Reflex2').position += Vector2(fmod(BG_SPEED * delta, OS.window_size.x), 0) * 2
	bg.get_node('Reflex3').position = Vector2(bg.get_node('Reflex1').position.x - OS.window_size.x, bg.get_node('Reflex1').position.y)
	bg.get_node('Reflex4').position = Vector2(bg.get_node('Reflex2').position.x - OS.window_size.x, bg.get_node('Reflex2').position.y)

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

func blink_screen():
	var tween = Tween.new()
	tween.interpolate_property(blink, 'modulate', Color(1, 1, 1, 1), Color(1, 1, 1, 0), .3, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
	self.add_child(tween)
	yield(tween, 'tween_completed')
	tween.queue_free()

func show_round():
	hud.show_round()
	yield(hud, "finished")
	if global.winner != -1:
		global.round_number += 1
	get_tree().paused = false
	if global.scores[0] < 3 and global.scores[1] < 3:
		get_tree().reload_current_scene()
