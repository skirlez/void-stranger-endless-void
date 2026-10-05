event_inherited()

if (remember_brand != properties.brand) {
	sprite_delete(brand_sprite);
	brand_sprite = create_brand_sprite(properties.brand);
	sprite_index = brand_sprite;
	remember_brand = properties.brand;
}