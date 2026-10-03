vsp += 0.06
image_angle -= hsp * 5

x += hsp
y += vsp

if y - sprite_height / 2 > room_height
	instance_destroy(id)