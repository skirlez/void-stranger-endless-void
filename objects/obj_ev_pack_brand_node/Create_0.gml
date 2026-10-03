event_inherited();

function create_brand_sprite(brand) {
	var brand_surface = surface_create(6, 6)
	surface_set_target(brand_surface)
	draw_clear(c_black)
	ev_draw_brand(0, 0, brand)
	surface_reset_target()

	return sprite_create_from_surface(brand_surface, 0, 0, 6, 6, false, false, 3, 3)

}
brand_sprite = create_brand_sprite(properties.brand);
sprite_index = brand_sprite;
remember_brand = properties.brand;