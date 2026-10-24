event_inherited()

if x_scroll_state == 0 {
    x_scroll_counter++;
    if x_scroll_counter == x_offset_start_time {
        x_scroll_state = 1;
        x_scroll_counter = 0;
    }
} else if x_scroll_state == 1 {
    current_x_offset += min(max_x_offset_speed, target_x_offset / x_offset_time);
    if current_x_offset >= target_x_offset {
        current_x_offset = target_x_offset;
        x_scroll_state = 2;
    }
} else if x_scroll_state == 2 {
    x_scroll_counter++;
    if x_scroll_counter == x_offset_pause_time {
        x_scroll_state = 3;
        x_scroll_counter = 0;
    }
} else if x_scroll_state == 3 {
    current_x_offset -= min(max_x_offset_speed, target_x_offset / x_offset_time);
    if current_x_offset <= 0 {
        current_x_offset = 0;
        x_scroll_state = 0;
        x_scroll_counter = x_offset_start_time - x_offset_pause_time;
    }
}

hovered_index = -1

if ev_is_mouse_on_me()  {
    if mouse_wheel_down() {
        if first_displayed_index + page_size < array_length(filtered_indices) {
            first_displayed_index++;
            if audio_is_playing(snd_scroll)
                audio_stop_sound(snd_scroll)
            audio_play_sound(snd_scroll, 10, false, 1, 0, random_range(0.9, 1.0));
        }
    }

    if mouse_wheel_up() {
        if first_displayed_index > 0 {
            first_displayed_index--;
            if audio_is_playing(snd_scroll)
                audio_stop_sound(snd_scroll)
            audio_play_sound(snd_scroll, 10, false, 1, 0, random_range(1.0, 1.1));
        }
    }

    var relative_y = mouse_y - y;

    if relative_y >= 0 && relative_y < element_height * page_size {
        hovered_index = (relative_y div element_height) + first_displayed_index;

        if ev_mouse_pressed() && hovered_index < array_length(filtered_indices) {
            if selected_index == filtered_indices[hovered_index] {
                audio_play_sound(agi("snd_ev_textbox_click"), 10, false)

                if (on_confirm) {
                    on_confirm()
                }

            } else {
	            audio_play_sound(global.select_sound, 10, false, 1, 0, random_range(0.9, 1.1))
                selected_index = filtered_indices[hovered_index];
                x_scroll_state = 0;
                x_scroll_counter = 0;
                current_x_offset = 0;

                if (on_select){
                    on_select(selected_index, elements[selected_index])
                }
            }
        }
    }
}