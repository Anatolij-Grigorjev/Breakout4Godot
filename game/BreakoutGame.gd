extends Node2D

const FlashPointsScn = preload("res://gui/ScoredPoints.tscn")
const BallTrailScn = preload("res://ball/BallTrail.tscn")
const BallScn = preload("res://ball/Ball.tscn")
const CameraShakeDampenerScn = preload("res://tools/CameraShakeDampener.tscn")

#powerups
const PowerupPointsScn = preload("res://drops/PowerupPoints.tscn")
const PowerupExtraBallScn = preload("res://drops/PowerupExtraBall.tscn")
const PowerupSpeedupBallScn = preload("res://drops//PowerupSpeedupBall.tscn")
const PowerupSlowdownBallScn = preload("res://drops//PowerupSlowdownBall.tscn")


#breaking shouts
const BreakShoutTemplate1 = preload("res://bricks/BreakShout1.tscn")
var break_templates = [
	BreakShoutTemplate1
]
var break_words = ["SLAY!!!", "WHAM!!!", "WHACK!!!", "KAPOW!!!", "OOF!!!", "YASS!!!"]

signal game_over(total_score)



export(int) var starting_num_balls = 4
export(PackedScene) var bricksScn
export(String) var bricks_config_filepath


onready var bg = $BG/Background
onready var paddle = $Paddle
onready var ballSmokes = $ParticlesBattery
onready var camera = $Camera2D
onready var cameraShake = $Camera2D/ScreenShake

onready var scoreCounter = $GUI/GameHUD/ScoresHUD/AccumCounter
onready var livesCounter = $GUI/GameHUD/LowerHUD/LivesHUD/MarginContainer/LivesCounter
onready var gameEndMessage = $GUI/GameEndMessage
onready var overlay = $GUI/Overlay
onready var ballLossArea = $BallLossArea

var currentScore := 0
var base_bricks_shake_dampen_coef := 0.5

var stageFinished = false

var powerup_configs = []


var bricks: Node2D
var bricks_shake_dampener: Node2D


func _ready():
	
	scoreCounter.value = currentScore

	livesCounter.numExtraBalls = starting_num_balls

	bricks = _build_and_configure_stage_bricks(bricksScn, bricks_config_filepath)
	bricks_shake_dampener = _attach_shake_dampener_to_bricks(bricks, CameraShakeDampenerScn)

	bricks.connect("brick_destroyed", self, "_on_brick_destroyed")
	bricks.connect("brick_damaged", self, "_on_brick_damaged")
	bricks.connect("map_cleared", self, "_on_bricksmap_cleared")
	ballLossArea.connect("ball_fell", self, "_on_ball_fallen")

	paddle.connect("request_launch_ball", self, "_on_paddle_new_ball_requested")

	var dropConfigPoints = ScenePowerupConfig.new(PowerupPointsScn, self, "_should_points_drop")
	var dropConfigSpeedupBall = ScenePowerupConfig.new(PowerupSpeedupBallScn, self, "_should_speedup_drop")
	var dropConfigSlowdownBall = ScenePowerupConfig.new(PowerupSlowdownBallScn, self, "_should_slowdown_drop")
	var dropConfigExtraBall = ScenePowerupConfig.new(PowerupExtraBallScn, self, "_should_extra_ball_drop")

	powerup_configs = [
		dropConfigPoints, 
		dropConfigSpeedupBall, 
		dropConfigSlowdownBall, 
		dropConfigExtraBall
	]

	_reset_stage()



func _build_and_configure_stage_bricks(bricksScn: PackedScene, bricks_config_filepath: String) -> Node2D:
	var new_bricks = bricksScn.instance()
	var configs_map = Utils.file2JSON(bricks_config_filepath)

	new_bricks.brick_type_transitions = configs_map.brick_type_transitions
	new_bricks.points_for_brick_of_type = configs_map.points_for_brick_of_type

	add_child_below_node(camera, new_bricks)
	new_bricks.position = Vector2(configs_map.starting_pos.x, configs_map.starting_pos.y)

	return new_bricks


func _attach_shake_dampener_to_bricks(bricks: Node2D, DampenerScn: PackedScene) -> Node2D:

	var new_dampener = DampenerScn.instance()
	new_dampener.camera_node_path = camera.get_path()
	
	bricks.add_child(new_dampener)

	return new_dampener


func _should_points_drop(brick_type: int) -> bool:
	return randf() < 0.12


