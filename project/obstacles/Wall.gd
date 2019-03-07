tool

extends Node2D

export (int)var size = 1000 setget set_size

var objects = ['bigbox', 'box', 'box2', 'box3', 'boxmetal', 'float2']


#func _ready():
#	update_pit()


func set_size(s):
	size = s
	for child in get_children():
		child.queue_free()
	