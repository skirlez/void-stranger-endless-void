max_distance = 10
max_radius = 3;
circles = [
	 { angle : 360 * 0/3 - 90, distance : max_distance / 3, radius : 0 },
	 { angle : 360 * 1/3 - 90, distance : max_distance / 3, radius : 0},
	 { angle : 360 * 2/3 - 90, distance : max_distance / 3, radius : 0 }
]
timer = global.pack_editor.placechanger_copying_max;
lerp_up_to = 1;
move_in = false;
add_angle = random(360);