extends KinematicBody2D


export(float) var speed: float = 150.0

onready var ballSparks = $Sprite/ParticlesBattery
onready var anim: AnimationPlayer = $AnimationPlayer


func _ready():
	pass # Replace with function body.


func _process(delta: float):
	var direction = Vector2(0, 0)
	if Input.is_action_pressed("ui_left"):
		direction.x = -1
	if Input.is_action_pressed("ui_right"):
		direction.x = 1
	
	move_and_collide(direction * speed * delta)


func ball_hit_at(global_hit_pos: Vector2, hit_normal: Vector2):
	anim.play("bounce_ball")
	ballSparks.fireNextParticleSystem(global_hit_pos)

