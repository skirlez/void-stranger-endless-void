event_inherited()

function commit() {
	with (agi("obj_ev_level_settings_window")) {
		if !global.editing_pack_level {
			global.level.name = name_textbox.txt
			global.level.description = description_textbox.txt
		}
		else {
			global.pack_level_preferred_music = global.music_names[music_select.index];
		}
		
		// this is stripped once we leave the level anyway if we're editing a pack level, it is just done because
		// the editor expects it
		global.level.music = global.music_names[music_select.index]
		
		for (var i = 0; i < 5; i++) {
			global.level.burdens[i] = burdens[i].image_index
		}
		global.level.theme = theme_selector.get_selected_index();
	}
}


burdens = array_create(5)
for (var i = 0; i < 5; i++) {
	burdens[i] = instance_create_layer(112 - 72 + i * 16, 72 + 30, "WindowElements", agi("obj_ev_burden_toggle"), 
	{
		burden_ind : i,
		layer_num : global.mouse_layer,
		image_index : global.level.burdens[i]
	})
	
	add_child(burdens[i])
}


var theme_selector_y = global.editing_pack_level ? 72 + 35 : 72 - 35
theme_selector = instance_create_layer(112 + 50, theme_selector_y, "WindowElements", agi("obj_ev_selector"), {
	elements : ["Regular", "Universe"],
	selected_element : global.level.theme,
	max_radius : 20
})
add_child(theme_selector)

music_select = instance_create_layer(112 + 48, 72 + 4, "WindowElements", agi("obj_ev_music_select"), {
	base_scale_x : 1,
	preselected_music : global.level.music
})
add_child(music_select)

elements_depth = layer_get_depth("WindowElements")



if global.editing_pack_level {
	var man1 = instance_create_depth(112 + 39, 72 - 14, elements_depth - 1, agi("obj_ev_man"))
	add_child(man1)
	var man2 = instance_create_depth(112 + 48, 72 - 14, elements_depth - 1, agi("obj_ev_man"))
	add_child(man2)
	leave_button = instance_create_layer(112 - 35, 72 - 20, "WindowElements", agi("obj_ev_executing_button"), 
	{
		txt : "LEAVE",
		base_scale_x : 3,
		base_scale_y : 2,
		func : function () {
			strip_level_for_pack(global.level)
			global.editing_pack_level_properties.level = global.level;
			global.editing_pack_level = false;
			global.void_radio_disable_stack--;
			global.pack_level_preferred_music = global.music_names[window.music_select.index];
			room_goto(global.pack_editor_room)	
		}
	})
	add_child(leave_button)
	exit;
}

var man = instance_create_depth(112 + 43, 72 - 14, elements_depth - 1, agi("obj_ev_man"))
add_child(man)




save_button = instance_create_layer(112 - 65, 72 - 34, "WindowElements", agi("obj_ev_save_button"), 
{
	txt : "Save",
	pre_save_func : commit,
	base_scale_y : 0.7
})

quit_button = instance_create_layer(112 - 20, 72 - 34, "WindowElements", agi("obj_ev_main_menu_button"), 
{
	txt : "Quit",
	base_scale_x : 1.2,
	base_scale_y : 0.7,
	room_name : "rm_ev_level_select"
})
add_child(quit_button)
var textbox_scale = 5;
var textbox_left_pos = 112 - 78;
var textbox_x = textbox_left_pos + 8 * textbox_scale;

name_textbox = instance_create_layer(textbox_x, 72 - 10, "WindowElements", agi("obj_ev_textbox"), 
{
	txt : global.level.name,
	empty_text : "Level Name",
	base_scale_x : textbox_scale,
	allow_newlines : false,
	automatic_newline: false,
	char_limit : 30,
	opened_x : room_width / 2,
	opened_y : room_height / 2
	//exceptions: "~`!@#$%^&()_=-+{} [],.;'"
})
	
description_textbox = instance_create_layer(textbox_x, 72 + 10, "WindowElements", agi("obj_ev_textbox"), 
{
	txt : global.level.description,
	empty_text : "Level Description",
	char_limit : 256,
	base_scale_x : textbox_scale,
	allow_newlines : false,
	layer_num : global.mouse_layer,
	opened_x : room_width / 2,
	opened_y : room_height / 2
})

description_textbox.depth--;
	
add_child(save_button)
add_child(name_textbox)
add_child(description_textbox)
	



var claim_button = instance_create_layer(112 + 46, 72 + 40, "WindowElements", agi("obj_ev_executing_button"), {
	func : function () {
		global.mouse_layer++
		new_window(11, 6, agi("obj_ev_claim_window"), 
		{
			layer_num : global.mouse_layer,
			layer : layer_get_id("Windows2")
		})
	},
	sprite_index : agi("spr_ev_claim")
})



add_child(claim_button)
