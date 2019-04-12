extends CanvasLayer

var CrateParticleMaterial = preload("res://fx/crates/materials/crate_particle.material")
var TrailParticleMaterial = preload("res://fx/trails/trail.material")

var materials = [
    CrateParticleMaterial,
	TrailParticleMaterial
]

func _ready():
    for material in materials:
        var particles_instance = Particles2D.new()
        particles_instance.set_process_material(material)
        particles_instance.set_one_shot(true)
        particles_instance.set_emitting(true)
        self.add_child(particles_instance)