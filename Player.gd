extends KinematicBody

# Physics
var movementSpeed = 10.0 		# How fast the player can move.
var jumpStrength = 5.0 		# How much force used to make player jump
var gravity = 10.0			# Gravity's strength.

# cam look
var minCamVerticalAngle = -90.0		# Limit camera view to straight down.
var maxCamVerticalAngle = 90.0		# Limit camera view to straight up.
var lookSensitivity = 0.5			# How fast camera moves. 'mouse sensitivity'. 

# vectors
var playerVelocity : Vector3 = Vector3() 	# Players Velocity
var mouseDelta : Vector2 = Vector2()			# How much the mouse has moved since last frame refresh.

# player components
onready var camera = get_node("Camera")		# "attach" the camera to access from script.
onready var bulletScene = preload("res://Bullet.tscn")
onready var bulletSpawn = get_node("Camera/bulletSpawn")
var ammo : int = 15

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)



# called when an input is detected
func _input (event):
	# did the mouse move?
	if event is InputEventMouseMotion:
		mouseDelta = event.relative

# called every frame
func _process (delta):
	# rotate camera along X axis
	camera.rotation_degrees -= Vector3(rad2deg(mouseDelta.y), 0, 0) * lookSensitivity * delta
	# clamp the vertical camera rotation
	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, minCamVerticalAngle, maxCamVerticalAngle)

	# rotate player along Y axis
	rotation_degrees -= Vector3(0, rad2deg(mouseDelta.x), 0) * lookSensitivity * delta

	# reset the mouse delta vector
	mouseDelta = Vector2()
	$Camera/playerScore.text = str(Global.current_score)
	if Global.player_health <= 0:
		print("Dead")
		get_tree().change_scene("res://Lose.tscn")
	
	if Input.is_action_just_pressed("shoot"):
		shoot()

func shoot ():
	var bullet = bulletScene.instance()
	get_node("/root/Doom").add_child(bullet)
	bullet.global_transform = bulletSpawn.global_transform
	bullet.scale = Vector3(0.1,0.1,0.1) # Scale appropriately.

	ammo -= 1

# called every physics step
func _physics_process (delta):
	# reset the x and z velocity
	playerVelocity.x = 0
	playerVelocity.z = 0
	var input = Vector2()
	# movement inputs
	if Input.is_action_pressed("player_forward"):
		input.y -= 1
	if Input.is_action_pressed("player_backward"):
		input.y += 1
	if Input.is_action_pressed("player_left"):
		input.x -= 1
	if Input.is_action_pressed("player_right"):
		input.x += 1
	# normalize the input so we can't move faster diagonally
	input = input.normalized()
	
	if Input.is_action_pressed("run"):
		movementSpeed = 20
	else:
		movementSpeed = 10
	
	# get our forward and right directions
	var forward = global_transform.basis.z
	var right = global_transform.basis.x
	# set the velocity
	playerVelocity.z = (forward * input.y + right * input.x).z * movementSpeed
	playerVelocity.x = (forward * input.y + right * input.x).x * movementSpeed
	# apply gravity
	playerVelocity.y -= gravity * delta
#	print(playerVelocity.y)
	# move the player
	playerVelocity = move_and_slide(playerVelocity, Vector3.UP)
	# jump if we press the jump button and are standing on the floor
	if Input.is_action_pressed("jump") and is_on_floor():
		playerVelocity.y = jumpStrength

