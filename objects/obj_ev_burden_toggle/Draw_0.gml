event_inherited()
if burden_ind == burden_types.swapper 
	draw_sprite(swapper_sprite, 1, x - 8, y + 8)
else if burden_ind == burden_types.stackrod
	draw_sprite(stackrod_sprite, 1, x - 8, y + 8)
else 
	draw_sprite_part(burdens_sprite, 0, 16 + burden_ind * 16, 0, 16, 16, x - 8, y + 8)