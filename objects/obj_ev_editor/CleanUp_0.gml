ds_map_destroy(global.placeable_name_map)
ds_map_destroy(global.beaten_levels_map)
ds_map_destroy(global.level_key_map)
ds_map_destroy(global.key_level_map)
ds_map_destroy(global.happenings);
ds_map_destroy(global.static_hashset)

if global.logging_socket != noone
	network_destroy(global.logging_socket)

clean_struct_maps()
ds_map_destroy(global.struct_map_cleaner)
surface_free(spin_surface)

ds_map_destroy(global.branefuck_command_functions)
ds_map_destroy(global.branefuck_command_tiles)
ds_map_destroy(global.locusts_collected_this_level)

ds_map_destroy(global.blobtable)