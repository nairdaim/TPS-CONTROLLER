extends CharacterBody3D

@onready var camera_mount: Node3D = $camera_mount
@onready var animation_player: AnimationPlayer = $visuals/mixamo_base/AnimationPlayer
@onready var visuals: Node3D = $visuals
@onready var camera_3d: Camera3D = $camera_mount/Camera3D
@onready var cam_anim_player: AnimationPlayer = $camera_mount/Camera3D/AnimationPlayer

@export var h_sens = 0.15
@export var v_sens = 0.10
@export var shoulder_camera = false

var SPEED = 1.75
var walking_speed = 1.75
var running_speed = 4.0
var running = false

var JUMP_VELOCITY = 4.5

func switch_shoulder(): #Switching shoulders
	if shoulder_camera == true:
		cam_anim_player.play("left")
	else :
		cam_anim_player.play("right")

func _ready(): #Mouse captured in the window
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _input(event):
	if event is InputEventMouseMotion: #Camera Rotation
		rotate_y(deg_to_rad(-event.relative.x) * h_sens)
		visuals.rotate_y(deg_to_rad(event.relative.x) * h_sens)
		print(visuals.rotation.y)
		camera_mount.rotate_x(-deg_to_rad(event.relative.y) * v_sens)
		camera_mount.rotation.x = clamp(camera_mount.rotation.x, deg_to_rad(-70), deg_to_rad(45))

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if Input.is_action_pressed("run"): ##Running State
		SPEED = running_speed
		running = true
	else: 
		SPEED = walking_speed
		running = false
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if Input.is_action_just_pressed("change_cam_shoulder"):
		shoulder_camera = !shoulder_camera
		switch_shoulder()
		#
	if Input.is_action_just_pressed("ui_accept") and is_on_floor(): #Jumping
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	

	if direction && running: #Running
		if animation_player.current_animation != "running":
			animation_player.play("running")
			camera_3d.unzoom()
			camera_3d.zoom(1.1)
			
		visuals.look_at(position + direction)
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
	elif direction: #Walking
		
		if animation_player.current_animation != "walking":
			animation_player.play("walking")
			camera_3d.unzoom()
		if Input.is_action_just_pressed("zoom"):
			camera_3d.zoom(0.5)
		if Input.is_action_just_released("zoom"):
			camera_3d.unzoom()
		
		visuals.look_at(position + direction)
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
	else: #Idle
		if animation_player.current_animation != "idle":
			animation_player.play("idle")
		if Input.is_action_just_pressed("zoom"):
			camera_3d.zoom(0.5)
		if Input.is_action_just_released("zoom"):
			camera_3d.unzoom()
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	
	move_and_slide()
