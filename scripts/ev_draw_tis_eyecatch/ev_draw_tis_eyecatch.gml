function ev_draw_tis_eyecatch(grade, pos_x, pos_y) {
	var spr = agi("spr_lamp");
	if grade == 0
		spr = agi("spr_player_down")
	else if grade == 1
		spr = agi("spr_lil_down")
	else if grade == 2
		spr = agi("spr_cif_down")
	else if grade == 3
		spr = agi("spr_ev_tis_statue")
	else if grade == 4
		spr = agi("spr_ev_tis")
		
	var spin_h = (dsin(global.editor_time * 0.3) + 1) / 2;
	var spin_v = (dcos(global.editor_time * 0.45) + 1) / 2;
	var size = 45;
	var offset = 95
	ev_draw_cube(spr, global.editor_time % 50 < 25, pos_x + size + offset, pos_y + size, size, spin_h, spin_v)
}