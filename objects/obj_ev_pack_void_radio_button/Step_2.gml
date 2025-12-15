var cam_x = camera_get_view_x(view_camera[0])
var cam_y = camera_get_view_y(view_camera[0])
var cam_width = camera_get_view_width(view_camera[0])
var cam_height = camera_get_view_height(view_camera[0])
ratio_x = cam_width / 224;
ratio_y = cam_height / 144;

scale_x *= ratio_x
scale_y *= ratio_y

image_xscale = scale_x / base_scale_x
image_yscale = scale_y / base_scale_y
x = cam_x + xstart * ratio_x;
y = cam_y + ystart * ratio_y;

spin_time_h += 0.45 + additional_spin
spin_time_v += 0.38 + additional_spin
spin_h = (dsin(spin_time_h) + 1) / 2;
spin_v = (dcos(spin_time_v) + 1) / 2;

if additional_spin > 0
	additional_spin *= 0.92
else
	additional_spin = 0;
	

if (global.pack_editor.pack_arrow_boost_max - global.pack_editor.pack_arrow_boost) > 0.06 {
	music_index = -1	
}
else {
	music_index = 0;
	for (var i = 0; i < array_length(global.music_names); i++) {
		if audio_get_name(global.music_inst) == global.music_names[i]
			music_index = i
	}
}


number_angle = dcos(spin_time_h) * 7
	+ (global.pack_editor.pack_arrow_boost_max - global.pack_editor.pack_arrow_boost) * 200
number_size = lerp(number_size, global.void_radio_on, 0.4)

number_x = dcos(spin_time_h * 1.5) * number_size
number_y = dsin(spin_time_v * 1.5) * number_size