extends Control

func _ready():
	$AnimationPlayer.play("fly")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		$AnimationPlayer.play("fadeout")
		await $AnimationPlayer.animation_finished
		get_tree().change_scene_to_file("res://Scenes/Factory.tscn")
