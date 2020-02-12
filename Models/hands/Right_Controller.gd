extends Node

enum MOVEMENT_TYPE { MOVE_AND_ROTATE, MOVE_AND_STRAFE }

# Is this active?
export var enabled = true setget set_enabled, get_enabled

# We don't know the name of the camera node... 
export (NodePath) var camera = null

# size of our player
export var player_radius = 0.4 setget set_player_radius, get_player_radius

# to combat motion sickness we'll 'step' our left/right turning
export var turn_delay = 0.2
export var turn_angle = 20.0
export var max_speed = 5.0
export var drag_factor = 0.1
var time = 0
var lastTurnTime = 0

# fly mode and strafe movement management
export (MOVEMENT_TYPE) var move_type = MOVEMENT_TYPE.MOVE_AND_ROTATE

var turn_step = 0.0
var origin_node = null
var camera_node = null
var velocity = Vector3(0.0, 0.0, 0.0)
var gravity = -30.0
onready var collision_shape: CollisionShape = get_node("KinematicBody/CollisionShape")
onready var tail : RayCast = get_node("KinematicBody/Tail")

func set_enabled(new_value):
	enabled = new_value
	if collision_shape:
		collision_shape.disabled = !enabled
	if tail:
		tail.enabled = enabled
	if enabled:
		# make sure our physics process is on
		set_physics_process(true)
	else:
		# we turn this off in physics process just in case we want to do some cleanup
		pass

func get_enabled():
	return enabled

func get_player_radius():
	return player_radius

func set_player_radius(p_radius):
	player_radius = p_radius

func _ready():
	# origin node should always be the parent of our parent
	origin_node = get_node("../..")
	
	if camera:
		camera_node = get_node(camera)
	else:
		# see if we can find our default
		camera_node = origin_node.get_node('ARVRCamera')
	
	set_player_radius(player_radius)
	
	collision_shape.disabled = !enabled
	tail.enabled = enabled

func _physics_process(delta):
	time += delta
	
	if !origin_node:
		return
	
	if !camera_node:
		return
	
	if !enabled:
		set_physics_process(false)
		return
	
	# Adjust the height of our player according to our camera position
	var player_height = camera_node.transform.origin.y + player_radius
	if player_height < player_radius:
		# not smaller than this
		player_height = player_radius
	
	collision_shape.shape.radius = player_radius
	collision_shape.shape.height = player_height - (player_radius * 2.0)
	collision_shape.transform.origin.y = (player_height / 2.0)
	
	# We should be the child or the controller on which the teleport is implemented
	var controller = get_parent()
	if controller.get_is_active():
		var left_right = controller.get_joystick_axis(0)
		#var forwards_backwards = controller.get_joystick_axis(1)
	
		if(move_type == MOVEMENT_TYPE.MOVE_AND_ROTATE && abs(left_right) > 0.1):
			if left_right > 0.0:
				if turn_step < 0.0:
					# reset step
					turn_step = 0
					
				turn_step += left_right * delta
			else:
				if turn_step > 0.0:
					# reset step
					turn_step = 0
					
				turn_step += left_right * delta
	
			# we rotate around our Camera, but we adjust our origin, so we need a little bit of trickery
			var t1 = Transform()
			var t2 = Transform()
			var rot = Transform()
		
			t1.origin = -camera_node.transform.origin
			t2.origin = camera_node.transform.origin
			
			if (time - lastTurnTime) > turn_delay:
				lastTurnTime = time
			# Rotating
				if (turn_step > 0.0):
					rot = rot.rotated(Vector3(0.0,-1.0,0.0),turn_angle * PI / 180.0)
					turn_step -= turn_delay
				else:
					rot = rot.rotated(Vector3(0.0,1.0,0.0),turn_angle * PI / 180.0)
					turn_step += turn_delay
				
			origin_node.transform *= t2 * rot * t1
		else:
			turn_step = 0.0
