extends SxCVars

class _Vars:
    extends Object

    var test_boolean := false
    var test_string := "hello"
    var test_integer := 1
    var test_float := 2.5

    # For TestSxCVars
    var sprite_speed := 10.0
    var sprite_rotation := 0.0
    var sprite_color := Color.white

func _init() -> void:
    _vars = _Vars.new()
    SxDebugConsole.bind_cvars(self)
