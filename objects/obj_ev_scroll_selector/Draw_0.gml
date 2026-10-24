if (!surface_exists(label_surf))
    label_surf = surface_create(224, 16);

draw_set_font(global.ev_font)
draw_set_halign(fa_left)
draw_set_valign(fa_top)


// draw empty search result texts
if array_length(filtered_indices) == 0 {
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_set_color(c_gray);

    draw_set_alpha(0.75);
    draw_sprite(floor_sprite, 0, no_result_px, no_result_py);
    draw_sprite(floor_sprite, 0, no_result_px + 16, no_result_py);
    draw_sprite(floor_sprite, 0, no_result_px - 16, no_result_py);
    draw_sprite(floor_sprite, 0, no_result_px, no_result_py - 16);
    draw_sprite(floor_sprite, 1, no_result_px, no_result_py + 16);
    draw_sprite(floor_sprite, 1, no_result_px + 16, no_result_py + 16);
    draw_sprite(floor_sprite, 1, no_result_px - 16, no_result_py + 16);
    draw_sprite(no_result_sprites[no_result_index], 0, no_result_px, no_result_py);
    draw_set_alpha(1.0);

    draw_text_ext(no_result_px, no_result_py + 16, no_result_texts[no_result_index], 12, width - 20);
    exit;
}


// compute the maximum width of indices to align the labels
var index_width = 0;
for (var i = 0; i < array_length(labels); i++) {
    var str_index = left_pad(string(i), number_of_int_digits(array_length(elements)), "0")
    index_width = max(index_width, string_width($"{str_index}.")); 
}

// total width allowed for labels
var label_width = width - (index_width + left_padding_index + left_padding_label);

// draw a page of elements
for (var i = 0; i < page_size; i++)
{
    var index = i + first_displayed_index;

    if index >= array_length(filtered_indices) {
        break;
    }

    var filtered_index = filtered_indices[index]
    var label = labels[filtered_index]
    var str_index = left_pad(string(filtered_index), number_of_int_digits(array_length(elements)), "0");
    var truncated_label = truncate_labels(filtered_index, label_width);
    var text_width = string_width(truncated_label);
    var px = x;
    var py = y + i * element_height; 

    // draw background color
    if selected_index == filtered_index {
        draw_set_color(selected_bg_color);
    } else if hovered_index == i {
        draw_set_color(hovered_bg_color);
    }

    if selected_index == filtered_index || hovered_index == i {
        draw_rectangle(px, py, px + width - 1, py + element_height - 1, false);
    }

    // draw index + label text
    if selected_index == filtered_index {
        draw_set_color(selected_text_color);
    } else if hovered_index == i {
        draw_set_color(hovered_text_color);
    } else {
        draw_set_color(text_color)
    }

    draw_text(px + left_padding_index, py, $"{str_index}.")
    
    if (selected_index == filtered_index) {
        // selected index: draw the index and the full label on a surface
        target_x_offset = max(0, string_width(labels[filtered_index]) - label_width)
        surface_set_target(label_surf);
        draw_clear_alpha(c_black, 0);
        draw_text(-current_x_offset, 0, label);
        surface_reset_target();
        draw_surface_part(
            label_surf,
            0, 
            0,
            label_width,
            element_height,
            px + left_padding_index + index_width + left_padding_label, 
            py
        )
    } else {
        // other elements: draw the index and the truncated label
        draw_text(
            px + left_padding_index + index_width + left_padding_label, 
            py, 
            truncated_label
        );
    }

}

// draw "..." to hint that there are more elements above
if first_displayed_index > 0 {
    draw_set_halign(fa_center);
    draw_set_color(text_color);
    draw_text(x + (width / 2), y - element_height, "...");
}

// draw "..." to hint that there are more elements below
if first_displayed_index + page_size < array_length(filtered_indices) {
    draw_set_halign(fa_center)
    draw_set_color(text_color);
    draw_text(x + (width / 2), y + (page_size - 1) * element_height + 6, "...");
} 