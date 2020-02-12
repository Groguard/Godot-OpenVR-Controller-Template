extends Spatial

export (NodePath) var camera = null

var origin_node = null
var camera_node = null
var belt_offset = deg2rad(90)
var camera_offset = deg2rad(10)
	
func check_and_put_in_toolbelt(held_obj):
	for slot in $Slots.get_children():
		if slot.check_and_put_in_toolbelt_slot(held_obj):
			return true;
	return false;

func check_and_grab_in_toolbelt_slot(new_parent):
	for slot in $Slots.get_children():
		var item = slot.check_and_get_in_toolbelt_slot(new_parent)
		if item:
			return item
	return false

func _process(_delta):
	global_transform.origin = camera_node.global_transform.origin
	global_transform.origin.y -= (camera_node.transform.origin.y * 0.5)
	var camera_rot = camera_node.rotation
	#if (camera_rot.x < -1.2):
	camera_rot.y -= belt_offset
	self.rotation.y = camera_rot.y

func _ready():
	if camera:
		camera_node = get_node(camera)
