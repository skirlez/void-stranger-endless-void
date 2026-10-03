image_angle += sign(hsp) * 5;
vsp += 0.2

x += hsp
y += vsp

if y - sprite_height / 2 > room_height
	instance_destroy(id)