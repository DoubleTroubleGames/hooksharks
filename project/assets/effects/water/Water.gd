tool
extends ColorRect


func _ready():
	pass


func refresh_rect_size():
	$Waves.material.set_shader_param("rect_size", self.rect_size)
