extends Control

onready var voice_a := $MarginContainer/VBoxContainer/GridContainer/A as SxFaButton
onready var voice_b := $MarginContainer/VBoxContainer/GridContainer/B as SxFaButton
onready var voice_c := $MarginContainer/VBoxContainer/GridContainer/C as SxFaButton
onready var player := $SxAudioStreamPlayer as SxAudioStreamPlayer

func _ready() -> void:
    voice_a.connect("pressed", player, "play_key", ["explosion"])
    voice_b.connect("pressed", player, "play_key", ["laser"])
    voice_c.connect("pressed", player, "play_key", ["powerup"])
