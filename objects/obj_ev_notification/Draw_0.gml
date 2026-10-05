draw_set_halign(fa_left)
draw_set_valign(fa_top)
draw_set_color(c_black)
draw_set_font(global.ev_font)

var cam_x = camera_get_view_x(view_camera[0])
var cam_y = camera_get_view_y(view_camera[0])

var scale_x = camera_get_view_width(view_camera[0]) / 224
var scale_y = camera_get_view_height(view_camera[0]) / 144

ev_draw_rectangle(
	cam_x + (x - 2) * scale_x, 
	cam_y + (y - 2) * scale_y, 
	cam_x + (x + string_width(txt) + 2) * scale_x, 
	cam_y + (y + string_height(txt)) * scale_y,
	false)
draw_set_color(c_white)
draw_text_transformed(cam_x + x * scale_x, cam_y + y * scale_y, txt, scale_x, scale_y, 0)


