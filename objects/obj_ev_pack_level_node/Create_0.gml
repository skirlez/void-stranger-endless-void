event_inherited()

// this is work that is done twice (unfortunately)
// gamemaker doesn't provide very good facilities for inheritence

image_xscale = global.level_node_display_scale
image_yscale = global.level_node_display_scale
center_x_offset = 112 * image_xscale
center_y_offset = 72 * image_yscale
set_scale_and_center_start()
line_drawer.update()

max_exits = level_get_exit_count(properties.level)

display = instance_create_layer(x, y, "PackLevels", global.display_object, 
{ 
	lvl : properties.level,
	name : properties.level.name,
	brand : properties.level.author_brand,
	draw_beaten : false,
	no_spoiling : false,
	display_context : display_contexts.pack_editor,
	owner_node : id,
	mask_index : agi("spr_ev_nothing")
})

function sync_display_with_me() {
	display.image_xscale = image_xscale;
	display.image_yscale = image_yscale;
	display.x = x + shake_x_offset;
	display.y = y;
	if display.lvl != properties.level
		sync_display_level()
	
}
sync_display_with_me()
sync_in_step = true;

function sync_display_level() {
	display.lvl = properties.level;
	display.name = properties.level.name;
	display.delete_cached_game_surface();
	display.delete_cached_name_surface();	
}
