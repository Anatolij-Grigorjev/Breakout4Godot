extends Node2D

export(float) var max_intensity_coef = 2.0

onready var sparks_1x = $ParticlesBattery
onready var sparks_2x = $ParticlesBattery2x
onready var sparks_3x = $ParticlesBattery3x


func _ready():
	# migrate sparks into parent scene for detached effect
	var paddle = get_parent()
	if not paddle:
		return
	var scene = paddle.get_parent()
	if not scene:
		return
	
	call_deferred("_reparent_fx_to_scene", scene)


func fire_hit_sparks(spark_position: Vector2, intensity_coef: float):
	var ballSparks = _pick_sparks_for_hit(intensity_coef)
	ballSparks.fireNextParticleSystem(spark_position)
	
	
func _pick_sparks_for_hit(intensity_coef: float) -> CPUParticles2D:
	if intensity_coef < max_intensity_coef / 2:
		return sparks_1x
	elif intensity_coef < max_intensity_coef:
		return sparks_2x
	else:
		return sparks_3x



func _reparent_fx_to_scene(scene: Node2D):
	for fx in [sparks_1x, sparks_2x, sparks_3x]:
		fx.get_parent().remove_child(fx)
		scene.add_child(fx)
