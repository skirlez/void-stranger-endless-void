draw_set_color(c_black)
draw_set_alpha(alpha)

var camera_x = camera_get_view_x(view_camera[0])
var camera_y = camera_get_view_y(view_camera[0])

ev_draw_rectangle(camera_x, camera_y, camera_x + 224, camera_y + 144, false)
draw_set_alpha(1)