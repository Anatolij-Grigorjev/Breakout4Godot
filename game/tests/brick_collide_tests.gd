extends "res://addons/gut/test.gd"

var GameScn = load("res://BreakoutGame.tscn")
var BallScn = load("res://ball/Ball.tscn")
var BricksScn = load("res://bricks/BricksMap.tscn")

func test_ball_collide_bricks():

    var parent = Node2D.new()
    var bricks = BricksScn.instance();
    var ball = BallScn.instance()
    # bricks and ball dont touch
    parent.add_child(bricks);
    bricks.position = Vector2(100, 0)
    parent.add_child(ball);
    ball.position = Vector2(10, 0)
    add_child_autofree(parent)
    yield(yield_for(0.1, "waiting for parent to settle in..."), YIELD)
    #move ball into bricks
    var collision = ball.move_and_collide(Vector2(100, 0))
    assert_not_null(collision, "ball and bricks should collide!")
    assert_eq(collision.collider, bricks, "ball should collide with bricks!")
    
