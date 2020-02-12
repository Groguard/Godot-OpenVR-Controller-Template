extends Area

signal has_picked_up(what)
signal has_dropped

export var impulse_factor = 1.0
export var pickup_button_id = 2
export var action_button_id = 15
export var max_samples = 5

var object_in_area = Array()
var closest_object = null
var picked_up_object = null
var belt = null
var origin_node = null

var last_position = Vector3(0.0, 0.0, 0.0)
var velocities = Array()

func _get_velocity():
	var velocity = Vector3(0.0, 0.0, 0.0)
	var count = velocities.size()
	
	if count > 0:
		for v in velocities:
			velocity = velocity + v
		
		velocity = velocity / count
	
	return velocity

func _on_Function_Pickup_body_entered(body):
	# add our object to our array if required
	if body.has_method('pick_up') and object_in_area.find(body) == -1:
		object_in_area.push_back(body)
		_update_closest_object()

func _on_Function_Pickup_body_exited(body):
	# remove our object from our array
	if object_in_area.find(body) != -1:
		object_in_area.erase(body)
		_update_closest_object()

func _update_closest_object():
	var new_closest_obj = null
	if !picked_up_object:
		var new_closest_distance = 1000
		for o in object_in_area:
			# only check objects that aren't already picked up
			if o.is_picked_up() == false:
				var delta_pos = o.global_transform.origin - global_transform.origin
				var distance = delta_pos.length()
				if distance < new_closest_distance:
					new_closest_obj = o
					new_closest_distance = distance
	
	if closest_object != new_closest_obj:
		# remove highlight on old object
		if closest_object:
			closest_object.decrease_is_closest()
		
		# add highlight to new object
		closest_object = new_closest_obj
		if closest_object:
			closest_object.increase_is_closest()

func drop_object():
	if picked_up_object:
		# let go of this object
		picked_up_object.let_go(_get_velocity() * impulse_factor)
		picked_up_object = null
		emit_signal("has_dropped")

func _pick_up_object(p_object):
	# already holding this object, nothing to do
	if picked_up_object == p_object:
		return
	
	# holding something else? drop it
	if picked_up_object:
		drop_object()
	
	# and pick up our new object
	if p_object:
		picked_up_object = p_object
		picked_up_object.pick_up(self)
		emit_signal("has_picked_up", picked_up_object)

func _on_button_pressed(p_button):
	if p_button == pickup_button_id:
		if picked_up_object and !picked_up_object.press_to_hold:
			var item = picked_up_object
			drop_object()
			belt.check_and_put_in_toolbelt(item)
#		elif !picked_up_object and belt.Slots.can_grab():
#			var belt_slot_item = belt.get_slot_object()
#			print(belt_slot_item.name)
#		if picked_up_object and !picked_up_object.press_to_hold:
#			drop_object()
		elif closest_object:
			_pick_up_object(closest_object)
		else:
			belt.check_and_grab_in_toolbelt_slot(self)

	elif p_button == action_button_id:
		if picked_up_object and picked_up_object.has_method("action"):
			picked_up_object.action()

func _on_button_release(p_button):
	if p_button == pickup_button_id:
		if picked_up_object and picked_up_object.press_to_hold:
			var item = picked_up_object
			drop_object()
			belt.check_and_put_in_toolbelt(item)

func _ready():
	# origin node should always be the parent of our parent
	origin_node = get_node("../..")
	belt = origin_node.get_node("Toolbelt")
	get_parent().connect("button_pressed", self, "_on_button_pressed")
	get_parent().connect("button_release", self, "_on_button_release")
	last_position = global_transform.origin

func _process(delta):
	velocities.push_back((global_transform.origin - last_position) / delta)
	if velocities.size() > max_samples:
		velocities.pop_front()
	
	last_position = global_transform.origin
	_update_closest_object()
