extends Control

@onready var sprite := $Sprite as Sprite2D

var _velocity := SxRand.unit_vec2()

func _ready() -> void:
    pass

func _process(delta: float) -> void:
    var vp_size := get_viewport_rect().size
    var speed := GameCVars.get_cvar("sprite_speed") as float
    sprite.position += _velocity * delta * speed
    sprite.rotation += GameCVars.get_cvar("sprite_rotation") as float * delta

    if sprite.position.x > vp_size.x || sprite.position.x < 0:
        _velocity.x *= -1
    if sprite.position.y > vp_size.y || sprite.position.y < 0:
        _velocity.y *= -1

    var color := GameCVars.get_cvar("sprite_color") as Color
    sprite.modulate = color
