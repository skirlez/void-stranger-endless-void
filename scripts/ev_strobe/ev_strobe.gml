
function ev_strobe_integer(iframes){
	var func = agi("scr_music_strobe_integer")
	if func == -1
		return 0;
	else
		return func(iframes)
}
function ev_strobe_fasttriplet_real(iframes) {
	var func = agi("scr_music_strobe_fasttriplet_real")
	if func == -1
		return 0;
	else
		return func(iframes)	
	
}
function ev_get_track_bpm(track, position) {
	var func = agi("scr_music_strobe_raw_value")
	if func == -1 {
		return -1;
	}
	else {
		return func(track, position, true)
	}
}