
function ev_badge() constructor {
	draw_func = noone;
	//			draw_set_color(c_grey)
	// ev_draw_rectangle(pos_x, pos_y, pos_x + 7, pos_y + 7, true)
}

function brand_badge(brand) : ev_badge() constructor {
	self.brand = brand
	draw_func = function () {
		draw_set_color(c_white)
		ev_draw_brand(0, 0, brand)
	}	
}
function sprite_badge(sprite) : ev_badge() constructor {
	self.sprite = sprite
	draw_func = function () {
		draw_sprite(sprite, 0, 0, 0)
	}	
}
function memory_badge() : ev_badge() constructor {
	draw_func = function () {
		var time = (global.editor_time / 2) % 80
		static spr = agi("spr_ev_memory_badge")
		if time > sprite_get_number(spr) - 1
			time = 0;
		draw_sprite(spr, time, 0, 0)
	}	
}


