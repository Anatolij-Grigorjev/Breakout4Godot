# A configuration of powerup for a specific stage
# This takes a locally-pure function that is called on some owner
# this function accepts int type of broken brick and should return a 
# bool indicating if the powerup of this configu should drop
#
# not supplying owner and func name will just mean this never drops
class_name ScenePowerupConfig


var PowerupScn: PackedScene
var spawn_check_owner
var spawn_check_func_name: String


func _init(Scn, check_owner = null, checker_name: String = ''):
    self.PowerupScn = Scn
    self.spawn_check_owner = check_owner
    self.spawn_check_func_name = checker_name


func should_drop_for_brick(broken_brick_type: int) -> bool:

    if not spawn_check_owner or not spawn_check_func_name:
        return false
    return spawn_check_owner.call(spawn_check_func_name, broken_brick_type)


func new_drop_at_pos(global_position: Vector2) -> PowerupBase:
    var drop = PowerupScn.instance()
    drop.global_position = global_position
    drop.fall_rate = 100.0

    return drop