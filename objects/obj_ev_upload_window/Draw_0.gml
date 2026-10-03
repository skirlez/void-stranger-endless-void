draw_self()
draw_set_halign(fa_center)
draw_set_valign(fa_middle)
draw_set_color(c_white)

// When someone says something so conditionalphobic you gotta hit them with that if/else stare
if (state == 0)
	draw_text_shadow(room_width / 2, room_height / 2 - 10, are_you_sure_upload_text)
else if (state == 1) 
	draw_text_shadow(room_width / 2, room_height / 2 - 10, doing_the_thing_text)
else if (state == 2)
	draw_text_shadow(room_width / 2, room_height / 2 - 10, done_text)
else if (state == 3)
	draw_text_shadow(room_width / 2, room_height / 2 - 20, fail_text)
else if (state == 4)
	draw_text_shadow(room_width / 2, room_height / 2 - 10, manage_text)
else if (state == 5)
	draw_text_shadow(room_width / 2, room_height / 2 - 10, are_you_sure_delete_text)
else if (state == 6)
	draw_text_shadow(room_width / 2, room_height / 2 - 10, verifying_text)
else if (state == 7)
	draw_text_shadow(room_width / 2, room_height / 2 - 10, no_idea_text)
else if (state == 8) {
	var str = beat_first_text
	if level_contains_crystal_memory(lvl)
		str += "\n" + and_memory_crystal_text
	draw_text_shadow(room_width / 2, room_height / 2 - 10, str)
}