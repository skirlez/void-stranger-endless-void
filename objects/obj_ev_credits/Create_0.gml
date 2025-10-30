event_inherited()


var camera_y = camera_get_view_y(view_camera[0]);

grube_mode = false
grube_button = instance_create_layer(200, camera_y + 30, "WindowElements", agi("obj_ev_executing_button"), {
	txt : "Grube",
	base_scale_x : 1.2,
	base_scale_y : 0.9,
	count : 0,
	func : function () {
		static grube_obj = agi("obj_ev_grube");
		var type;
		if count < 5
			type = ev_grube_types.player_cube;
		else
			type = choose(ev_grube_types.player_cube, 
						ev_grube_types.player_cube,
						irandom_range(1, ev_grube_types.size - 1));
		var grube = instance_create_layer(200 + irandom_range(-20, 20), y + 42, "Grube", grube_obj, {
			type : type
		})
		grube.window = window;
		array_push(window.grubes, grube)
		count++;
		if count == 5 {
			// in case we get a level cube lol
			global.tile_mode = false;
			with (window) {
				grube_mode = true;
				remove_child(scroll_button_up)
				remove_child(scroll_button_down)
				instance_destroy(scroll_button_up)
				instance_destroy(scroll_button_down)
				var t = instance_create_layer(200, camera_get_view_y(view_camera[0]) + 72, "Textbox", agi("obj_ev_textbox"), {
					opened_x : 112,
					opened_y : 72 + camera_get_view_y(view_camera[0]),
					txt : "Stack the grubes!\nLeft click to grab, right click to destroy. " 
						+ "You can scroll with the scroll wheel or the up/down keys."
						+ "\nCAREFUL: Grubes under too much pressure may be destroyed...\n"
						+ "Try to keep a modest amount."
					,
					layer_num : 0,
					allow_deletion : false,
					char_limit : 0,
				})
				add_child(t)
			}
			
			
			
			audio_sound_gain(global.music_inst, 0, 1000)
			global.music_inst = noone
			ev_play_music(agi("msc_stg_extraboss"), true, true)
			audio_sound_gain(global.music_inst, 0, 0)
			audio_sound_gain(global.music_inst, 1, 1000)
			instance_create_layer(mouse_x, mouse_y, "Plucker", agi("obj_ev_plucker"))
		}
		

	}
})
add_child(grube_button)


scroll_button_down = instance_create_layer(200, camera_y + 88, "WindowElements", agi("obj_ev_executing_scroll_button"), {
	func : function () {
		with (window) {
			current_page_index++;
			if current_page_index >= array_length(credits)
				current_page_index = 0;
			load_credits_page(current_page_index)
		}
	}
})
scroll_button_up = instance_create_layer(200, camera_y + 56, "WindowElements", agi("obj_ev_executing_scroll_button"), {
	image_index : 1,
	func : function () {
		with (window) {
			current_page_index--;
			if current_page_index < 0 
				current_page_index = array_length(credits) - 1;
			load_credits_page(current_page_index)
		}
	}
})
add_child(scroll_button_up)
add_child(scroll_button_down)

max_stack = 0;
grubes = []
dense_check_timer_max = 2;
dense_check_timer = dense_check_timer_max;

highest_stack = global.highest_grube_stack;
timer_hold_highest_stack_max = 300;
timer_hold_highest_stack = 0;
potential_new_highest_stack = 0;

scroll_accel = 0;
credits_surface_width = 165;

function ev_credits_entry(txt) constructor {
	self.txt = txt;
	self.step = function () { };
	self.draw = function() { };
	self.reset = function () { };
	self.time_until_active = -1;
	self.skip_active_timing = false;
	self.activate_sound = noone;
}

function ev_credits_header(txt) : ev_credits_entry(txt) constructor {
	self.step = method(self, function() {
		line_width_progress = lerp(line_width_progress, 1.0, 0.15)	
	});
	self.draw = method(self, function (draw_x, draw_y) {
		draw_y += 14
		ev_draw_rectangle(draw_x, draw_y, draw_x + credits_surface_width * 0.6 * line_width_progress, draw_y + 1, false);
		draw_y -= 14;
		draw_text_shadow(draw_x, draw_y, txt)
		draw_y += 16;
		return draw_y;
	})
	self.reset = method(self, function () {
		line_width_progress = 0;
	})
	self.line_width_progress = 0;
	
	self.credits_surface_width = agi("obj_ev_credits").credits_surface_width;
	self.activate_sound = agi("snd_ev_place")
}

