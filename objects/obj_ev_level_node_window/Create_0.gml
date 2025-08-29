event_inherited();
function commit() {
	node_instance.properties.level.bount = int64_safe(bount_textbox.txt, -1);
	node_instance.properties.level.name = name_textbox.txt
	try_level_name_and_rename(node_instance.properties.level, get_all_level_node_instances())
}

var level = node_instance.properties.level;

var txt;
if level.bount >= 0
	txt = string(level.bount);
else
	txt = "???";


name_textbox = instance_create_layer(x - 30, y - 30, "WindowElements", agi("obj_ev_textbox"), {
	empty_text : "Level Name",
	txt : level.name,
	allow_newlines : false,
	automatic_newline: false,
	char_limit : 30,
	base_scale_x : 5,
});
name_warning = instance_create_layer(x + 40, y - 30, "WindowElements", agi("obj_ev_textbox"), {
	txt : "WARNING! To save pack progress for players, EV saves the level's name to a file."
		+ " If you have uploaded this pack, DON'T modify the level names! Otherwise players"
		+ " who saved on those levels will have their save erased!",
	allow_deletion : false,
	char_limit : -1,
	
	allow_deletion : false,
	base_scale_x : 3,
});

bount_textbox = instance_create_layer(x - 54, y, "WindowElements", agi("obj_ev_textbox"), {
	empty_text : "Brane Count",
	txt : txt,
	allow_alphanumeric : false,
	exceptions : "?0123456789",
	char_limit : 3,
	base_scale_x : 2,
});

var copy = instance_create_layer(x + 55, y + 30, "WindowElements", agi("obj_ev_executing_button"), {
	layer_num : 1,
	lvl : level,
	sprite_index : agi("spr_ev_copy"),
	func : function () {
		var str = export_level(lvl);
		clipboard_set_text(str)
		ev_notify("Copied to clipboard!")
	}
})

var edit = instance_create_layer(x + 55, y + 5, "WindowElements", agi("obj_ev_executing_button"), {
	layer_num : 1,
	lvl : level,
	sprite_index : agi("spr_ev_edit_level"),
	func : function () {
		window.commit();
		with (global.pack_editor) {
			remember_zoom = zoom;
			remember_camera_x = camera_get_view_x(view_camera[0])
			remember_camera_y = camera_get_view_y(view_camera[0])		
		}
		global.level = lvl;
		// set to false again on obj_ev_pack_level_node create, once the one with the same node id is created
		global.editing_pack_level = true;
		global.editing_pack_level_nid = window.node_instance.node_id;
		
		// so it remembers what the pack is
		global.pack.starting_node_states = convert_room_nodes_to_structs()
		room_goto(global.editor_room)
	}
})


add_child(bount_textbox);
add_child(name_textbox);
add_child(name_warning);
add_child(copy);
add_child(edit);

is_brand_room = is_level_brand_room(level)

elements_depth = layer_get_depth("WindowElements")