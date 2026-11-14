extends Control

var sayings = ["The galaxy is under siege.\n\n\n\n\n\n\n[center][Press SPACE to continue][/center]",
"Intergalactic terrorists have already destroyed multiple solar systems... and now, they threaten to blot out our sun and plunge us into eternal darkness.",
"Scientists around the world have found just one solution to save us from imminent destruction:",
"We need to rocket lemurs into the sun.",
"Nikola Tesla has appointed you as Lieutenant Lemur Lassoer.",
"Lasso at least 3 lemurs together to form space crews (the more lemurs, the better).",
"There is only one problem with this plan.",
"Lemurs of different colors do not get along.",
"[shake]Do not, under any circumstances, lasso lemurs of different colors together.[/shake]",
"If you accidentally lasso multi-colored lemurs three times, or take too long to send a lemur crew, the sun will immediately explode and everyone you love you die.",
"Nikola Tesla is counting on you.",
"And, well, the entire galaxy.",
"Have fun :)"
]
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
			get_tree().change_scene_to_file("res://Scenes/Factory.tscn")
	
