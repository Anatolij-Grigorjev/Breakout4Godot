extends "res://addons/gut/test.gd"


func test_fun_random_default_when_empty():
    var default = 5
    var afr = ArrayFunRandom.new([], default, 10)
    
    for _i in range(10):
        var fun_random = afr.get_fun_random()
        assert_eq(fun_random, default, "value " + str(default) + " is configured default")


func test_fun_random_respect_max_allowed():
    
    var afr = ArrayFunRandom.new([1, 2, 3], 0, 1)

    var latest_value = -1
    var num_times = 0
    for i in range(100):
        var random = afr.get_fun_random()
        if random == latest_value:
            num_times += 1
        else:
            latest_value = random
            num_times = 0
        assert_true(
            num_times <= afr.max_allowed_repeats + 1, 
            "picked value %s repeated %s time(-s) on iteration %s/%s" % [random, num_times, i + 1, 100]
        )