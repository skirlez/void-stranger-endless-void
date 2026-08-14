event_inherited()

var no = instance_create_layer(142, 102, elements_layer, agi("obj_ev_executing_button"), 
{
	txt: "No",
	base_scale_x: 0.8,
	base_scale_y: 0.6,
	layer_num: global.mouse_layer,
	func : function() {
		instance_destroy(window)
	}
})
var yes = instance_create_layer(82, 102, elements_layer, agi("obj_ev_executing_button"), 
{
	txt: "Yes",
	base_scale_x: 0.8,
	base_scale_y: 0.6,
	layer_num: global.mouse_layer,
	func : function () {
		
		with (window) {
			on_confirm()
			instance_destroy(id)
		}
	}
})
add_child(no)
add_child(yes)
