event_inherited()
function calculate_offset_direction() {
	var angle = point_direction(x, y, mouse_x, mouse_y);
	// 16 wind compass rose directions, represented by 0-15
	angle = round(angle / 22.5)
	// convert to 0-8 representing cardinals and diagonals with a bias towards cardinals
	angle = (angle - dsin(angle * 90)) / 2;
	
	// back to angles
	angle *= 45
	return { offset_x : round(dcos(angle)), offset_y : -round(dsin(angle)) };
}
empty_offset_struct = { offset_x : 0, offset_y : 0 };

sprites_array = [sprite_index, sprite_index, sprite_index, sprite_index, sprite_index, sprite_index];
indices_array = [0, 1, 1, 1, 1, 1];