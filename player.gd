extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.003

const PITCH_MIN = -1.4  # ~-80 degrees (look down limit)
const PITCH_MAX = 1.4   # ~+80 degrees (look up limit)

@onready var camera = $Camera3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	# Capture and hide the mouse cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	# Mouse look
	if event is InputEventMouseMotion:
		# Left/right — rotate the whole body on Y axis
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		
		# Up/down — rotate only the camera on X axis
		camera.rotation.x -= event.relative.y * MOUSE_SENSITIVITY
		camera.rotation.x = clamp(camera.rotation.x, PITCH_MIN, PITCH_MAX)
	
	# Press Escape to release mouse (useful during testing)
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Movement relative to where the player is FACING
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
