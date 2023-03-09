extends Control

onready var sprite := $Sprite as Sprite

var _velocity := SxRand.unit_vec2()

func _ready() -> void:
    pass

func _process(delta: float) -> void:
    var size := get_viewport().size
    var speed := GameCVars.get_cvar("sprite_speed") as float
    sprite.position += _velocity * delta * speed
    sprite.rotation += GameCVars.get_cvar("sprite_rotation") as float * delta

    if sprite.position.x > size.x || sprite.position.x < 0:
        _velocity.x *= -1
    if sprite.position.y > size.y || sprite.position.y < 0:
        _velocity.y *= -1

    var color := GameCVars.get_cvar("sprite_color") as Color
    sprite.modulate = color
