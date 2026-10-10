for (var row = 0; row < height; row += 1) {
    for (var col = 0; col < width; col += 1) {
        var color = tiles[row * width + col] ? c_white : c_black;
        draw_rectangle_color(
            x + col * scale, 
            y + row * scale, 
            x + (col + 1) * scale - 1,
            y + (row + 1) * scale - 1,
            color,
            color,
            color,
            color,
            false
        )
    }
}

draw_sprite(
    target_sprite,
    0,
    x + target_col * scale, 
    y + target_row * scale,
)