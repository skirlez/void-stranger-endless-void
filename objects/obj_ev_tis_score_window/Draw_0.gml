draw_self()
draw_set_valign(fa_top)
draw_set_halign(fa_center)
draw_set_color(c_white)
var times_string = "Times"
var scores_string = "Scores"
for (var i = 0; i < min(array_length(times), 5); i++) {
	times_string += "\n" + string(times[i]) + "s"
}
for (var i = 0; i < min(array_length(scores), 5); i++) {
	scores_string += "\n" + string(scores[i])
}
draw_text_shadow(x - 50, y - 40, times_string)
draw_text_shadow(x + 50, y - 40, scores_string)