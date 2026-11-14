extends Control

func _ready() -> void:
	$anim.play("crossover")
	await $anim.animation_finished
	get_tree().change_scene_to_file("res://Scenes/normal_ending.tscn")
