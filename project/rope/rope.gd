extends Line2D

onready var player = get_parent()
onready var hook = player.get_node('Hook')

func _ready():
	self.add_point(Vector2(0, 0))
	self.add_point(player.dir)

func _physics_process(delta):
	self.set_point_position(1, self.get_point_position(1) + delta)
