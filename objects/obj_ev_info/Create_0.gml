event_inherited();
rules = instance_create_layer(112, 72 - 30, "Instances", agi("obj_ev_executing_button"), {
	base_scale_x : 2.5,
	base_scale_y : 0.7,
	txt : "Server Rules",
	func : function () {
		url_open("https://github.com/skirlez/void-stranger-endless-void/wiki/Main-Server-Rules")
		ev_notify("Opening browser window...")
	}
});
add_child(rules)

level_docs = instance_create_layer(112 - 40, 72, "Instances", agi("obj_ev_executing_button"), {
	base_scale_x : 2.1,
	base_scale_y : 0.7,
	txt : "Level Docs",
	func : function () {
		url_open("https://github.com/skirlez/void-stranger-endless-void/wiki/Level-Editor-Documentation")
		ev_notify("Opening browser window...")
	}
});
add_child(level_docs)
pack_docs = instance_create_layer(112 + 40, 72, "Instances", agi("obj_ev_executing_button"), {
	base_scale_x : 2.1,
	base_scale_y : 0.7,
	txt : "Pack Docs",
	func : function () {
		url_open("https://github.com/skirlez/void-stranger-endless-void/wiki/Pack-Editor-Documentation")
		ev_notify("Opening browser window...")
	}
});
add_child(pack_docs)