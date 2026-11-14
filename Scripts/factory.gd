extends Node2D

var points = 0
var suns_remaining = 3

@onready var bumper = $bumperArea
@onready var cam = $Camera2D

@onready var canvas = $CanvasLayer
@onready var ptsLabel = $CanvasLayer/Points
@onready var sun1 = $CanvasLayer/sun1
@onready var sun2 = $CanvasLayer/sun2
@onready var sun3 = $CanvasLayer/sun3

@onready var explosionSfx = $explosion
@onready var gameOverSfx = $gameover
@onready var anim = $anim

# /// UI /// #
func update_ui():
	ptsLabel.text = "Points: " + str(points)
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
	anim.play("gameover")
	gameOverSfx.play()

# /// Enclosure /// #
@onready var enclosureLine = $enclosureLine
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

const BUMP_STRENGTH = 150
func bump(body):
	if body.is_in_group("lemurs"):
		body.start_jump(bumper.global_position.angle_to_point(body.global_position), BUMP_STRENGTH)

func stop_bumper():
	bumper.hide()
	bumper.monitoring = false
	bumping = false

func start_enclosure():
	enclosing = true
	enclosureLine.clear_points()

func stop_enclosure():
	enclosing = false
	check_diversity()

func add_enclosure_point(point):
	enclosureLine.add_point(point)

func _process(delta):
	if bumping:
		var mouse_pos = get_global_mouse_position()
		bumper.position = mouse_pos
	if enclosing:
		var mouse_pos = get_global_mouse_position()
		add_enclosure_point(mouse_pos)

const MIN_LEMURS = 6
func check_diversity():
	var poly = enclosureLine.points
	if poly.size() < 3:
		return # valid shape has >3 points
	var enclosedLemurs = []
	for lemur in get_tree().get_nodes_in_group("lemurs"):
		if Geometry2D.is_point_in_polygon(enclosureLine.to_local(lemur.global_position), poly):
			enclosedLemurs.append(lemur)
	print(enclosedLemurs)
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
		print("DIVERSITY ALERT!!")
		suns_remaining -= 1
		update_ui()
	elif enclosedAmount > MIN_LEMURS:
		var pts = get_fib_pts(enclosedAmount)
		points += pts * 100

func get_fib_pts(value: int, start: int = 6) -> int:
	if value < start:
		return 0
	return fib(value - start + 1)

func fib(n: int) -> int:
	var a = 1
	var b = 1
	for i in range(n - 1):
		var tmp = a + b
		a = b
		b = tmp
	return a
