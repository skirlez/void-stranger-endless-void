update()
var ind = global.tile_mode ? tile_ind : object_ind
var tile = global.editor.current_list[ind]
selected = (global.selected_thing == 2 && tile == global.held_tile_state.tile)

event_inherited()

if keyboard_check_pressed(ord(string(num + 1))) && !selected && global.mouse_layer == 0
	event_user(0)	
