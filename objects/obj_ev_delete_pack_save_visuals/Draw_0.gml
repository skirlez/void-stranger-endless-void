timer++;
bg_alpha += 0.015
draw_set_alpha(bg_alpha)

draw_set_color(c_white)
ev_draw_rectangle(0, 0, room_width, room_height, false)

if timer > 100 {
	if timer > 300 {
		jumparound += 0.06
		if jumparound > 20
			jumparound = 20;
			
		if timer % 2 == 0 {
			rand[0] = random_range(-1, 1)
			rand[1] = random_range(-1, 1)
			rand[2] = random_range(-1, 1)
			rand[3] = random_range(-1, 1)
		}
			
	}
	
	text_alpha += 0.02
	draw_set_alpha(text_alpha)
	draw_set_halign(fa_center)
	draw_set_halign(fa_middle)
	draw_set_color(c_gray)
	var txt = "YOUR SAVE IS GETTING DELETED!!!!";
	draw_text(room_width / 2 + rand[0] * jumparound,
		room_height / 2 - 16 + rand[1] * jumparound,
		txt)
	draw_set_color(c_black)
	draw_text(room_width / 2 + rand[2] * jumparound,
		room_height / 2 - 16 + rand[3] * jumparound,
		txt)
	
}