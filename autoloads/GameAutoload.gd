extends Node

func _ready() -> void:
    SxDebugTools.setup_global_instance(get_tree())
    SxSceneTransitioner.setup_global_instance(get_tree())
