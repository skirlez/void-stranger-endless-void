event_inherited();

enum DownloadState {
	DOWNLOADING,
	SUCCESS,
	FAILURE,
	ERROR
}

download_pack = http_get(global.packs_server + "/detail/" + nodeless_pack.save_name)
download_timeout = 300
state = DownloadState.DOWNLOADING

function on_success(pack_string)
{
	download_pack = noone
    state = DownloadState.SUCCESS

	var play = instance_create_layer(112, 72 + 30, "WindowElements", agi("obj_ev_executing_button"), {
		txt : "GO!",
		base_scale_x : 1.0,
		base_scale_y : 0.6,
		layer_num : global.mouse_layer,
		pack_string : pack_string,
		display_instance : display_instance,
		func : function() {
			global.pack_parameters = create_pack_parameters()
			global.editor.play_pack_string_transition(pack_string, display_instance)
			instance_destroy(window)
		}
	});
	add_child(play);
	add_x_button();
}

function on_fail(error_str = "") 
{
	download_pack = noone
	state = DownloadState.FAILURE
	
	var error_textbox = instance_create_layer(112, 80, "WindowElements", agi("obj_ev_textbox"), 
	{
		txt : error_str,
		base_scale_x : 6,
		base_scale_y : 1,
		layer_num : 1,
		allow_deletion : false,
		char_limit : 0,	
	})
	add_child(error_textbox)
	
	var ok = instance_create_layer(112, 72 + 30, "WindowElements", agi("obj_ev_executing_button"), {
		txt : "Oh damn",
		base_scale_x : 2.6,
		base_scale_y : 0.6,
		layer_num : global.mouse_layer,
		func : function() {
			instance_destroy(window)
		}
	});
	add_child(ok);
	add_x_button();
}
