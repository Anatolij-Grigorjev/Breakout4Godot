class_name ScenePowerupConfig


var PowerupScn: PackedScene
var brick_type_probabilities = {}
var max_times_in_scene
var caught_in_scene


func _init(Scn, probs, max_in_scene = -1):
    self.PowerupScn = Scn
    self.brick_type_probabilities = probs
    self.max_times_in_scene = max_in_scene if max_in_scene > 0 else 999
    self.caught_in_scene = 0


func can_spawn() -> bool:
    return max_times_in_scene > caught_in_scene


func should_drop_for_brick(brick_type: int) -> bool:
    var probability = Utils.nvl(brick_type_probabilities[brick_type], 0.0)
    return randf() < probability

func reset():
    caught_in_scene = 0