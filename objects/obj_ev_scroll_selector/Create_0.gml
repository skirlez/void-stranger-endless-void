// page_size, width and element_height in Variable Definitions

first_displayed_index = min(selected_index + page_size, array_length(elements)) - page_size
hovered_index = -1

// indices of filtered elements
all_indices = array_create(array_length(elements))
for (var i = 0; i < array_length(all_indices); i++) {
    all_indices[i] = i;
}
filtered_indices = all_indices

// hitbox of the selector, sprite is a 1x1 image
image_xscale = width
image_yscale = element_height * page_size

// text paddings
left_padding_index = 5
left_padding_label = 5

// surface to scroll the text horizontally when the selected element is too long
label_surf = -1
current_x_offset = 0;
target_x_offset = 0;
x_scroll_state = 0;
x_scroll_counter = 0;
x_offset_time = 90;
x_offset_pause_time = 60;
x_offset_start_time = 16;
max_x_offset_speed = 1;

// sound played when scrolling up/down
snd_scroll = agi("snd_ev_scroll")

// color constants used to draw the list of elements
text_color = c_ltgray
hovered_text_color = c_white
hovered_bg_color = c_gray
selected_text_color = c_black
selected_bg_color = c_white

// empty results texts and sprites
no_result_sprites = [
    agi("spr_boulder"),
    agi("spr_voider"),
    agi("spr_pit"),
    agi("spr_slower"),
    agi("spr_watcher"),
    agi("spr_atoner"),
];
no_result_texts = [
    "Don't ask how I search...",                // egg
    "...",                                      // add
    "[You made the results go away]",           // tan
    "How bothersome.",                          // gor
    "One wrong search and I'll destroy you...", // lev
    "Only a simple search remains",             // cif
];
floor_sprite = agi("spr_floor");
no_result_index = irandom_range(0, array_length(no_result_texts) - 1);
no_result_px = x + width / 2;
no_result_py = y + page_size * element_height / 2 - 8;

// cache for truncated labels to avoid recomputing them everytime they are drawn
truncated_labels = array_create(array_length(labels), noone)

function truncate_labels(index, max_width, suffix = "...") {
    if truncated_labels[index] != noone {
        return truncated_labels[index];
    }

    var txt = labels[index];

    if (string_width(txt) <= max_width) {
        truncated_labels[index] = txt;
        return txt;
    }

    var limit = max_width - string_width(suffix);
    var low = 0
    var high = string_length(txt)

    // binary search for efficient character-perfect truncation
    while (low < high) {
        var middle = (low + high + 1) div 2;

        if string_width(string_copy(txt, 1, middle)) <= limit {
            low = middle;
        } else {
            high = middle - 1;
        }
    }

    txt = string_copy(txt, 1, low) + suffix;
    truncated_labels[index] = txt;
    return txt;
}

function filter_elements_by_text(txt) {
    if txt == "" {
        filtered_indices = all_indices
        no_result_index = irandom_range(0, array_length(no_result_texts) - 1);;
        return;
    }

    var search_text = string_lower(txt);


    filtered_indices = []
    for (var i = 0; i < array_length(elements); i++) {
        if (search_text != "" && string_pos(search_text, string_lower(labels[i])) == 0)
            continue;
        
        array_push(filtered_indices, i);
    }
    first_displayed_index = max(0, min(first_displayed_index + page_size, array_length(filtered_indices)) - page_size)
}