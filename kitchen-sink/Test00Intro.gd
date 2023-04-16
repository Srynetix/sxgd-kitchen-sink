extends MarginContainer

@onready var _label := $RichTextLabel as RichTextLabel

func _ready() -> void:
    _label.meta_clicked.connect(_on_meta_clicked)

func _on_meta_clicked(meta) -> void:
    OS.shell_open(meta)
