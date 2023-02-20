extends Control

onready var _dialog := $SxFullScreenFileDialog as SxFullScreenFileDialog

func _ready() -> void:
    _dialog.connect("file_selected", self, "_on_file_selected")

func _on_file_selected(item: String) -> void:
    print("File selected: ", item)
