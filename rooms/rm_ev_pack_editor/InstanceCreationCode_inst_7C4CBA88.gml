func = function() {
	static grube_obj = agi("obj_ev_grube")
	var grube = instance_create_layer(x + irandom_range(-20, 0), y - 42, "Grube", grube_obj, {
		type : ev_grube_types.player_cube
	})
}