extends Node2D

# /// Enclosure /// #
@onready var enclosureLine = $enclosureLine
var enclosing = false
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				start_enclosure()
			else:
				stop_enclosure()
		if event.button_index == MOUSE_BUTTON_RIGHT:
			check_diversity()

func start_enclosure():
	enclosing = true
	enclosureLine.clear_points()

func stop_enclosure():
	enclosing = false
	check_diversity()

func add_enclosure_point(point):
	enclosureLine.add_point(point)

func _process(delta):
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
	var enclosedAmount = len(enclosedLemurs)
	var enclosedColor = ""
	var diverse = false
	for body in enclosedLemurs:
		if enclosedColor == "":
			enclosedColor = body.color
		else:
			if body.color != enclosedColor:
				diverse = true
	if diverse:
		print("DIVERSITY ALERT!!")
	elif enclosedAmount > MIN_LEMURS:
		var pts = get_fib_pts(enclosedAmount)
		print("YOU GOT " + str(pts) + "PTS!!")

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
