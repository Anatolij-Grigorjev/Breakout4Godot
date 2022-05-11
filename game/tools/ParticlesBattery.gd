extends Node2D
class_name ParticlesBattery
"""
A container for one-shot particle systems that will use them one after the 
other in a rolling selection fashion

Can be used to always have a system available in cases where 
one system is still recharging while another can be fired
"""
signal activeParticlesWillEmit(activeParticles)
signal activeParticlesEmitted(activeParticles)

onready var particleSystems: Array = []


var numSystems: int = 0
var currentSystemIdx: int = 0


func _ready():
	currentSystemIdx = 0
	particleSystems = _filterParticleSystemsChildren()
	numSystems = particleSystems.size()


func _filterParticleSystemsChildren() -> Array:
	var systems = []
	for node in get_children():
		if (node is Particles2D or node is CPUParticles2D):
			systems.push_back(node)
		
	return systems
	

func fireNextParticleSystem(global_particles_pos: Vector2, particles_rot: float = 0) -> void:
	if (numSystems == 0):
		return
		
	var particles = next_system()
	particles.global_position = global_particles_pos
	particles.rotation = particles_rot
	emit_signal("activeParticlesWillEmit", particles)
	particles.emitting = true
	emit_signal("activeParticlesEmitted", particles)


func next_system() -> Node2D:
	var particles = particleSystems[currentSystemIdx]
	currentSystemIdx = (currentSystemIdx + 1) % numSystems
	return particles
	
