// this method is called more times than necessary
// e.g. when disconnecting nodes in a loop,
// but it's relatively cheap, so it's not a problem. it exists
// so that this work isn't done for every node and for every frame
function update() {
	center_x = owner.center_x
	center_y = owner.center_y
	exit_instances = owner.exit_instances

	box_left = center_x
	box_right = center_x
	box_top = center_y
	box_bottom = center_y
	for (var i = 0; i < array_length(exit_instances); i++) {
		var node = exit_instances[i];
		box_left = min(box_left, node.center_x)
		box_right = max(box_right, node.center_x)
		box_top = min(box_top, node.center_y)
		box_bottom = max(box_bottom, node.center_y)
	}
	x = box_left
	y = box_top
	image_xscale = box_right - box_left
	image_yscale = box_bottom - box_top
}
update()

image_alpha = 0.25