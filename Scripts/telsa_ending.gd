extends Control

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") and !$anim.is_playing():
		$anim.play("fade")
		await $anim.animation_finished
		get_tree().change_scene_to_file("res://Scenes/Factory.tscn")
