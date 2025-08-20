event_inherited();


clone_button = instance_create_layer(x + 50, y + 30, "WindowElements", agi("obj_ev_executing_button"), {
	txt : "Clone",
	base_scale_x : 1.3,
	base_scale_y : 0.7,
	func : function () {
		with (window) {
			try {
				new_pack.save_name = generate_ulid();
				var new_new_pack_string = export_pack(new_pack);
				var file = file_text_open_write(global.packs_directory + new_pack.save_name + "." + pack_extension)
				file_text_write_string(file, new_new_pack_string);
				file_text_close(file)
				ev_notify("Pack cloned!")
				level_select.on_level_update();
			}
			catch (e) {
				ev_notify("Couldn't paste pack!")	
			}
			instance_destroy(id)
		}
	}
})
add_child(clone_button)

update_button = instance_create_layer(x - 50, y + 30, "WindowElements", agi("obj_ev_executing_button"), {
	txt : "Update",
	base_scale_x : 1.5,
	base_scale_y : 0.7,
	func : function () {
		with (window) {
			try {
				var file = file_text_open_write(global.packs_directory + new_pack.save_name + "." + pack_extension)
				file_text_write_string(file, new_pack_string);
				file_text_close(file)
				ev_notify("Pack pasted!")
				level_select.on_level_update();
			}
			catch (e) {
				ev_notify("Couldn't paste pack!")	
			}
			instance_destroy(id)
		}
	}
})
add_child(update_button)