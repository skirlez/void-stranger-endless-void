event_inherited()

var play = instance_create_layer(208, 40, "LevelHighlightButtons", agi("obj_ev_play_button"))
play.layer_num = 1
play.lvl = lvl
play.lvl_sha = lvl_sha
play.display_instance = display_instance
play.highlighter = id;
play.image_alpha = 0

var copy = instance_create_layer(192, 40, "LevelHighlightButtons", agi("obj_ev_executing_button"), {
	layer_num : 1,
	lvl : lvl,
	image_alpha : 0,
	sprite_index : agi("spr_ev_copy"),
	func : function () {
		var str = export_level(lvl);
		clipboard_set_text(str)
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
	
	var edit = instance_create_layer(192, 73, "LevelHighlightButtons", agi("obj_ev_edit_button"))
	edit.layer_num = 1
	edit.lvl = lvl
	edit.display_instance = display_instance
	edit.highlighter = id
	edit.image_alpha = 0
	
	var deleteb = instance_create_layer(192, 90, "LevelHighlightButtons", agi("obj_ev_delete_button"))
	deleteb.layer_num = 1
	deleteb.level_select = instance_find(agi("obj_ev_level_select"), 0)
	deleteb.save_name = lvl.save_name
	deleteb.display_instance = display_instance
	deleteb.image_alpha = 0

	var upload = instance_create_layer(208, 90, "LevelHighlightButtons", agi("obj_ev_upload_button"))
	upload.layer_num = 1
	upload.level_or_save_name = lvl;
	upload.image_alpha = 0;
	upload.is_pack = false;




	textbox_offset = 20;
	add_child(deleteb)
	add_child(upload)
	add_child(edit)
}
else {
	date_textbox = instance_create_layer(201, 130, "LevelDescription", agi("obj_ev_textbox"), 
	{
		txt : ("Upload date:\n" 
			+ format_date(lvl.upload_date) 
			+ "\nLast edited date:\n" 
			+ format_date(lvl.last_edit_date)),
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
	txt : (lvl.description == "" ? "No description provided." : "Description:\n" + lvl.description),
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
	txt : ev_make_author_textbox_text(lvl.author),
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