// add argument2 which will exit early and return song tempo for us

// TARGET: LINENUMBER_REPLACE
// 1
function scr_music_strobe_raw_value(argument0, argument1, argument2)

// TARGET: LINENUMBER
// 123
if argument2
    return _tempo;

// Add bpms of various songs that EV adds so everything animates to their beat
// and also msc_rytmi2 because it doesn't have one
// TARGET: LINENUMBER
// 6
case snd_ev_music_astra_jam:
    _tempo = 81.815
    break;
case snd_ev_music_monsday:
    _tempo = 115
    break;
case snd_ev_music_teusday:
    _tempo = 73.5
    break
case snd_ev_music_blossom:
    _tempo = 140
    break
case snd_ev_music_ex_smooth:
    _tempo = 100
    break
case snd_ev_music_endless_void:
    _tempo = 80
    break
case snd_ev_music_stealie_feelies:
    _tempo = 90
    break;
case snd_ev_music_judgment_jingle:
    _tempo = 93
    break
case snd_ev_music_determined_descent:
    _tempo = 85
    break
case msc_rytmi2:
    _tempo = 142
    break
