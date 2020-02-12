extends Spatial

onready var slot = $Slot;

func can_grab():
	if slot.get_child_count() == 0: return false;
	return true;


func get_slot_object():
	if slot.get_child_count() == 0: return null;
	
	var obj = slot.get_child(0);
	return obj;


func get_grab_object(_controller):
	return get_slot_object();


func check_and_put_in_toolbelt_slot(held_obj):
	if ($Slot.get_child_count() > 0): return false; # already something in there
	if (!$Area.overlaps_body(held_obj)): return false;
	
	held_obj.pick_up(slot)
	held_obj.transform = Transform()
	
	$MeshInstance.visible = false;


func check_and_get_in_toolbelt_slot(new_parent):
	if ($Slot.get_child_count() > 0):
		var obj = get_slot_object()
		if (!$Area.overlaps_area(new_parent)): return false;
		new_parent._pick_up_object(obj)
		$MeshInstance.visible = true;


func _on_Area_area_entered(_area):
	if (slot.get_child_count() > 0):
		$MeshInstance.visible = false;
	else:
		$MeshInstance.visible = true;


func _on_Area_area_exited(_area):
	if ($Area.get_overlapping_areas().size() <= 1):
		$MeshInstance.visible = false;

