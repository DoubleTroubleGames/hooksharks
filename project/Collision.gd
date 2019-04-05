extends Node

enum {PLAYER_ABOVE = 1, PLAYER_BELOW = 2, OBSTACLE = 4, FLOATING_OBSTACLE = 8,
		TRAIL = 16, POWERUP = 32, HOOK = 64, CHECKPOINT = 128,
		FINISH_LINE = 256, MEGAHOOK = 512, PULLABLE_OBJECT = 1024}


func placeholder(area):
	match area.collision_layer:
		Collision.PLAYER_ABOVE:
			pass
		Collision.PLAYER_BELOW:
			pass
		Collision.OBSTACLE:
			pass
		Collision.FLOATING_OBSTACLE:
			pass
		Collision.TRAIL:
			pass
		Collision.POWERUP:
			pass
		Collision.HOOK:
			pass
		Collision.CHECKPOINT:
			pass
		Collision.FINISH_LINE:
			pass
		Collision.MEGAHOOK:
			pass
		Collision.PULLABLE_OBJECT:
			pass