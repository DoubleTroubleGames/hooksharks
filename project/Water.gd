tool
extends ColorRect

func _ready():
	pass

func _on_Water_resized():
	$Waves.material.set_shader_param("rect_size", self.rect_size)
