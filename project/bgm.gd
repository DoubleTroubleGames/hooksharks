extends AudioStreamPlayer

func _ready():
	self.play()
	for child in get_children():
		child.playing = false
