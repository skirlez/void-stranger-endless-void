if !surface_exists(brand_surface)
	brand_surface = surface_create(6, 6)
	
surface_set_target(brand_surface)
draw_clear(c_black)
draw_set_color(c_white)
ev_draw_brand(0, 0, brand)
surface_reset_target();


draw_surface_ext(brand_surface, x, y, scale, scale, 0, c_white, 1)
