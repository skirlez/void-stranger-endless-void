
function ev_tis_pack_check_highscore() {
	new_record_score = 0;
	new_record_time = 0;
	var json = load_pack_highscores(global.pack.save_name)
	if array_length(json.scores) == 0 {
		new_record_score = 1;
		json.scores = [final_score];
	}
	else {
		var record_score = json.scores[0];
		for (i = 1; i < array_length(json.scores); i++) {
			if json.scores[i] > record_score
				record_score = json.scores[i];
		}
		if final_score > record_score {
			new_record_score = 1;
		}
		array_push(json.scores, final_score);
	}
	
	if array_length(json.times) == 0 {
		new_record_time = 1;
		json.times = [finaltime];
	}
	else {
		var record_time = json.times[0];
		for (i = 1; i < array_length(json.times); i++) {
			if json.times[i] < record_time
				record_time = json.times[i];
		}
		if finaltime < record_time {
			new_record_time = 1;
		}
		array_push(json.times, finaltime);
	}
	
	save_pack_highscores(global.pack.save_name, json)
}