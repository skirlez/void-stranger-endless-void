event_inherited();
music_select = instance_create_layer(x, y, "WindowElements", agi("obj_ev_music_select"), {
	base_scale_x : 1,
	preselected_music : node_instance.properties.music,
	boost_pack_arrow_progress : true,
})
add_child(music_select)
global.void_radio_disable_stack++;
ev_play_music(agi(node_instance.properties.music), true);

global.pack_editor.boost_pack_arrow();
