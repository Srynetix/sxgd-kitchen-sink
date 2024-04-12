extends Node

class Vars:
    extends SxCVars.VarCollection

    var test_boolean := false
    var test_string := "hello"
    var test_integer := 1
    var test_float := 2.5

    # For TestSxCVars
    var sprite_speed := 10.0
    var sprite_rotation := 0.0
    var sprite_color := Color.WHITE

func _init() -> void:
    SxCVars.bind_collection(Vars.new())
