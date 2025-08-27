event_inherited();
transition = false;
transition_timer = 0;
if !global.seen_intro { 
	global.seen_intro = true;
	animate = true;
	timer = 0;
	ev_play_music(agi("msc_gotstaff"), false, true)
}
else
	animate = false;
	
dust_emit_counter = 0;
dust_emit_limit = 0;

increase_lerp = 0;