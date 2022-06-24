"""
The class provides stateful algorithms to pick a random array element in a way that is more
'fun' for the player but is actually less truly mathematically random.
The idea is to make sure same values dont get picked too often to seem not fun even if the picking is actually random
"""
class_name ArrayFunRandom


var max_allowed_repeats: int


var elems: Array = []
var empty_default
var prev_random_value


var value_repeats: Dictionary = {}



func _init(elems: Array = [], empty_default = null, max_allowed_repeats: int = 1):
	self.elems = elems
	self.empty_default = empty_default
	self.prev_random_value = empty_default
	self.max_allowed_repeats = max_allowed_repeats
	for elem in elems:
		value_repeats[elem] = 0


"""
Get random element from backing array. 
The 'fun' part makes sure same value is not provided more often than 'max_allowed_repeats' times
"""
func get_fun_random():
	if (elems == null or elems.empty()):
		return empty_default
	if (elems.size() == 1):
		return elems[0]
	
	var rand_idx = randi() % elems.size()
	var random_value = elems[rand_idx]



	if random_value != prev_random_value:
		
		value_repeats[prev_random_value] = 0

	else:
		if (_is_value_too_frequent(random_value)):
			var least_used_value = _get_least_used_random()
			value_repeats[random_value] = 0
			random_value = least_used_value
		
		else:
			value_repeats[random_value] += 1

	prev_random_value = random_value
	return random_value


func _is_value_too_frequent(value) -> bool:
	return value_repeats[value] > max_allowed_repeats


func _get_least_used_random():

	if value_repeats.empty():
		return empty_default
		
	var lowest_uses = max_allowed_repeats + 1
	var least_used = value_repeats.keys()[0]
	for value in value_repeats:
		if value_repeats[value] < lowest_uses:
			lowest_uses = value_repeats[value]
			least_used = value
	
	return least_used