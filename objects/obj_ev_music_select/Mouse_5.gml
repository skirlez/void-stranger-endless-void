if !ev_is_mouse_on_me()
	exit;
index--
if index < 0
	index = array_length(musics) - 1
	
ev_play_music(musics[index])
txt = string(index)

if boost_pack_arrow_progress {
	global.pack_editor.boost_pack_arrow();
}