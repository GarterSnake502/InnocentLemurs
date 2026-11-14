extends CharacterBody2D

const GRAVITY = 10
const JUMP_SPEED = 32
const START_JUMP_VEL = -3

const COLORS = [Color(1, 0, 0.5), Color(0, 0.8, 0.8), Color(1, 0.7, 0), Color(0.5, 0, 1)]

var jump_dir = Vector2(0, 0)
var vert_vel = 0
var color: Color


func _ready():
	$"Jump Timer".wait_time = randf_range(1, 3)
	$"Jump Timer".start()
	color = COLORS[randi_range(0, 4)]
	$Lemur.self_modulate = color

func _physics_process(delta: float) -> void:
	if vert_vel < -START_JUMP_VEL:
		velocity.y += vert_vel
		vert_vel += GRAVITY * delta
		if vert_vel >= -START_JUMP_VEL:
			$"Jump Timer".wait_time = randf_range(1, 3)
			$"Jump Timer".start()
	else:
		velocity = Vector2.ZERO
	move_and_slide()

func jump_random_angle():
	start_jump(randf_range(0, 2 * PI))

func start_jump(angle):
	jump_dir = Vector2.from_angle(angle)
	vert_vel = START_JUMP_VEL
	velocity = jump_dir * JUMP_SPEED
