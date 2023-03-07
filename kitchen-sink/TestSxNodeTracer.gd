extends Control

const SPEED := 100

onready var _sprite := $Sprite as Sprite
onready var _sprite2 := $Sprite2 as Sprite
onready var _sprite3 := $Sprite3 as Sprite
onready var _sprite4 := $Sprite4 as Sprite

onready var velocities := {
    _sprite: SxRand.unit_vec2(),
    _sprite2: SxRand.unit_vec2(),
    _sprite3: SxRand.unit_vec2(),
    _sprite4: SxRand.unit_vec2(),
}


func _ready():
    for sprite in velocities:
        var tracer := sprite.get_node("NodeTracer") as SxNodeTracer
        tracer.trace_parameter("Modulate", sprite.modulate)


func _process(delta: float) -> void:
    for x in velocities:
        process_sprite(x, delta)


func process_sprite(sprite: Sprite, delta: float) -> void:
    var tracer := sprite.get_node("NodeTracer") as SxNodeTracer
    var size := get_viewport().size
    sprite.position += velocities[sprite] * delta * SPEED

    if sprite.position.x > size.x || sprite.position.x < 0:
        velocities[sprite].x *= -1
    if sprite.position.y > size.y || sprite.position.y < 0:
        velocities[sprite].y *= -1

    tracer.trace_parameter("Position", sprite.position)
    tracer.trace_parameter("Velocity", velocities[sprite])

func _show_panel():
    GameDebugTools.show()
    GameDebugTools.show_specific_panel(SxDebugTools.PanelType.NODE_TRACER)
