extends Control

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

@onready var sprite := $Sprite as Sprite2D

var _velocity := SxRand.unit_vec2()

func _ready() -> void:
    SxCVars.bind_collection(Vars.new())

func _process(delta: float) -> void:
    var vp_size := get_viewport_rect().size
    var speed := SxCVars.get_cvar("sprite_speed") as float
    sprite.position += _velocity * delta * speed
    sprite.rotation += SxCVars.get_cvar("sprite_rotation") as float * delta

    if sprite.position.x > vp_size.x || sprite.position.x < 0:
        _velocity.x *= -1
    if sprite.position.y > vp_size.y || sprite.position.y < 0:
        _velocity.y *= -1

    var color := SxCVars.get_cvar("sprite_color") as Color
    sprite.modulate = color
