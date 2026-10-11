
var ind = global.tile_mode ? tile_ind : object_ind
var tile = global.editor.current_list[ind]
if (tile == global.editor.object_player)
	sprite_index = ev_get_stranger_down_sprite(global.stranger)
else
	sprite_index = tile.spr_ind


if (selected) {
	if (global.tile_mode) {
		var color = c_black
		var sprite = global.white_floor_sprite
	}
	else {
		color = c_white
		sprite = sprite_index
	}
	
	gpu_set_fog(true, color, 0, 1)
	var increase = dsin(global.editor_time) / 8 + 0.25;
	draw_sprite_ext(sprite, 0, x, y, scale_x + increase, scale_y + increase, 0, c_white, 1)
	gpu_set_fog(false, color, 0, 1)
}


draw_sprite_ext(sprite_index, tile.img_ind, x, y, scale_x, scale_y, 0, c_white, 1)
	
	
