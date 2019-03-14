tool
extends ColorRect

func _ready():
	pass

func _on_Water_resized():
	print("TU8")
	$Waves.material.set_shader_param("rect_size", self.rect_size)
