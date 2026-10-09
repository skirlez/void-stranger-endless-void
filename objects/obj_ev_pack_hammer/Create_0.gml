event_inherited()
base_scale_x_start = base_scale_x
base_scale_y_start = base_scale_y


global.pack_editor.select_tool_happening.subscribe(function (struct) {
	selected = (struct.new_selected_thing == pack_things.hammer)
	if !selected
		global.pack_editor.judging_node = noone
})