func _should_speedup_drop(brick_type: int) -> bool:
	var stage_balls = _get_active_balls()
	var max_probability = 0.3
	for ball in stage_balls:
		var speedupDiff = ball.currentSpeedupCoef() - 1.0
		var speed_to_probability_coef = max_probability / (ball.maxSpeedCoef - 1.0)
		#if not probable for this ball (is at max speed), then skip
		var probability = max_probability - speedupDiff * speed_to_probability_coef
		if probability < 0.001:
			continue
		else:
			return randf() < probability

	return false


func _should_slowdown_drop(brick_type: int) -> bool:
	var stage_balls = _get_active_balls()
	var max_probability = 0.3
	for ball in stage_balls:
		var speedupDiff = ball.currentSpeedupCoef() - 1.0
		var speed_to_probability_coef = max_probability / (ball.maxSpeedCoef - 1.0)
		#if not probable for this ball (is at lowest speed), then skip
		var probability = speedupDiff * speed_to_probability_coef
		if probability < 0.001:
			continue
		else:
			return randf() < probability

	return false


func _should_extra_ball_drop(brick_type: int) -> bool:
	var num_balls = livesCounter.numExtraBalls
	if num_balls > 1:
		return false
	return randf() < 0.07


func _process(delta):
	if stageFinished and Input.is_action_just_released("ui_accept"):
		_reset_stage()



func _reset_stage():
	stageFinished = false
	_hide_stage_end_message()

	for ball in _get_active_balls():
		ball.queue_free()
	
	paddle.enable_control()

	scoreCounter.value = 0.0
	livesCounter.numExtraBalls = starting_num_balls
	bricks.reset_bricks()
	bricks_shake_dampener.shake_dampen_coef = base_bricks_shake_dampen_coef



func _on_paddle_new_ball_requested():
	if livesCounter.numExtraBalls <= 0 or paddle.ball_attached:
		return
	
	livesCounter.numExtraBalls -= 1
	var new_ball = _create_new_ball()
	paddle.attach_ball(new_ball)



func _on_ball_collided(ball: Ball, collision: KinematicCollision2D):
	
	if (collision.collider.is_in_group("bricks")):
		var speed_shake_coef = 1.0
		cameraShake.beginShake(0.2, 15 * speed_shake_coef, 10 * speed_shake_coef, 1)
		_fire_collision_particles(collision)
		bg.do_pulse(ball.currentSpeedupCoef())



func _on_ball_speed_changed(ball: Ball):
	var ball_speed_coef_completeness = ball.currentSpeedupCoef() / max(0.1, ball.maxSpeedCoef)
	bricks_shake_dampener.shake_dampen_coef = base_bricks_shake_dampen_coef - ball_speed_coef_completeness



func _on_brick_damaged(tile_idx: Vector2, old_type: int, new_type: int):
	print("brick at %s changed type: %s -> %s" % [tile_idx, old_type, new_type])


func _on_brick_destroyed(ball: Ball, type: int, tileIdx: Vector2):

	var brickPoints = _get_points_for_brick_type(ball, type)
	# brick position is relative to tilemap parent
	var brick_origin_pos = bricks.map_to_world(tileIdx) + bricks.position
	var global_brick_center = brick_origin_pos + bricks.cell_size / 2

	_add_scored_points_bubble(global_brick_center, brickPoints)
	scoreCounter.value += brickPoints

	_process_drop_powerup(type, global_brick_center)
	_add_random_shout_at(global_brick_center)

	

func _on_paddle_collected_drop(drop_points: float):
	_glow_paddle_collected_drop()
	if drop_points > 0:
		_on_paddle_collected_points(drop_points)


func _process_drop_powerup(brick_type, start_global_pos):

	for dropConfig in powerup_configs:
		if (dropConfig as ScenePowerupConfig).should_drop_for_brick(brick_type):
			_start_drop_of_scene(dropConfig, start_global_pos)
			return

	return


func _start_drop_of_scene(drop_config: ScenePowerupConfig, global_pos: Vector2):

	var drop = drop_config.new_drop_at_pos(global_pos)
	#triggers signal connection to named method
	drop.start_in_stage(self)



func _on_paddle_collected_ball_speedup(speedup_coef: float):

	if paddle.ball_attached:
		return

	var active_balls = _get_active_balls()
	for ball_idx in range(active_balls.size()):
		var ball = active_balls[ball_idx]
		ball.glow_blue()
		var additive = ball.speed_additive_for_coef(speedup_coef)
		var prev_ball_speed = ball.currentSpeed
		ball.speedup_ball_by_amount(additive)
		var additive_prc = abs(100.0 - (ball.currentSpeed * 100.0 / max(prev_ball_speed, 0.001)))
		_add_flashing_text_above_paddle(
			paddle.global_position - Vector2(-50 - 50 * ball_idx, 15), "+%01d%%" % additive_prc
		)

		

