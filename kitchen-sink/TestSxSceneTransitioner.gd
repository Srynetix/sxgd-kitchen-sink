extends Control

func pressed():
    var instance := SxSceneTransitioner.get_global_instance(get_tree())
    instance.fade_to_scene_path("res://SxSceneRunner.tscn")
