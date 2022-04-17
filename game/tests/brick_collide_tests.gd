extends "res://addons/gut/test.gd"

var BallScn = load("res://ball/Ball.tscn")
var BricksScn = load("res://bricks/BricksMap.tscn")

var parent: Node2D
var bricks
var ball

func before_each():
    parent = Node2D.new()
    bricks = BricksScn.instance();
    ball = BallScn.instance()


func test_ball_collide_bricks():
    
    # bricks and ball dont touch
    _setup_tree_bricks_pos_ball_pos(
        Vector2(100, 0), 
        Vector2(10, 0)
    )

    #move ball into bricks
    var collision = ball.move_and_collide(Vector2(100, 0))
    assert_not_null(collision, "ball and bricks should collide!")
    if (collision):
        assert_eq(collision.collider, bricks, "ball should collide with bricks!")
    

func test_ball_collide_brick_lost():
    # bricks and ball dont touch
    _setup_tree_bricks_pos_ball_pos(
        Vector2(100, 0), 
        Vector2(10, 0)
    )

    ball.speed = 100.0
    ball.direction = Vector2.RIGHT
    gut.simulate(ball, 100, 0.1)
    #top left tile
    var tileCoord = Vector2.ZERO
    assert_eq(bricks.get_cellv(tileCoord), TileMap.INVALID_CELL)


func _setup_tree_bricks_pos_ball_pos(bricksPos: Vector2, ballPos: Vector2):
    parent.add_child(bricks);
    bricks.position = bricksPos
    parent.add_child(ball);
    ball.position = ballPos
    add_child_autofree(parent)
    _wait_next_frame()


func _wait_seconds(secs: float, message: String = "waiting..."):
    yield(yield_for(secs, message), YIELD)

func _wait_next_frame():
    _wait_seconds(0.16, "waiting for next frame...")
