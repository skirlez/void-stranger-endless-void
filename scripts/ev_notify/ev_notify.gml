function ev_notify(txt) {
	static object = agi("obj_ev_notification")
	move_all_notifications_up()
	with (object) {
		y += 40
		if y - 2 > room_height {
			instance_destroy(id)	
		}
	}
	//instance_destroy(obj)
	var i = instance_create_layer(5, -30, "Notifications", object)
	i.txt = txt
	i.vspeed = 6;

	log_info($"[Notification] {txt}")
}
function move_all_notifications_up() {
	static object = agi("obj_ev_notification")
	with (object) {
		while (vspeed > 0) {
			y += vspeed
			vspeed -= 0.3
			if vspeed < 0
				vspeed = 0	
		}
	}	
}