extends "res://addons/gut/test.gd"

var BallScn = load("res://ball/Ball.tscn")
var BarrierScn = load("res://Barrier.tscn")

var parent
var ball
var barrier

func before_each():
    parent = Node2D.new()
    ball = BallScn.instance()
    barrier = BarrierScn.instance()


func test_ball_hit_barrier_bounce():
    parent.add_child(ball)
    parent.add_child(barrier)

    ball.position = Vector2(100, 0)
    barrier.position = Vector2.ZERO

    add_child_autofree(parent)
    _wait_next_frame()

    var collision = ball.move_and_collide(Vector2(-200, 0))
    assert_not_null(collision, "ball should collide")
    if (collision):
        assert_eq(collision.collider, barrier, "ball should collide with barrier")






func _wait_seconds(secs: float, message: String = "waiting..."):
    yield(yield_for(secs, message), YIELD)

func _wait_next_frame():
    _wait_seconds(0.16, "waiting for next frame...")