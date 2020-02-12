extends Spatial

export var active = true;

var grab_left = null;
var grab_right = null;

var active_grab = null;
var last_grab = null;

var left_start_position = Vector3();
var right_start_position = Vector3();

func _ready():
	if (not get_parent() is ARVROrigin):
		print(" in Feature_Climbing: parent not ARVROrigin.");

	grab_left = get_node("../Left_Hand/Feature_StaticGrab")
	grab_right = get_node("../Right_Hand/Feature_StaticGrab")
	
	if (grab_left == null || grab_right == null):
		print(" in Feature_Climbing; both controllers need the Feature_StaticGrab");

func start_left_grab():
	left_start_position = get_parent().global_transform.origin;
	#print(str("Start Grab at ", active_grab.grab_position));
	
func start_right_grab():
	right_start_position = get_parent().global_transform.origin;
	#print(str("Start Grab at ", active_grab.grab_position));


func _process(_dt):
	if (!active): return;

	if (grab_left.is_just_grabbing and grab_right.is_just_grabbing):
		start_left_grab();
		start_right_grab();
		var position = (left_start_position + right_start_position)/2
		var new_position = (grab_left.delta_position + grab_right.delta_position)/2
		#get_parent().is_fixed = true;
		get_parent().global_transform.origin = position - new_position
		
	elif (grab_left.is_just_grabbing):
			start_left_grab();
			get_parent().is_fixed = true;
			get_parent().global_transform.origin = left_start_position - grab_left.delta_position;
	
	elif (grab_right.is_just_grabbing):
			start_right_grab();
			get_parent().is_fixed = true;
			get_parent().global_transform.origin = right_start_position - grab_right.delta_position;
			
	else:
		get_parent().is_fixed = false;
	
#	if (active_grab):
#		get_parent().is_fixed = true;
#		get_parent().global_transform.origin = start_position - active_grab.delta_position;
#	else:
#		get_parent().is_fixed = false;
