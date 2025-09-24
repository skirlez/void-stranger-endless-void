function ev_on_pack_cif_reset(){
	static pack_player = agi("obj_ev_pack_player");
	global.player_blink = 0
	ev_reset_locusts()
	global.editor.reset_branefuck_persistent_memory()
	ds_map_clear(pack_player.pack_memories)
	pack_player.move_to_root_state();
	if global.pack_parameters.tis {
		ev_play_music(agi("msc_stg_extraboss"), true, false)
		instance_destroy(agi("obj_cc_medal"))
		ev_set_tis_up()
	}
}