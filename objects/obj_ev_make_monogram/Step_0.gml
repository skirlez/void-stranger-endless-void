if ev_mouse_pressed() && ev_is_mouse_on_me() {
	drawing = true
}


if (drawing && ev_is_mouse_on_me()) {
	var relative_x = (mouse_x - x) div (scale)
	var relative_y = (mouse_y - y) div (scale)

	if (
        (relative_x < width && relative_y < height) && 
        (relative_x != last_relative_x || relative_y != last_relative_y)
    ) {
        if last_active == -1 {
            last_active = 1 - tiles[relative_y * width + relative_x]
        }
        
		tiles[relative_y * width + relative_x] = last_active
		audio_play_sound(agi("snd_ev_paint_brand"), 10, false)
		last_relative_x = relative_x;
		last_relative_y = relative_y;
	}
}

if ev_mouse_released() {
    last_active = -1
	last_relative_x = -1
	last_relative_y = -1
	drawing = false;
}

if ev_mouse_right_pressed() {
	var relative_x = (mouse_x - x) div scale
	var relative_y = (mouse_y - y) div scale

    if (relative_x < width && relative_y < height && relative_x >= 0 && relative_y >= 0) {
		audio_play_sound(agi("snd_ev_place"), 10, false, 1, 0, random_range(0.9, 1.1))
        target_col = relative_x
        target_row = relative_y
    }
}