extends MarginContainer

onready var _label := $RichTextLabel as RichTextLabel

func _ready() -> void:
    _label.connect("meta_clicked", self, "_on_meta_clicked")

func _on_meta_clicked(meta) -> void:
    OS.shell_open(meta)
