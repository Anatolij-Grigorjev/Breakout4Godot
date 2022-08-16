extends KinematicBody2D
class_name Ball

signal ball_collided(ball, collision)
signal ball_speed_changed(ball)

onready var anim: AnimationPlayer = $AnimationPlayer
onready var glow_anim: AnimationPlayer = $GlowAnimationPlayer
onready var sprite: Sprite = $Sprite
onready var hit_ball_sparks: ParticlesBattery = $ParticlesBattery
onready var coef_label: Label = $Label
onready var coef_label_anim: AnimationPlayer = $Label/AnimationPlayer

export(float) var bounceSpeedupCoef: float = 1.05
export(float) var maxSpeedCoef: float = 3.0

export(float) var baseSpeed: float = 145.0
export(float) var baseSpinDegrees: float = 360.0
export(Vector2) var direction := Vector2.DOWN

var baseSpinRadians: float = deg2rad(baseSpinDegrees)
var bounce_speed_additive: float = speed_additive_for_coef(bounceSpeedupCoef)
var spinAdditive: float = baseSpinRadians * bounceSpeedupCoef - baseSpinRadians
var maxBallSpeed: float = maxSpeedCoef * baseSpeed

var currentSpeed setget _set_current_speed_and_broadcast
var currentSpinRadians
var colliderSize: Vector2


func _ready():
	reset_speed()
	colliderSize = Vector2.ONE * $CollisionShape2D.shape.radius * 2.0

func reset_speed():
	_set_current_speed_and_broadcast(baseSpeed)
	currentSpinRadians = baseSpinRadians
	direction = Vector2.DOWN


func stop():
	_set_current_speed_and_broadcast(0)
	currentSpinRadians = 0


func disable_paddle_collisions():
	set_collision_mask_bit(1, false)
	set_collision_layer_bit(2, false)


func enable_paddle_collisions():
	set_collision_mask_bit(1, true)
	set_collision_layer_bit(2, true)


func currentSpeedupCoef() -> float:
	return currentSpeed / max(baseSpeed, 1.0)


func is_at_max_speed() -> bool:
	return currentSpeed == maxBallSpeed


# an amount of speed that shoud be added to ball in absolute speed units,
# expressed as coefficient of base ball speed (above 1.00)
func speed_additive_for_coef(coef: float) -> float:
	return baseSpeed * coef - baseSpeed


func _process(delta: float):
	var collision: KinematicCollision2D = move_and_collide(direction * currentSpeed * delta)
	sprite.rotate(currentSpinRadians * delta)
	_handle_potential_collision(collision)
		

func glow_blue():
	_glow_with_particles_and_label("glow_blue", $CPUParticles2DBlue, "raising")


func glow_red():
	_glow_with_particles_and_label("glow_red", $CPUParticles2DRed, "lowering")


func _glow_with_particles_and_label(glow_anim_name, particles_node, label_anim_name):
	glow_anim.play(glow_anim_name)
	particles_node.emitting = true
	coef_label.visible = true
	if coef_label_anim.is_playing():
		coef_label_anim.stop()
	coef_label_anim.play(label_anim_name)



## called by animation track to end glowing
func _stop_glowing():
	glow_anim.stop()
	$CPUParticles2DBlue.emitting = false
	$CPUParticles2DRed.emitting = false
	$Sprite/GlowFX.material.set_shader_param("outline_width", 0.0)
	coef_label.visible = false


func _set_current_speed_and_broadcast(new_speed_val: float):
	if new_speed_val == currentSpeed:
		return
	currentSpeed = new_speed_val
	var high_speed_prc = currentSpeedupCoef()
	coef_label.text = "x%.2f" % high_speed_prc
	sprite.material.set_shader_param("radius", max(0.0, high_speed_prc))
	emit_signal("ball_speed_changed", self)


func _handle_potential_collision(collision: KinematicCollision2D):
	if (not collision):
		return
	
	var next_direction = direction.bounce(collision.normal)


	if not collision.collider.is_in_group("barrier"):
		sprite.rotation = collision.normal.angle()

	if collision.collider.is_in_group("ball"):
		hit_ball_sparks.fireNextParticleSystem(collision.position)
	
	if collision.collider.is_in_group("bricks"):
		glow_blue()
		speedup_ball()
		anim.play("hit-squish")
		var tilemap: BricksMap = collision.collider as BricksMap
		tilemap.bricks_hit_at_by_ball(self, collision.position, collision.normal)
	
	if collision.collider.is_in_group("paddle"):
		var paddle = collision.collider
		var ball_hit_paddle_bumper = paddle.ball_hit_at(collision.position, currentSpeedupCoef())
		#if on way down the ball hits a bumper slanted in the same direction, 
		# it will keep going down and roll off paddle
		# to prevent that we reverse gravity and force it to bounce
		if ball_hit_paddle_bumper and next_direction.y > 0.0:
			next_direction.y *= -1
		next_direction = (next_direction + paddle.velocity.normalized()).normalized()

	
	direction = _adjust_horizontal_bounce_direction(next_direction, collision.collider)
	
	emit_signal("ball_collided", self, collision)


func speedup_ball():
	speedup_ball_by_amount(bounce_speed_additive)


func speedup_ball_by_amount(speedup_amount: float):
	_set_current_speed_and_broadcast(clamp(currentSpeed + speedup_amount, baseSpeed, baseSpeed * maxSpeedCoef))
	currentSpinRadians = clamp(baseSpinRadians + spinAdditive * currentSpeedupCoef(), baseSpinRadians, baseSpinRadians * 2.0 * maxSpeedCoef)


func _adjust_horizontal_bounce_direction(original_direction: Vector2, collider: Node2D) -> Vector2:
	var current_angle = original_direction.angle()
	var allowed_adjustmenet = rand_range(PI / 12, PI / 6)
	var new_direction = original_direction
	if abs(current_angle) < PI / 6:
		new_direction = new_direction.rotated(sign(current_angle) * allowed_adjustmenet)
		print("(on %s): land angle: %s deg. not exciting, adjusted for %s deg. to %s deg." % [collider, rad2deg(current_angle), rad2deg(allowed_adjustmenet), rad2deg(new_direction.angle())])
	elif abs(current_angle) > PI * 5 / 6:
		new_direction = new_direction.rotated(-sign(current_angle) * allowed_adjustmenet)
		print("(on %s): land angle: %s deg. not exciting, adjusted for %s deg. to %s deg." % [collider, rad2deg(current_angle), rad2deg(allowed_adjustmenet), rad2deg(new_direction.angle())])
	return new_direction
