extends Tween

enum Directions {UP, DOWN}

var direction = Directions.DOWN
var object
var speed = randf() + 1

func init(object):
	self.object = object
	loop_animation()

func loop_animation():
	if (direction == Directions.UP):
		self.interpolate_property(object, "position", object.position, object.position - Vector2(0, 5), speed, Tween.TRANS_CUBIC,Tween.EASE_IN)
		direction = Directions.DOWN
	else:
		self.interpolate_property(object, "position", object.position, object.position + Vector2(0, 5), speed, Tween.TRANS_CUBIC,Tween.EASE_IN)
		direction = Directions.UP
	self.start()
	yield(self, "tween_completed")
	loop_animation()