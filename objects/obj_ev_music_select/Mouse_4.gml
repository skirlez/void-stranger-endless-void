if !ev_is_mouse_on_me()
	exit;

audio_play_sound(agi("snd_ev_selector_click"), 10, false)

global.mouse_layer++;

var init_struct = {
	add_x: false,
	source_x : x + image_xscale * sprite_get_width(sprite_index) / 2,
	source_y : y + image_yscale * sprite_get_height(sprite_index) / 2,
	source_image_xscale : image_xscale,
	source_image_yscale : image_yscale,
	layer: layer_get_id("Windows2"),
	selected_index : index,
	elements: global.music_names,
	labels: global.music_labels,
	layer_num : global.mouse_layer,
	music_select : id,
	on_select: function (index) {
		music_select.index = index;
		music_select.txt = index;
		ev_play_music(music_select.musics[index]);

		if music_select.boost_pack_arrow_progress {
			global.pack_editor.boost_pack_arrow();
		}
	}
}

if (node_instance) {
	new_window_with_pos(x, y, 12, 8, agi("obj_ev_scroll_selector_window"), init_struct)
} else {
	new_window(12, 8, agi("obj_ev_scroll_selector_window"), init_struct)
}
