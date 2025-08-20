timer = 80
state = end_animation_states.start
enum end_animation_states {
	start,
	you_win,
	stats,
	done,
}

you_win_y = -20
stats_title_y = -20

var pack_player = agi("obj_ev_pack_player")

function get_stat_height(i) {
	return 50 + 14 * i	
}

var total_play_time = pack_player.play_time + current_time - pack_player.start_time;
var seconds = num_to_string((total_play_time div 1000) % 60, 2)
var minutes = num_to_string((total_play_time div 60000) % 60, 2)
var hours = num_to_string(total_play_time div 3600000, 2)

stat_texts = [
	"Deaths",
	"Time spent",
	"Crystals collected",
	"Locusts collected",
	"Distinct branes visited"]
stat_values = [
	string(global.death_count),
	$"{hours}:{minutes}:{seconds}",
	string(ds_map_size(pack_player.pack_memories)),
	string(pack_player.total_locusts_collected),
	string(ds_map_size(pack_player.visited_levels))
]

stat_texts_x = array_create(array_length(stat_values))
for (var i = 0; i < array_length(stat_values); i++) {
	var alt;
	if i % 2 == 0
		alt = -200;
	else
		alt = 424;
	stat_texts_x[i] = alt;

}
stat_values_y = array_create(array_length(stat_values), 200)

stats_level = -1
stats_delay = 25

var lengths = [];
draw_set_font(global.ev_font)
for (var i = 0; i < array_length(stat_texts); i++) {
	array_push(lengths, string_width(stat_texts[i] + ":  " + stat_values[i]))	
}
array_sort(lengths, false)



stats_x_left = floor(112 - lengths[0] / 2)
stats_x_right = floor(112 + lengths[0] / 2)