extends "res://tests/tests_base.gd"

var BallScn = load("res://ball/Ball.tscn")
var PaddleScn = load("res://paddle/Paddle.tscn")
var BarrierScn = load("res://Barrier.tscn")

var ball
var paddle
var barrier


func before_each():
    ball = BallScn.instance()
    paddle = PaddleScn.instance()
    barrier = BarrierScn.instance()


func test_ball_hit_paddle():

    ball.position = Vector2(0, -100)
    paddle.position = Vector2.ZERO

    _setup_tree([ball, paddle])

    var collision = ball.move_and_collide(Vector2(0, 200))
    assert_not_null(collision, "paddle and ball collide")
    if (collision):
        assert_eq(collision.collider, paddle)


func test_ball_hit_paddle_not_brick_anim():
    
    ball.position = Vector2(0, -100)
    paddle.position = Vector2.ZERO

    watch_signals(ball)

    _setup_tree([ball, paddle])

    ball.direction = Vector2(0, 1)
    ball.baseSpeed = 100

    gut.simulate(ball, 101, 0.1)

    assert_signal_emitted(ball, "ball_collided", "ball didnt collide with paddle")
    assert_false(ball.anim.current_animation == "hit-squish")


func test_move_paddle_hits_barrier():

    paddle.position = Vector2(-100, 0)
    barrier.position = Vector2.ZERO
    _setup_tree([paddle, barrier])

    var collision = paddle.move_and_collide(Vector2(100, 0))

    assert_not_null(collision, "paddle and barrier collide")
    if (collision):
        assert_eq(collision.collider, barrier)