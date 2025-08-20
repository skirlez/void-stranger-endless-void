event_inherited();

timer = 0;
deleting = true
audio_play_sound(agi("snd_lockdamage"), 10, false)
audio_pause_sound(global.music_inst)
layer = layer_get_id("DeleteSaveButton")