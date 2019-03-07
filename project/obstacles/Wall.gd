tool

extends Node2D

export (int)var size = 1000 setget set_size

var objects = ['Box', 'Roof', 'Tire']


#func _ready():
#	update_pit()


func set_size(s):
	size = s
	for child in get_children():
		child.queue_free()
	randomize()
	var current_size = 0
	while current_size < size:
		var Obj = load(str("res://obstacles/", objects[randi() % objects.size()],".tscn")).instance()
		var obj_size = Obj.get_node("Sprite").texture.get_size().x
		Obj.set_position(Vector2(current_size + obj_size/2, 0))
		add_child(Obj)
		current_size += obj_size
