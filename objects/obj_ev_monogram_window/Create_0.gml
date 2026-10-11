event_inherited();

max_width = 14;
max_height = 9;
min_width = 1;
min_height = 1;

spr_monogram_bg = agi("spr_ev_monogram_bg");
center_x = 120;
center_y = 76;


draw_monogram = instance_create_layer(center_x, center_y, "WindowElements", agi("obj_ev_make_monogram"), {
	tiles : copy_array(monogram_properties.tiles),
    width : monogram_properties.width,
    height : monogram_properties.height,
    target_col: monogram_properties.target_col,
    target_row: monogram_properties.target_row,
    max_width: max_width,
    max_height: max_height,
})
add_child(draw_monogram)


add_column = instance_create_layer(center_x + 20, center_y - 54, "WindowElements", agi("obj_ev_executing_button"), {
	sprite_index: agi("spr_ev_play"),
	draw_monogram: draw_monogram,
    max_width: max_width,
	func : function () {
        if (draw_monogram.width == max_width) {
            return;
        }

        for (var row = 0; row < draw_monogram.height; row += 1) {
            var rrow = draw_monogram.height - row - 1;
            array_insert(draw_monogram.tiles, draw_monogram.width * rrow + draw_monogram.width, 0)
        }
		draw_monogram.width += 1
        draw_monogram.image_xscale = draw_monogram.scale * draw_monogram.width
	}
});
add_child(add_column)


remove_column = instance_create_layer(center_x - 20, center_y - 54, "WindowElements", agi("obj_ev_executing_button"), {
	sprite_index: agi("spr_ev_play"),
	draw_monogram: draw_monogram,
    min_width: min_width,
    base_scale_x: -1,
	func : function () {
        if (draw_monogram.width == min_width) {
            return;
        }

        for (var row = 0; row < draw_monogram.height; row += 1) {
            var rrow = draw_monogram.height - row - 1;
            array_delete(draw_monogram.tiles, draw_monogram.width * rrow + draw_monogram.width - 1, 1)
        }
		
		draw_monogram.width -= 1
		if (draw_monogram.target_col == draw_monogram.width)
			draw_monogram.target_col -= 1
        draw_monogram.image_xscale = draw_monogram.scale * draw_monogram.width
		
	}
});
add_child(remove_column)

add_row = instance_create_layer(center_x - 74, center_y + 20, "WindowElements", agi("obj_ev_executing_button"), {
	sprite_index: agi("spr_ev_play"),
	draw_monogram: draw_monogram,
    max_height: max_height,
    image_angle: 90,
    base_scale_x: -1,
	func : function () {
        if (draw_monogram.height == max_height) {
            return;
        }

        // resizing up will set new indices to 0 
        array_resize(draw_monogram.tiles, draw_monogram.width * (draw_monogram.height + 1))

		draw_monogram.height += 1
        draw_monogram.image_yscale = draw_monogram.scale * draw_monogram.height
	}
});
add_child(add_row)

remove_row = instance_create_layer(center_x - 74, center_y - 20, "WindowElements", agi("obj_ev_executing_button"), {
	sprite_index: agi("spr_ev_play"),
	draw_monogram: draw_monogram,
    min_height: min_height,
    image_angle: 90,
	func : function () {
        if (draw_monogram.height == min_height) {
            return;
        }

        array_resize(draw_monogram.tiles, draw_monogram.width * (draw_monogram.height - 1))

		draw_monogram.height -= 1
		if (draw_monogram.target_row == draw_monogram.height)
			draw_monogram.target_row -= 1
        draw_monogram.image_yscale = draw_monogram.scale * draw_monogram.height
	}
});
add_child(remove_row)