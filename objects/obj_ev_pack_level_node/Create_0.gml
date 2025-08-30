image_xscale = global.level_node_display_scale
image_yscale = global.level_node_display_scale

node_instance_setup(level_get_exit_count(properties.level), true, 112 * image_xscale, 72 * image_yscale)
// no need
no_culling = false;


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