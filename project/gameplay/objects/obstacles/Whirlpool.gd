tool
extends Node2D

export(float) var whirl_size = 20 setget new_whirlpool_size
export(float) var death_size = 10 setget new_death_size

export(float) var pull_force = 100

func _ready():
	pass

func new_whirlpool_size(new_size):
	$PullingWave.scale = Vector2(new_size, new_size)
	whirl_size = new_size

func new_death_size(new_size):
	$DeathZone.scale = Vector2(new_size, new_size)
	death_size = new_size