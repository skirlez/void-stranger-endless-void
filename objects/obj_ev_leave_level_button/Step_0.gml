event_inherited()

var quill_exists = global.is_merged && instance_exists(agi("obj_quill"))
var end_of_pack = instance_exists(agi("obj_ev_pack_end")) 
					&& agi("obj_ev_pack_end").state == end_animation_states.done
var mouse_in_region = mouse_y < 32 && mouse_x < 48 

can_use = (mouse_in_region || end_of_pack)
	&& !quill_exists 
	&& global.can_leave_level
	

		

if can_use
	y = lerp(y, 14, 0.3)	
else
	y = lerp(y, ystart, 0.3)