func _on_paddle_collected_ball_slowdown(slowdown_coef: float):

	if paddle.ball_attached:
		return

	var active_balls = _get_active_balls()
	for ball_idx in range(active_balls.size()):
		var ball = active_balls[ball_idx]
		ball.glow_red()
		var additive = ball.speed_additive_for_coef(slowdown_coef)
		var prev_ball_speed = ball.currentSpeed
		ball.speedup_ball_by_amount(-additive)
		var additive_prc = abs(100.0 - (ball.currentSpeed * 100.0 / max(prev_ball_speed, 0.001)))
		_add_flashing_text_above_paddle(
			paddle.global_position - Vector2(-50 - 50 * ball_idx, 15), "-%01d%%" % additive_prc
		)



func _on_paddle_collected_extra_ball():
	livesCounter.numExtraBalls += 1


func _on_paddle_collected_points(amount: float):
	scoreCounter.value += amount
	_add_scored_points_bubble(paddle.global_position, amount)
	


func _glow_paddle_collected_drop():
	paddle.get_node("AnimationPlayer").play("glow_red")


func _on_ball_fallen(ball):

	var num_balls_in_scene = _get_active_balls().size()
	if num_balls_in_scene > 1:
		ball.queue_free()
		return
	if (livesCounter.numExtraBalls <= 0):
		emit_signal("game_over", scoreCounter.value)
		_stop_current_stage_activity()
		_show_stage_end_message("GAME OVER :(\nSCORE: " + str(scoreCounter.value))
	else:
		livesCounter.numExtraBalls -= 1
		remove_child(ball)
		paddle.attach_ball(ball)


func _on_bricksmap_cleared(cleared_bricks: int):
	print("cleared brickmap with %s bricks" % cleared_bricks)
	_stop_current_stage_activity()
	_show_stage_end_message("!!!SUCCESS!!!\nSCORE: " + str(scoreCounter.value))


func _stop_current_stage_activity():
	stageFinished = true
	for ball in _get_active_balls():
		ball.currentSpeed = 0.0
	for drop in get_tree().get_nodes_in_group("drop"):
		drop.queue_free()
	paddle.disable_control()



func _show_stage_end_message(message: String):
	overlay.get_node("AnimationPlayer").play("fade_in")
	gameEndMessage.visible = true
	gameEndMessage.get_node("HBoxContainer/Label").text = message
	gameEndMessage.get_node("AnimationPlayer").play("show")


func _hide_stage_end_message():
	gameEndMessage.visible = false
	overlay.get_node("AnimationPlayer").play("fade_out")
	gameEndMessage.get_node("AnimationPlayer").play("RESET")


func _get_points_for_brick_type(ball: Ball, type: int) -> float:
	return bricks.get_points_for_brick_type(type) * ball.currentSpeedupCoef()


func _fire_collision_particles(collision: KinematicCollision2D):
	var particlesPos = collision.position - (collision.normal * 10)
	var particlesRotation = collision.normal.angle()
	ballSmokes.fireNextParticleSystem(particlesPos, particlesRotation)


func _add_random_shout_at(shout_origin: Vector2):

	var shout_template = Utils.randomElement(break_templates) as PackedScene
	var new_shout = shout_template.instance()
	new_shout.text = Utils.randomElement(break_words)
	new_shout.global_position = shout_origin
	new_shout.direction = Utils.randomPoint(-1, 1)
	add_child(new_shout)




func _add_scored_points_bubble(score_origin: Vector2, points: float):
	_add_flashing_text_above_paddle(
		score_origin - Vector2(0, 15), 
		"+%s" % int(points)
	)


func _add_flashing_text_above_paddle(global_position: Vector2, text: String):
	var flashPoints = FlashPointsScn.instance()
	flashPoints.global_position = global_position
	flashPoints.text = text
	add_child(flashPoints)


func _get_active_balls() -> Array:
	return get_tree().get_nodes_in_group("ball")

func _create_new_ball() -> Ball:
	var ball =  BallScn.instance()
	ball.connect("ball_collided", self, "_on_ball_collided")
	ball.connect("ball_speed_changed", self, "_on_ball_speed_changed")
	return ball
