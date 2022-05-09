extends "res://tests/tests_base.gd"


const LivesCounterScn = preload("res://gui/livesCounter.tscn")

var livesCounter

func before_each():
    livesCounter = LivesCounterScn.instance()
    livesCounter.numExtraBalls = 3



func test_increasing_num_lives_adds_children():

    _setup_tree([livesCounter])
    var newAmount = 5
    livesCounter.numExtraBalls = newAmount

    _wait_next_frame()

    assert_eq(livesCounter.ballsContainer.get_child_count(), newAmount)


func test_decrese_num_lives_removes_children():

    _setup_tree([livesCounter])
    var newAmount = 1
    var originalAmount = livesCounter.numExtraBalls
    livesCounter.numExtraBalls = newAmount

    _wait_next_frame()

    var freeingNodes = []
    for ball in livesCounter.ballsContainer.get_children():
        if ball.is_queued_for_deletion():
            freeingNodes.append(ball)

    assert_eq(freeingNodes.size(), originalAmount - newAmount)


func test_num_lives_cant_be_negative():

    _setup_tree([livesCounter])
    var newAmount = -7
    livesCounter.numExtraBalls = newAmount

    _wait_next_frame()
    var remainingNodes = []
    for ball in livesCounter.ballsContainer.get_children():
        if not ball.is_queued_for_deletion():
            remainingNodes.append(ball)
    
    assert_eq(livesCounter.numExtraBalls, 0)
    assert_eq(remainingNodes.size(), 0)
    

