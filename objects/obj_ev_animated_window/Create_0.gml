event_inherited();

enum window_anim_state {
    opening,
    closing,
    displaying,
}
anim_state = window_anim_state.opening
anim_counter = 0
opening_time = 16
closing_time = 8


target_x = x
target_y = y
target_image_xscale = image_xscale
target_image_yscale = image_yscale


// source_x, source_y, source_image_xscale, source_image_yscale are in Variable Definitions
// defaulted to the same values as target_*
x = source_x
y = source_y
image_xscale = source_image_xscale
image_yscale = source_image_yscale

// curve for opening/closing animation
curve = animcurve_get_channel(ac_window_opening, 0) // TODO: use a separate animation curve


function close() {
    anim_state = window_anim_state.closing; 
    anim_counter = 0;
	event_user(1);
}
