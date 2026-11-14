extends Control

var sayings = ["The galaxy is under siege.\n\n\n\n\n\n\n[center][Press SPACE to continue][/center]",
"Intergalactic terrorists have already destroyed multiple solar systems... and now, they threaten to blot out our sun and plunge us into icy death.",
"Scientists around the world have found just one solution to save us from imminent destruction:",
"We need to rocket lemurs into the sun.",
"Nikola Tesla has appointed you as Lieutenant Lemur Lassoer.",
"Their only hope was to send a fly, resistant to the lamps' lure, able to extinguish mankind's defense once and for all.",
"You have one goal: [i]BREAK THE LAMPS.[/i]"]
var index = 0

func _ready() -> void:
	$RichTextLabel.text = sayings[index]
	index += 1
	$anim.play("scroll out")

func _process(delta: float) -> void:

	if Input.is_action_just_pressed("ui_accept"):
		if index == 3:
			$music.stop()
			$rockmusic.play()
			$RichTextLabel.text = sayings[index]
			index += 1
			$anim.play("scroll out", -1, 0.4)
		elif index < sayings.size():
			$RichTextLabel.text = sayings[index]
			index += 1
			$anim.play("scroll out")
		elif index == sayings.size():
				$anim.play("LAMPLIGHT")
				index += 1
		elif $anim.assigned_animation != "fade out":
			$anim.play("fade out")
			await $anim.animation_finished
			get_tree().change_scene_to_file("res://Scenes/game.tscn")
	