function ev_credits_text(txt) : ev_credits_entry(txt) constructor {
	self.draw = method(self, function (draw_x, draw_y) {
		draw_text_shadow(draw_x, draw_y, txt)
		draw_y += 14
		return draw_y;
	})
	self.activate_sound = agi("snd_ev_drag")
}
function ev_credits_spacing(spacing = 8) : ev_credits_entry("") constructor {
	self.draw = method(self, function (draw_x, draw_y) {
		return draw_y + spacing;
	})
	self.spacing = spacing;
	self.skip_active_timing = true;
}

credits = [
	[
		new ev_credits_header("Contributors"),
		new ev_credits_text("skirlez"),
		new ev_credits_text("KyuuMetis"),
		new ev_credits_text("Pyredrid"),
		new ev_credits_text("Meepster99"),
		new ev_credits_text("Flan"),
		new ev_credits_text("cyrelouyea"),
		new ev_credits_text("Fayti1703"),
	],
	[
		new ev_credits_header("Contributors"),
		new ev_credits_text("gullwingdoors"),
		new ev_credits_text("juliascythe"),
		new ev_credits_text("enn"),
		new ev_credits_spacing(),
		new ev_credits_header("Server Development"),
		new ev_credits_text("hexfae"),
	],
	[
		new ev_credits_header("Music"),
		new ev_credits_text("astra_jam (Sun)"),
		new ev_credits_text("by crappyblue"),
		new ev_credits_text("Monsday (Mon)"),
		new ev_credits_text("by skirlez"),
		new ev_credits_text("Tail's Lullaby (Tue)"),
		new ev_credits_text("by 8bitavo"),
		new ev_credits_text("Blossom (Wed)"),
		new ev_credits_text("by gooeyPhantasm"),
	],
	[
		new ev_credits_header("Music"),
		new ev_credits_text("EX Smooth (Thu)"),
		new ev_credits_text("by B. Spaghettini"),
		new ev_credits_text("Endless Void (Fri)"),
		new ev_credits_text("by gooeyPhantasm"),
		new ev_credits_text("Stealie Feelies (Sat)"),
		new ev_credits_text("And the rest of the OST"),
		new ev_credits_text("by eebrozgi"),
	],
	[
		new ev_credits_header("Music"),
		new ev_credits_text("Judgment Jingle"),
		new ev_credits_text("by gooeyPhantasm"),
		new ev_credits_text("Determined Descent"),
		new ev_credits_text("by Emidemi")
	],
	[
		new ev_credits_header("SFX"),
		new ev_credits_text("The BFXR Program"),
		new ev_credits_text("fatboy94"),
		new ev_credits_text("SubUnit_FieldRec"),
		new ev_credits_text("Snake16547"),
		new ev_credits_text("Ruben_Uitenweerde"),
		new ev_credits_spacing(),
		new ev_credits_text("Links and licenses"),
		new ev_credits_text("available in"),
		new ev_credits_text("SFX_CREDITS.md")
	],
	[
		new ev_credits_header("Special Thanks"),
		new ev_credits_text("Underminers team"),
		new ev_credits_text("for UndertaleModTool"),
		new ev_credits_text("attic-stuff"),
		new ev_credits_text("for runtile"),
		new ev_credits_spacing(),
		new ev_credits_header("Original Game"),
		new ev_credits_text("Void Stranger"),
		new ev_credits_text("by System Erasure"),
	],
]



function load_credits_page(page_index) {
	for (var i = 0; i < array_length(current_page); i++) {
		current_page[i].reset();
	}
	current_page = credits[page_index];
	var accum_time = 0;
	for (var i = 0; i < array_length(current_page); i++) {
		if current_page[i].skip_active_timing
			continue;
		accum_time += 5;
		current_page[i].time_until_active = accum_time;
		
	}
}
current_page = []
current_page_index = 0;
load_credits_page(current_page_index);


credits_surface = noone;