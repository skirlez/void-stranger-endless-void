event_inherited();

var spr_close_window =  agi("spr_ev_alt_close_window");

var left = target_x - target_image_xscale * sprite_get_width(sprite_index) / 2;
var right = target_x + target_image_xscale * sprite_get_width(sprite_index) / 2;
var top = target_y - target_image_yscale * sprite_get_height(sprite_index) / 2;

scroll_selector = instance_create_layer(left + 1, top + 24, "WindowElements2", agi("obj_ev_scroll_selector"), 
{
	width: target_image_xscale * sprite_get_width(sprite_index) - 2,
    selected_index: selected_index,
	elements: elements,
    labels: labels,
	on_select: on_select,
    on_confirm: function () {
        window.close();
    },
})
add_child(scroll_selector)

search_box = instance_create_layer(target_x, top + sprite_get_height(sprite_index) / 2, "WindowElements2", agi("obj_ev_textbox"), 
{
	empty_text : "Search...",
	allow_newlines : false,
	automatic_newline : false,
	char_limit : 50,
	base_scale_x : target_image_xscale / 2,
	change_func : function () {
        window.scroll_selector.filter_elements_by_text(txt);
	}
})
add_child(search_box)


close_btn = instance_create_layer(right - sprite_get_width(spr_close_window) / 2 - 2, top + sprite_get_height(spr_close_window) / 2 + 2, "WindowElements2", agi("obj_ev_executing_button"), {
	sprite_index : spr_close_window,
	func : function () {
        window.close();
	}
})
add_child(close_btn)