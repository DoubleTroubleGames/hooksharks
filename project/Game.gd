extends Node2D

onready var blink = $Blink
onready var bg = $BG
onready var hud = $HUD

const HOOK = preload("res://hook/Hook.tscn")
const HOOK_CLINK = preload("res://hook/HookClink.tscn")
const ROPE = preload("res://rope/Rope.tscn")
const WALL_PARTICLES = preload("res://fx/WallParticles.tscn")
const BG_SPEED = 20
const SHOW_ROUND_DELAY = 1
const TRANSITION_OFFSET = 1000
const TRANSITION_TIME = 1.0

export (int)var stage_num = 10
export (bool)var use_keyboard = false
export (int, "0", "1", "2", "3")var keyboard_id = 0

var hook_clink_positions = []
var ids = [0, 1, 2, 3]
var Cameras = []
var players = []
var player_num = 2

func _ready():
	var stage = get_first_stage().instance()
	stage.setup(self, player_num)
	stage.set_name("Stage")
	add_child(stage)
	
	bg.visible = true
	bg.scale = Vector2(OS.window_size.x/1600, OS.window_size.y/1280) * 1.2
	bg.position = OS.window_size / 2
	get_node("Mirage").rect_size = OS.window_size
	
	Cameras = get_cameras()
	connect_players()
	activate_players()
	
	if use_keyboard:
		var KeyboardPlayer = get_node("Players/Player" + str(keyboard_id + 1))
		KeyboardPlayer.input_type = "Keyboard_mouse"
		KeyboardPlayer.id = -1 # Sets keyboard user"s id as an out of range value
		ids.remove(keyboard_id)
		
		# Subtracts the id from all Players with id greater than keyboard user"s, as to make sure they get
		# connected to the correct gamepad
		for i in range(keyboard_id + 1, 4):
			if $Players.has_node("Player" + str(i + 1)):
				var Player = get_node("Players/Player" + str(i + 1))
				Player.id -= 1


func _physics_process(delta):
	bg.get_node("Reflex1").position += Vector2(fmod(BG_SPEED * delta, OS.window_size.x), 0)
	bg.get_node("Reflex2").position += Vector2(fmod(BG_SPEED * delta, OS.window_size.x), 0) * 2
	bg.get_node("Reflex3").position = Vector2(bg.get_node("Reflex1").position.x - OS.window_size.x, bg.get_node("Reflex1").position.y)
	bg.get_node("Reflex4").position = Vector2(bg.get_node("Reflex2").position.x - OS.window_size.x, bg.get_node("Reflex2").position.y)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func blink_screen():
	var tween = Tween.new()
	tween.interpolate_property(blink, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), .3, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
	self.add_child(tween)
	yield(tween, "tween_completed")
	tween.queue_free()

func create_rope(player, hook):
	var rope = ROPE.instance()
	rope.add_point(player.position)
	rope.add_point(player.position)
	rope.player = player
	rope.hook = hook
	get_node("Stage/Ropes").add_child(rope)
	return rope

func show_round():
	hud.show_round()
	yield(hud, "finished")
	if RoundManager.winner != -1:
		RoundManager.round_number += 1
	hud.hide_round()


func transition_stage(stage):
	var Twn = $StageTween
	var stage_pos = stage.get_position()
	Twn.interpolate_property(stage, "position", stage_pos, stage_pos + Vector2(0, TRANSITION_OFFSET), TRANSITION_TIME, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	Twn.start()


func clean_all():
	for child in $"Old Stage/Trails".get_children():
		child.queue_free()
	for child in $"Old Stage/Hooks".get_children():
		child.free_hook()
	players.clear()


func free_current_stage():
	var stage = get_node("Stage")
	stage.set_name("Old Stage") # Necessary to keep new stage from getting a name like Stage1
	transition_stage(stage)
	yield($StageTween, "tween_completed")
	clean_all()
	stage.queue_free()


func add_new_stage():
	var stage = get_random_stage().instance()
	stage.setup(self, player_num)
	stage.set_name("Stage")
	stage.set_position(Vector2(0, -TRANSITION_OFFSET))
	connect_players()
	add_child(stage)
	transition_stage(stage)
	yield($StageTween, "tween_completed")
	activate_players()


func connect_players():
	for player in players:
		player.connect("created_trail", self, "_on_player_created_trail")
		player.connect("hook_shot", self, "_on_player_hook_shot")
		player.connect("died", self, "remove_player")
		for camera in Cameras:
			player.connect("shook_screen", camera, "add_shake")

func activate_players():
	for player in players:
		player.get_node("Area2D").monitoring = true
		player.set_physics_process(true)

func remove_player(player, is_player_collision):
	players.erase(player)
	if players.size() == 1:
		var winner = players[0]
		winner.get_node("Area2D").queue_free()
		if not is_player_collision:
			var winner_id = get_winner_id(winner)
			RoundManager.scores[winner_id] += 1
			RoundManager.winner = winner_id
		else:
			RoundManager.winner = -1
		winner.set_physics_process(false)
		winner.set_process_input(false)
		
		yield(get_tree().create_timer(SHOW_ROUND_DELAY), "timeout")
		show_round()
		yield(hud, "finished")
		free_current_stage()
		yield($StageTween, "tween_completed")
		add_new_stage()


func get_winner_id(winner):
	if not use_keyboard:
		return winner.id 
	if winner.id == -1:
		return keyboard_id
	if winner.id >= keyboard_id:
		return winner.id + 1
	
	return winner.id

func _on_player_hook_shot(player, direction):
	var new_hook = HOOK.instance()
	new_hook.init(player, direction.normalized())
	new_hook.rope = create_rope(player, new_hook)
	get_node("Stage/Hooks").add_child(new_hook)
	for camera in Cameras:
		new_hook.connect("shook_screen", camera, "add_shake")
	new_hook.connect("hook_clinked", self, "_on_hook_clinked")
	new_hook.connect("wall_hit", self, "_on_wall_hit")
	
	player.get_node("SFX/HarpoonSFX").play()
	player.hook = new_hook

func _on_hook_clinked(clink_position):
	if clink_position in hook_clink_positions:
		return
	
	blink_screen()
	var hook_clink = HOOK_CLINK.instance()
	hook_clink.emitting = true
	hook_clink.position = clink_position
	add_child(hook_clink)
	
	hook_clink_positions.append(clink_position)
	
	var delay = hook_clink.lifetime / hook_clink.speed_scale
	yield(get_tree().create_timer(delay), "timeout")
	
	hook_clink.queue_free()
	hook_clink_positions.erase(clink_position)

func _on_wall_hit(position, rotation):
	var wall_particles = WALL_PARTICLES.instance()
	wall_particles.emitting = true
	wall_particles.position = position
	wall_particles.rotation = rotation
	add_child(wall_particles)
	
	var delay = wall_particles.lifetime / wall_particles.speed_scale
	yield(get_tree().create_timer(delay), "timeout")
	
	wall_particles.queue_free()

func _on_player_created_trail(trail):
	$Stage/Trails.add_child(trail)

func get_random_stage():
	var base_path = str("stages/", self.get_name().to_lower(), "-stages/Stage")
	return load(str(base_path, (randi() % stage_num - 1) + 2, ".tscn"))

func get_first_stage():
	var base_path = str("stages/", self.get_name().to_lower(), "-stages/Stage")
	return load(str(base_path, "1.tscn"))

# Used in inherited scripts
func get_cameras():
	pass