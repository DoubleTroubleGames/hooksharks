extends Node2D

onready var blink = $Blink
onready var bg = $BG
onready var camera = $Camera2D
onready var hud = $HUD
onready var stages = STAGES_DB.new()

const HOOK = preload('res://hook/Hook.tscn')
const ROPE = preload('res://rope/Rope.tscn')
const STAGES_DB = preload('res://arena-mode/stages/StagesDb.gd')
const BG_SPEED = 20

export (bool)var use_keyboard = false
export (int, '0', '1', '2', '3')var keyboard_id = 0

var ids = [0, 1, 2, 3]


func _ready():
	if Global.scores == [0, 0]:
		self.add_child(stages.get_first_stage().instance())
	else:
		self.add_child(stages.get_random_stage().instance())
	bg.visible = true
	bg.scale = Vector2(OS.window_size.x/1600, OS.window_size.y/1280) * 1.2
	bg.position = OS.window_size / 2
	get_node('Mirage').rect_size = OS.window_size
	self.move_child(hud, self.get_child_count())
<<<<<<< HEAD
	
	# Screen shake signals
	hud.connect("shook_screen", camera, "add_shake")
	for player in $Players.get_children():
		player.connect("shook_screen", camera, "add_shake")
	
	if use_keyboard:
		var KeyboardPlayer = get_node("Players/Player" + str(keyboard_id + 1))
		KeyboardPlayer.input_type = "Keyboard_mouse"
		KeyboardPlayer.id = -1 # Sets keyboard user's id as an out of range value
		ids.remove(keyboard_id)
		
		# Subtracts the id from all Players with id greater than keyboard user's, as to make sure they get
		# connected to the correct gamepad
		for i in range(keyboard_id + 1, 4):
			if $Players.has_node("Player" + str(i + 1)):
				var Player = get_node("Players/Player" + str(i + 1))
				Player.id -= 1


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
	hook.connect("shook_screen", camera, "add_shake")
	var rope = ROPE.instance()
	rope.add_point(player.position)
	rope.add_point(player.position)
	rope.player = player
	rope.hook = hook
	BGM.get_node('Harpoon').play()
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
	if Global.winner != -1:
		Global.round_number += 1
	get_tree().paused = false
	get_tree().reload_current_scene()
