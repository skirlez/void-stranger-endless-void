event_inherited();

textbox_instance = instance_create_layer(x, y, "WindowElements", agi("obj_ev_textbox"), {
	empty_text : "Branefuck Program",
	txt : node_instance.properties.program,
	allow_alphanumeric : true,
	exceptions : global.branefuck_characterset,
	char_limit : 9999,
	base_scale_x : 8,
});

add_child(textbox_instance);