event_inherited()

function commit() {
	global.pack.name = name_textbox.txt
	global.pack.description = description_textbox.txt	
	global.pack.password_brand = password_brand.brand;
}

save_button = instance_create_layer(30, 20, "WindowElements", agi("obj_ev_executing_button"), 
{
	func : function () {
		with (window)
			commit()
		if (global.pack.name == "") {
			ev_notify("Cannot save a pack\nwithout a name.")
			return;
		}
		var nodes = get_all_node_instances();
		var has_level = false;
		for (var i = 0; i < array_length(nodes); i++) {
			if nodes[i].node_type == global.pack_editor.level_node
				has_level = true;
		}
		if !has_level {
			ev_notify("Cannot save a pack\nwithout any levels.")
			return;
		}
		var starting_nodes = convert_room_nodes_to_structs()
		global.pack.starting_node_states = starting_nodes;
		var thumbnail = get_thumbnail_level_from_nodes(starting_nodes);
		global.pack.thumbnail_level = export_level(thumbnail);
		if save_pack(global.pack) {
			ev_notify("Pack saved!")
			global.pack_editor.save_timestamp = current_time;	
		}
		else
			ev_notify("Error saving pack!")	
	},
	txt : "Save",
	base_scale_y : 0.7
})

quit_button = instance_create_layer(70, 20, "WindowElements", agi("obj_ev_main_menu_button"), 
{
	txt : "Quit",
	base_scale_x : 1.2,
	base_scale_y : 0.7,
	room_name : "rm_ev_pack_select"
})
add_child(quit_button)

name_textbox = instance_create_layer(54, 42, "WindowElements", agi("obj_ev_textbox"), 
{
	txt : global.pack.name,
	empty_text : "Pack Name",
	base_scale_x : 5,
	allow_newlines : false,
	automatic_newline: false,
	char_limit : 30,
	opened_x : 112,
	opened_y : 72,
	//exceptions: "~`!@#$%^&()_=-+{} [],.;'"
})
description_textbox = instance_create_layer(70, 60, "WindowElements", agi("obj_ev_textbox"), 
{
	txt : global.pack.description,
	empty_text : "Pack Description",
	char_limit : 256,
	base_scale_x : 7,
	allow_newlines : false,
	opened_x : 112,
	opened_y : 72,
})


add_child(save_button)
add_child(name_textbox)
add_child(description_textbox)

password_brand = instance_create_layer(32, 110, "WindowElements", agi("obj_ev_make_brand"), {
	brand : global.pack.password_brand
})
add_child(password_brand)


elements_depth = layer_get_depth("WindowElements")