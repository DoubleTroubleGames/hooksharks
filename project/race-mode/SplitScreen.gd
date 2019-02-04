extends Node

onready var viewport1 = $Viewports/ViewportContainer1/Viewport
onready var viewport2 = $Viewports/ViewportContainer2/Viewport
onready var camera1 = $Viewports/ViewportContainer1/Viewport/Camera2D
onready var camera2 = $Viewports/ViewportContainer2/Viewport/Camera2D
onready var world = $Viewports/ViewportContainer1/Viewport/Race

func _ready():
	viewport2.world_2d = viewport1.world_2d
	camera1.target = world.get_node("Players/Player1")
	camera2.target = world.get_node("Players/Player2")
