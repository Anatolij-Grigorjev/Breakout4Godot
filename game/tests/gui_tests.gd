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


func _IGNORED_test_decrese_num_lives_removes_children():

    _setup_tree([livesCounter])
    var newAmount = 1
    livesCounter.numExtraBalls = newAmount

    _wait_seconds(1.5)

    assert_eq(livesCounter.ballsContainer.get_child_count(), newAmount)
