event_inherited()
var json = load_pack_highscores(save_name)
times = json.times;
array_sort(times, false)
scores = json.scores;
array_sort(scores, false)