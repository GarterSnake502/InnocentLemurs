extends Node2D

var suns_remaining = 3

@onready var bumper = $bumperArea
@onready var cam = $Camera2D

@onready var canvas = $CanvasLayer
@onready var ptsLabel = $CanvasLayer/Points
@onready var sun1 = $CanvasLayer/sun1
@onready var sun2 = $CanvasLayer/sun2
@onready var sun3 = $CanvasLayer/sun3
@onready var nextWaveTime = $CanvasLayer/nextWaveTime
@onready var terroristMisslesRemainingLabel = $CanvasLayer/TerroristMisslesRemaining

@onready var explosionSfx = $explosion
@onready var gameOverSfx = $gameover
@onready var anim = $anim

const MAX_TIME = 18.0
const MAX_TERRORIST_MISSLES = 30
var time_remaining = MAX_TIME
var terrorist_missles = MAX_TERRORIST_MISSLES

const CROSSOVER_SCORE = 4500
const TESLA_SCORE = 5000

func _ready():
	print(str(Score.points))
	for i in range(0, 8):
		spawn_lemur()
		nextWaveTime.max_value = MAX_TIME

func _process(delta):
	_process_bumping(delta)
	_process_enclosure(delta)
	_process_spawn(delta)

# /// SPAWN /// #
const MAX_LEMUR_COUNT = 30
var spawn_interval = 1
var spawn_time_remaining = spawn_interval
func _process_spawn(delta):
	# spawn in pipes at intervals
	if spawn_time_remaining <= 0:
		if get_tree().get_nodes_in_group("lemurs").size() < MAX_LEMUR_COUNT:
			spawn_lemur()
		spawn_time_remaining = spawn_interval
	# damage if enough time elapses
	spawn_time_remaining -= delta
	time_remaining -= delta
	nextWaveTime.value = time_remaining
	if time_remaining <= 0:
		suns_remaining -= 1
		update_ui()
		restore_spawn_time()

func spawn_lemur():
	var lemur = load("res://Scenes/Lemur.tscn").instantiate()
	$Lemurs.add_child(lemur)

func restore_spawn_time():
	terrorist_missles -= 1
	terroristMisslesRemainingLabel.text = "Terrorist missles remaining: " + str(terrorist_missles)
	time_remaining = MAX_TIME
	if terrorist_missles <= 0:
		anim.play("win")
		$music.stop()
		await anim.animation_finished
		if Score.points >= TESLA_SCORE:
			get_tree().change_scene_to_file("res://Scenes/telsa_ending.tscn")
		elif Score.points >= CROSSOVER_SCORE:
			get_tree().change_scene_to_file("res://Scenes/crossover_ending.tscn")
		else:
			get_tree().change_scene_to_file("res://Scenes/normal_ending.tscn")

# /// UI /// #
func update_ui():
	ptsLabel.text = "Points: " + str(Score.points)
	if suns_remaining < 3 and sun3.visible:
		destroy_sun(sun3)
		sun2.texture = load("res://Assets/UI/sun-nervous-1.png")
		sun1.texture = load("res://Assets/UI/sun-nervous-1.png")
	if suns_remaining < 2 and sun2.visible:
		destroy_sun(sun2)
		sun1.texture = load("res://Assets/UI/sun-nervous-2.png")
	if suns_remaining < 1 and sun1.visible:
		destroy_sun(sun1)
	if suns_remaining <= 0:
		destroy_world()
	

func destroy_sun(sun):
	sun.texture = load("res://Assets/UI/sun-dead.png")
	explosionSfx.pitch_scale = randf_range(0.9, 1.1)
	explosionSfx.play()
	var explosion = load("res://Scenes/sun_explosion.tscn").instantiate()
	explosion.global_position = sun.global_position
	explosion.emitting = true
	canvas.add_child(explosion)
	anim.play("shake")
	await get_tree().create_timer(1.5).timeout
	sun.hide()

func destroy_world():
	$music.stop()
	anim.play("gameover")
	gameOverSfx.play()
	for child in canvas.get_children():
		if child.name != "black":
			child.hide()
	await anim.animation_finished
	get_tree().change_scene_to_file("res://Scenes/bad_ending.tscn")

# /// Enclosure /// #
@onready var enclosureLine = $enclosureLine
@onready var enclosureLineAnim = $enclosureLine/anim
var enclosing = false
var bumping = false
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				start_enclosure()
			else:
				stop_enclosure()
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				start_bumper()
			else:
				stop_bumper()

func start_bumper():
	bumper.show()
	bumper.monitoring = true
	bumping = true

func _process_bumping(delta):
	if bumping:
		var mouse_pos = get_global_mouse_position()
		bumper.position = mouse_pos

const BUMP_STRENGTH = 150
func bump(body):
	if body.is_in_group("lemurs"):
		body.start_jump(bumper.global_position.angle_to_point(body.global_position), BUMP_STRENGTH)
		body.bump_sfx()
		$Bouncy.play()

func stop_bumper():
	bumper.hide()
	bumper.monitoring = false
	bumping = false

func start_enclosure():
	enclosureLineAnim.stop()
	enclosureLine.modulate = Color(1,1,1)
	enclosing = true
	enclosureLine.clear_points()

func _process_enclosure(delta):
	if enclosing:
		var mouse_pos = get_global_mouse_position()
		add_enclosure_point(mouse_pos)

func stop_enclosure():
	enclosing = false
	check_diversity()
	enclosureLineAnim.play("fade")

func add_enclosure_point(point):
	enclosureLine.add_point(point)

const MIN_LEMURS = 3
func check_diversity():
	var poly = enclosureLine.points
	if poly.size() < 3:
		return # valid shape has >3 Score.points
	var enclosedLemurs = []
	for lemur in get_tree().get_nodes_in_group("lemurs"):
		if Geometry2D.is_point_in_polygon(enclosureLine.to_local(lemur.global_position), poly):
			enclosedLemurs.append(lemur)
	var enclosedAmount = len(enclosedLemurs)
	var enclosedColor = Color(0,0,0)
	var diverse = false
	for body in enclosedLemurs:
		if enclosedColor == Color(0,0,0):
			enclosedColor = body.color
		else:
			if body.color != enclosedColor:
				diverse = true
	if diverse:
		suns_remaining -= 1
		update_ui()
	elif enclosedAmount >= MIN_LEMURS:
		var pts = get_fib_pts(enclosedAmount)
		Score.points += pts * 100
		$"Lasso Fanfare".pitch_scale = 1 + (pts - 1) * 0.1
		$"Lasso Fanfare".play()
		for body in enclosedLemurs:
			body.collect(pts)
		update_ui()
		restore_spawn_time()
		var textFade = load("res://Scenes/fadeText.tscn").instantiate()
		textFade.global_position = get_global_mouse_position()
		textFade.text = "+" + str(pts * 100)
		add_child(textFade)

func get_fib_pts(value: int, start: int = MIN_LEMURS) -> int:
	if value < start:
		return 0
	return fib(value - start + 2)

func fib(n: int) -> int:
	var a = 1
	var b = 1
	for i in range(n - 1):
		var tmp = a + b
		a = b
		b = tmp
	return a
