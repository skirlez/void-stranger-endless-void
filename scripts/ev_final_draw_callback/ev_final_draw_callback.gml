
function ev_final_draw_callback(surface_final) {
	if room == global.level_room && global.playtesting {
		with (global.editor) {
			if instance_exists(agi("obj_diamond_fade")) // it's a full screen clear and it kinda hurts the eyes, so just wait it out
				exit;
			if memory_surface_era == max_memory_surface_buffers {
				var buffer = buffer_create((224 * 144) * 4, buffer_fixed, 1)
				buffer_get_surface(buffer, surface_final, 0)
			
				memory_surface_buffers[memory_surface_time] =  buffer
				if memory_surface_time == max_memory_surface_buffers {
					memory_surface_era *= 2
				}
			}
			else {
				var scaled_down_time = (memory_surface_time - memory_surface_era div 2) div (memory_surface_era div 24)
				static has_sacrificed = false
				if scaled_down_time % 2 == 0
					has_sacrificed = false;	
				else if !has_sacrificed {
					has_sacrificed = true;
					var sacrifice_index = max_memory_surface_buffers - scaled_down_time
					buffer_delete(memory_surface_buffers[sacrifice_index])
					memory_surface_buffers[sacrifice_index] = noone;
					var buffer = buffer_create((224 * 144) * 4, buffer_fixed, 1)
					buffer_get_surface(buffer, surface_final, 0)
					memory_surface_buffers[max_memory_surface_buffers + scaled_down_time - 1] = buffer
				}
				if scaled_down_time == max_memory_surface_buffers {
					memory_surface_era *= 2
					flatten_memory_surface_buffers()
				}
			}
			memory_surface_time++;
		}
	}
}