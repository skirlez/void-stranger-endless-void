if (array_length(elements) == 0) {
	instance_destroy(id)
	ev_notify("Selector created without elements!")
}

enum selector_states {
	displaying,
	selecting,
	animating
}

state = selector_states.displaying;
animation_time = 0;

animation_length = 45;
animation_elements_progress = 0;

function get_selected_element() {
	return elements[selected_element];	
}
function get_selected_index() {
	return selected_element;	
}

function start_return_sequence(index) {
	var instance = element_objects[index]
	array_delete(element_objects, index, 1)
	array_push(element_objects, instance)
	selected_element = index;
	global.mouse_layer--;
	state = selector_states.animating;
}

bounce_text = ""
bounces = 0;
function return_bounce(instance) {
	var last = (bounces == array_length(element_objects) - 1);
	var pitch = last ? 1.6 : 1.2
	var gain = last ? 1 : 0.8
	audio_play_sound(agi("snd_ev_textbox_click"), 10, false, gain, 0, pitch)
	vsp = last ? 6 : 3
	y_bounce = 0;
	bounce_angle = instance.angle + 180;
	bounce_text = instance.txt
	bounces++;
}

vsp = 0
y_bounce = 0;
bounce_angle = 0;

element_objects = [];