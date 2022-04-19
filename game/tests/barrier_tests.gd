extends "res://tests/tests_base.gd"

var BallScn = load("res://ball/Ball.tscn")
var BarrierScn = load("res://Barrier.tscn")

var ball
var barrier

func before_each():
    ball = BallScn.instance()
    barrier = BarrierScn.instance()


func test_ball_hit_barrier_bounce():
    
    _setup_tree([barrier, ball])
    ball.position = Vector2(100, 0)
    barrier.position = Vector2.ZERO

    var collision = ball.move_and_collide(Vector2(-200, 0))
    assert_not_null(collision, "ball should collide")
    if (collision):
        assert_eq(collision.collider, barrier, "ball should collide with barrier")