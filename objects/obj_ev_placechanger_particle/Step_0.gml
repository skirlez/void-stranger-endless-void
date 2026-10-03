function do_friction(value, fric) {
	var s = sign(value)
	value -= fric * s
	if sign(value) != s
		return 0;
	return value;
	
}

x += hsp
y += vsp

image_alpha = max(0, (hsp * hsp + vsp * vsp) / 9)
if image_alpha == 0
	instance_destroy(id)
hsp = do_friction(hsp, 0.1)
vsp = do_friction(vsp, 0.1)

