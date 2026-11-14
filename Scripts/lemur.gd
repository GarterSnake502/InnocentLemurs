extends CharacterBody2D

const GRAVITY = 60   
const JUMP_SPEED = 32
const START_JUMP_VEL = -20

const COLORS = [Color(1, 0, 0.5), Color(0, 0.8, 0.8), Color(1, 0.7, 0), Color(0.5, 0, 1)]
const PIPE_POSITIONS = [Vector3(-112, -137, PI / 2), Vector3(112, -137, PI / 2), Vector3(-112, 137, -PI / 2), Vector3(112, 137, PI), Vector3(264, -64, PI), Vector3(264, 64, PI), Vector3(-264, -64, 0), Vector3(-264, 64, 0)]

var jump_dir = Vector2(0, 0)
var horizontal_vel = Vector2(0, 0)
var vert_vel = 0
var color: Color


func _ready():
	$"Jump Timer".wait_time = randf_range(1, 3)
	$"Jump Timer".start()
	color = COLORS[randi_range(0, 3)]
	$Lemur.self_modulate = color
	hop_in(randi_range(0, 7))

func _physics_process(delta: float) -> void:
	if vert_vel < -START_JUMP_VEL:
		velocity = horizontal_vel
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

func hop_in(pipe_index):
	position = Vector2(PIPE_POSITIONS[pipe_index].x, PIPE_POSITIONS[pipe_index].y)
	start_jump(PIPE_POSITIONS[pipe_index].z + randf_range(-0.3, 0.3), 100)

func start_jump(angle, jump_speed = JUMP_SPEED):
	jump_dir = Vector2.from_angle(angle)
	if jump_dir.x < 0:
		$Lemur.flip_h = true
		$Eyes.flip_h = true
	else:
		$Lemur.flip_h = false
		$Eyes.flip_h = false
	vert_vel = START_JUMP_VEL
	horizontal_vel = jump_dir * jump_speed

func bump_sfx():
	$bump.play()

func collect(point_amount):
	set_physics_process(false)
	$AnimationPlayer.play("die")
	$collect.pitch_scale = 1.0 + ((point_amount / 100) - 1) / 10
	$collect.play()
	await $AnimationPlayer.animation_finished
	queue_free()

func turn_around(body: Node2D) -> void:
	var turn_direction = (body.global_position - global_position).normalized()
	horizontal_vel = turn_direction * horizontal_vel.length()
