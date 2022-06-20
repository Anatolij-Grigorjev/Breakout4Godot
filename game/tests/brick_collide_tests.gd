extends "res://tests/tests_base.gd"

var BallScn = load("res://ball/Ball.tscn")
var BricksScn = load("res://bricks/BricksMap.tscn")

var bricks
var ball

func before_each():
    bricks = BricksScn.instance();
    ball = BallScn.instance()


func test_ball_collide_bricks():
    # bricks and ball dont touch
    
    _setup_tree([bricks, ball])
    bricks.position = Vector2(100, 0)
    ball.position = Vector2(10, 0)
    
    #move ball into bricks
    var collision = ball.move_and_collide(Vector2(100, 0))
    assert_not_null(collision, "ball and bricks should collide!")
    if (collision):
        assert_eq(collision.collider, bricks, "ball should collide with bricks!")


func test_ball_collide_bricks_emit_signal():
    
    bricks.position = Vector2(100, 0)
    ball.position = Vector2(10, 0)
    _setup_tree([bricks, ball])
    watch_signals(bricks)

    ball.currentSpeed = 100.0
    ball.direction = Vector2.RIGHT
    gut.simulate(ball, 100, 0.1)
    
    assert_signal_emitted(bricks, "brickDestroyed", "destryong brick should emit signal")


func test_ball_collide_brick_lost():
    # bricks and ball dont touch

    bricks.position = Vector2(100, 0)
    ball.position = Vector2(10, 0)
    _setup_tree([bricks, ball])

    ball.currentSpeed = 100.0
    ball.direction = Vector2.RIGHT
    gut.simulate(ball, 100, 0.1)
    
    yield(_wait_next_frame(), "completed")

    #top left tile
    var tileCoord = Vector2.ZERO
    assert_eq(bricks.get_cellv(tileCoord), TileMap.INVALID_CELL)


func test_ball_collide_bricks_ball_faster_spin_quicker():

    bricks.position = Vector2(100, 0)
    ball.position = Vector2(10, 0)
    _setup_tree([bricks, ball])

    var initialBallSpeed = 100
    var initialRotation = deg2rad(360)

    ball.currentSpeed = initialBallSpeed
    ball.baseSpinRadians = initialRotation
    ball.direction = Vector2.RIGHT
    gut.simulate(ball, 100, 0.1)

    assert_gt(ball.currentSpeed, initialBallSpeed, "ball got faster after hitting brick")
    assert_gt(ball.currentSpinRadians, initialRotation, "ball spins quicker after hitting brick")
