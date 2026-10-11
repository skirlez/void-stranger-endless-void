
var tile;
if(global.tile_mode) {
	tile = global.editor.current_list[tile_ind]
} else {
	tile = global.editor.current_list[object_ind]
}

if (tile == global.editor.object_player)
	sprite_index = ev_get_stranger_down_sprite(global.stranger)
else
	sprite_index = tile.spr_ind
	
image_index = tile.img_ind


if selected {
	var alpha = (dsin(global.editor_time * 4) / 5) + 0.75
	var inst = instance_position(mouse_x, mouse_y, agi("obj_ev_placeable_selection"))
	if !instance_exists(inst) || inst.layer_num != layer_num {
		draw_sprite_ext(sprite_index, image_index, x, y, scale_x, scale_y, 0, c_white, 1)
	}
	else {
		if (global.tile_mode)
			var tile = global.editor.tiles_list[inst.tile_ind]	
		else 
			var tile = global.editor.objects_list[inst.object_ind]
		draw_sprite_ext(sprite_index, image_index, x, y, scale_x, scale_y, 0, c_white, alpha)
		draw_sprite_ext(tile.spr_ind, tile.img_ind, x, y, scale_x, scale_y, 0, c_white, 1 - alpha)
	}



	
	draw_set_color(c_white)
	draw_circle(x - 0.5, y - 0.5, dsin(global.editor_time) / 2 + 2.5, false)

	draw_set_color(c_black)
	draw_line_width(x - 0.5, y - 0.5, mouse_x, mouse_y, 1)	
	draw_circle(x - 0.5, y - 0.5, dsin(global.editor_time) / 2 + 2, false)
	
	draw_circle(mouse_x, mouse_y, 0.5, false)

	

}
else
	draw_sprite_ext(sprite_index, image_index, x, y, scale_x, scale_y, 0, c_white, 1)