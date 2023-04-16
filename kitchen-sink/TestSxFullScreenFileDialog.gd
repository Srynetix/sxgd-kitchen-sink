extends Control

@onready var _dialog := $SxFullScreenFileDialog as SxFullScreenFileDialog

func _ready() -> void:
    _dialog.file_selected.connect(_on_file_selected)

func _on_file_selected(item: String) -> void:
    print("File selected: ", item)
