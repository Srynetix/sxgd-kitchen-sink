extends Control

@onready var voice_a := $MarginContainer/VBoxContainer/GridContainer/A as SxFaButton
@onready var voice_b := $MarginContainer/VBoxContainer/GridContainer/B as SxFaButton
@onready var voice_c := $MarginContainer/VBoxContainer/GridContainer/C as SxFaButton
@onready var player := $SxAudioStreamPlayer as SxAudioStreamPlayer

func _ready() -> void:
    voice_a.pressed.connect(player.play_key.bind("explosion"))
    voice_b.pressed.connect(player.play_key.bind("laser"))
    voice_c.pressed.connect(player.play_key.bind("powerup"))
