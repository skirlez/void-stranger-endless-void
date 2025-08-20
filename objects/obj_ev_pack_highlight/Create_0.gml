event_inherited()

var play = instance_create_layer(208, 40, "LevelHighlightButtons", agi("obj_ev_play_pack_button"))
play.layer_num = 1
play.nodeless_pack = nodeless_pack
play.display_instance = display_instance
play.highlighter = id;
play.image_alpha = 0



var play_t = instance_create_layer(8, room_height - 10, "LevelHighlightButtons", agi("obj_ev_play_pack_button"))
play_t.layer_num = 1
play_t.nodeless_pack = nodeless_pack
play_t.display_instance = display_instance
play_t.highlighter = id;
play_t.tis = true;
play_t.image_alpha = 0;

if global.tis_pack_button {
	var scores = instance_create_layer(24, room_height - 10, "LevelHighlightButtons", agi("obj_ev_executing_button"), {
		sprite_index : agi("spr_ev_score_list"),
		highlighter : id,
		layer_num : 1,
		image_alpha : 0,
		func : function () {
			new_window(11, 7, agi("obj_ev_tis_score_window"), {
				save_name : highlighter.nodeless_pack.save_name,
				layer_num : 2,
			})
			global.mouse_layer++;
		}
	})
	add_child(scores)
}

var copy = instance_create_layer(192, 40, "LevelHighlightButtons", agi("obj_ev_executing_button"), {
	layer_num : 1,
	nodeless_pack : nodeless_pack,
	image_alpha : 0,
	sprite_index : agi("spr_ev_copy"),
	func : function () {
		var pack_string = read_pack_string_from_file(nodeless_pack.save_name)
		clipboard_set_text(pack_string)
		ev_notify("Copied to clipboard!")
	}
})

var back = instance_create_layer(200, 16, "LevelHighlightButtons", agi("obj_ev_main_menu_button"), {
	base_scale_x : 1,
	base_scale_y : 0.7,
	txt : "Back",
	room_name : room_get_name(room),
	layer_num : 1,
	image_alpha : 0
});



add_child(play_t)
add_child(play)
add_child(back)
add_child(copy)


function format_date(date_str) {
	if string_length(date_str) < 8
		return "15/05/2015"
	var str = "";
	var pos = string_length(date_str);
	str += string_char_at(date_str, pos - 1) + string_char_at(date_str, pos) + "/";
	pos -= 2;
	str += string_char_at(date_str, pos - 1) + string_char_at(date_str, pos) + "/";
	pos -= 2;
	
	var amount_left = pos + 1;
	while (pos >= 1) {
		str += string_char_at(date_str, amount_left - pos)
		pos--;
	}
	return str;	
}

var textbox_offset;
if (!global.online_mode) {
	date_textbox = noone
	
	var edit = instance_create_layer(192, 73, "LevelHighlightButtons", agi("obj_ev_executing_button"), {
		layer_num : 1,
		nodeless_pack : nodeless_pack,
		display_instance : display_instance,
		highlighter : id,
		sprite_index : agi("spr_ev_edit_level"),
		image_alpha : 0,
		func : function () {				
			if nodeless_pack.password_brand == 0 
			|| load_pack_password(nodeless_pack) == nodeless_pack.password_brand {
				highlighter.hide_textbox();
				global.editor.edit_level_pack_transition(nodeless_pack, display_instance);
			}
			else {
				global.mouse_layer++
				new_window(8, 7, agi("obj_ev_pack_password_window"), { 
					nodeless_pack : nodeless_pack,
					layer_num : global.mouse_layer,
				})
				
			}
		}
	})
	

	
	var deleteb = instance_create_layer(192, 90, "LevelHighlightButtons", agi("obj_ev_delete_button"), {
		pack_mode : true,
		layer_num : 1,
		level_select : instance_find(agi("obj_ev_level_select"), 0),
		save_name : nodeless_pack.save_name,
		display_instance : display_instance,
		image_alpha : 0,
	})
	
	if pack_progress_exists(nodeless_pack.save_name) {
		var delete_save_button = instance_create_layer(208, 90, "LevelHighlightButtons", agi("obj_ev_delete_pack_save_button"), {
			layer_num : 1,
			level_select : instance_find(agi("obj_ev_level_select"), 0),
			save_name : nodeless_pack.save_name,
			display_instance : display_instance,
			image_alpha : 0,
		})
		add_child(delete_save_button)
	}

	/*
	var upload = instance_create_layer(208, 90, "LevelHighlightButtons", agi("obj_ev_upload_button"))
	upload.layer_num = 1
	upload.lvl = lvl;
	upload.image_alpha = 0
	*/
	
	

	add_child(deleteb)
	
	//add_child(upload)


	textbox_offset = 20;
	add_child(edit)
}
else {
	date_textbox = instance_create_layer(201, 130, "LevelDescription", agi("obj_ev_textbox"), 
	{
		txt : ("Upload date:\n" 
			+ format_date(nodeless_pack.upload_date) 
			+ "\nLast edited date:\n" 
			+ format_date(nodeless_pack.last_edit_date)),
		base_scale_x : 2,
		base_scale_y : 1,
		layer_num : 1,
		allow_deletion : false,
		char_limit : 0,	
		opened_x : room_width / 2,
		opened_y : room_height / 2,
		image_alpha : 0
	})
	textbox_offset = 0;
	add_child(date_textbox)
}

description_textbox = instance_create_layer(201, 90 + textbox_offset, "LevelDescription", agi("obj_ev_textbox"), 
{
	txt : (nodeless_pack.description == "" ? "No description provided." : "Description:\n" + nodeless_pack.description),
	base_scale_x : 2,
	base_scale_y : 1,
	layer_num : 1,
	allow_deletion : false,
	char_limit : 0,	
	opened_x : room_width / 2,
	opened_y : room_height / 2,
	image_alpha : 0
})

author_textbox = instance_create_layer(201, 110 + textbox_offset, "LevelDescription", agi("obj_ev_textbox"), 
{
	txt : ev_make_author_textbox_text(nodeless_pack.author),
	base_scale_x : 2,
	base_scale_y : 1,
	layer_num : 1,
	allow_deletion : false,
	char_limit : 0,	
	opened_x : room_width / 2,
	opened_y : room_height / 2,
	image_alpha : 0
})

add_child(description_textbox)
add_child(author_textbox)


function hide_textbox() {
	textbox_open_depth = layer_get_depth("LevelHighlightButtons")
}

textbox_depth = layer_get_depth("LevelHighlightButtons")
textbox_open_depth = layer_get_depth("WindowElements")