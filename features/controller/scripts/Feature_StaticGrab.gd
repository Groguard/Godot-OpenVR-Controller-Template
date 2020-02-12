extends Spatial

var grab_area : Area = null;
var controller : ARVRController = null;
onready var origin = get_node("../..")
onready var pick_up_area = get_node("../Function_Pickup")
export var grab_button = 15


signal oq_static_grab_started;
signal oq_static_grab_ended;

var is_grabbing = false;
var is_just_grabbing = false;
var grabbed_object = null;
var grab_position = Vector3();
var delta_position = Vector3();
var grab_just_pressed = false

var timer

export var rumble = 0.0 setget set_rumble, get_rumble

func set_rumble(new_value):
	if controller:
		controller.rumble = new_value

func get_rumble():
	if controller:
		return controller.rumble
	else:
		return 0


func _ready():
	controller = get_parent();
	if (not controller is ARVRController):
		print(" in Feature_StaticGrab: parent not ARVRController.");
	grab_area = $GrabArea;
	controller.connect("button_pressed", self, "_on_button_pressed")
	controller.connect("button_release", self, "_on_button_release")
	
	
func _process(_delta):
	grab_area.global_transform = controller.global_transform;
	if (grab_just_pressed):
		var overlapping_bodies = grab_area.get_overlapping_bodies();
		for b in overlapping_bodies:
			if (b.has_method("can_grab") and b.can_grab()):
				is_grabbing = true;
				is_just_grabbing = true;
				grab_position = controller.global_transform.origin; # we need the local translation here as we will move the origin
				grabbed_object = b;
				grab_just_pressed = false
				break;
		
	if (!controller.is_button_pressed(grab_button)):
		if (is_grabbing):
			emit_signal("oq_static_grab_ended", grabbed_object, controller)
			grabbed_object = null;
			is_grabbing = false;
	
	elif (is_grabbing):
		delta_position = controller.global_transform.origin - grab_position

func _on_button_pressed(p_button):
	if p_button == grab_button and !pick_up_area.picked_up_object and !grabbed_object:
		grab_just_pressed = true


func _on_button_release(p_button):
	if p_button == grab_button:
		is_just_grabbing = false;
