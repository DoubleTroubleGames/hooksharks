extends "res://camera/Camera.gd"

const MIN_ZOOM = 1
const ZOOM_LERP = 1
const POS_LERP = 1
const WINNER_ZOOM = .5
const WINNER_ZOOM_LERP = .15

var focuses = []
var max_limit = Vector2()
var min_limit = Vector2()
var point_focus = null

func _ready():
	set_physics_process(false)


func _physics_process(delta):
	update_camera()
	update()

func focus_on_point(point):
	point_focus = point
	
func reset_focus_point():
	point_focus = null

func update_camera():
	
	if not point_focus:
		get_focus_limits()
		
		#Update camera position
		position = min_limit + (max_limit - min_limit) / 2
		#set_position(lerp(position, target_pos, POS_LERP))
		
		#Update camera zoom
		var screen_size = get_tree().root.size
		
		var target_zoom = (max_limit-min_limit)/screen_size
		var final_zoom = max(max(target_zoom.x, target_zoom.y), MIN_ZOOM)
		#zoom = Vector2(final_zoom, final_zoom)
		set_zoom(lerp(zoom, Vector2(final_zoom, final_zoom), ZOOM_LERP))
	else:
		set_position(lerp(position, point_focus, POS_LERP))
		set_zoom(lerp(zoom, Vector2(WINNER_ZOOM, WINNER_ZOOM), WINNER_ZOOM_LERP))


func get_focus_limits():
	if focuses.empty():
		print("GroupCamera.gd: Should have at least one focus")
		assert(false)
	
	max_limit = focuses[0].global_position
	min_limit = focuses[0].global_position
	for f in focuses:
		var pos = f.global_position
		max_limit.x = max(max_limit.x, pos.x)
		max_limit.y = max(max_limit.y, pos.y)
		min_limit.x = min(min_limit.x, pos.x)
		min_limit.y = min(min_limit.y, pos.y)


func set_focuses():
	focuses = get_tree().get_nodes_in_group("camera_focus")
	set_physics_process(true)
	update_camera()
