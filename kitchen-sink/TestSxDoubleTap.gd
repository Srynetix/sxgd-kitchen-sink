extends Control

onready var _double_tap := $SxDoubleTap as SxDoubleTap
onready var _label := $MarginContainer/VBoxContainer/Label as Label
var _timer: Timer

func _ready() -> void:
    _double_tap.connect("doubletap", self, "_on_double_tap")
    _timer = Timer.new()
    _timer.wait_time = 1
    _timer.one_shot = true
    _timer.autostart = false
    _timer.connect("timeout", self, "_on_timer_timeout")
    add_child(_timer)

func _on_double_tap(touch_idx: int) -> void:
    _timer.stop()

    _label.text = "DOUBLE TAP DETECTED WITH TOUCH IDX %d" % touch_idx
    _timer.start()

func _on_timer_timeout() -> void:
    _label.text = ""
