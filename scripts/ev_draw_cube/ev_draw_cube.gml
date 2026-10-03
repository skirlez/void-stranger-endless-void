

function ev_draw_cube(sprite, subimg, draw_x, draw_y, size, spin_h, spin_v, optimize_opaque = true) {
	static recycled_sprite_array = array_create(6)
	static recycled_subimg_array = array_create(6)
	for (var i = 0; i < 6; i++) {
		recycled_sprite_array[i] = sprite;
		recycled_subimg_array[i] = subimg;
	}
	ev_draw_cube_multisprite(recycled_sprite_array, recycled_subimg_array, draw_x, draw_y, size, spin_h, spin_v, optimize_opaque);
	
}


// modified version of http://www.davetech.co.uk/gamemakercubeoutline to have textures.

// order of sprites/subimgs, when facing forward: front, back, left, right, top, bottom
function ev_draw_cube_multisprite(sprites, subimgs, draw_x, draw_y, size, spin_h, spin_v, optimize_opaque) {
	spin_h %= 1;
	spin_v %= 1;
	
	spin_h *= 2 * pi;
	spin_v *= 2 * pi;
	
	var nodes = [[-1, -1, -1], [-1, -1, 1], [-1, 1, -1], [-1, 1, 1], [1, -1, -1], [1, -1, 1], [1, 1, -1], [1, 1, 1]];
 
	var sin_x = sin(spin_h);
	var cos_x = cos(spin_h);
 
	var sin_y = sin(spin_v);
	var cos_y = cos(spin_v);
	
	var number_of_nodes = array_length(nodes);
	for (var i = 0; i < number_of_nodes; i++) {
	
		var node = nodes[i];

		var _x = node[0];
		var _y = node[1];
		var _z = node[2];
 
		node[0] = _x * cos_x - _z * sin_x;
		node[2] = _z * cos_x + _x * sin_x;
 
		_z = node[2];
 
		node[1] = _y * cos_y - _z * sin_y;
		node[2] = _z * cos_y + _y * sin_y;
	
		nodes[i] = node;
	};

	var faces = [
		new ev_cube_face(nodes[1], nodes[5], nodes[3], nodes[7], sprites[0], subimgs[0]), // front
		new ev_cube_face(nodes[4], nodes[0], nodes[6], nodes[2], sprites[1], subimgs[1]), // back
	
		new ev_cube_face(nodes[5], nodes[4], nodes[7], nodes[6], sprites[2], subimgs[2]), // left
		new ev_cube_face(nodes[0], nodes[1], nodes[2], nodes[3], sprites[3], subimgs[3]), // right

		new ev_cube_face(nodes[1], nodes[0], nodes[5], nodes[4], sprites[4], subimgs[4]), // top
		new ev_cube_face(nodes[2], nodes[3], nodes[6], nodes[7], sprites[5], subimgs[5]), // bottom
	];
	
	array_sort(faces, function (face1, face2) {
		return (ev_get_z_sum(face1) < ev_get_z_sum(face2) ? 1 : -1);
	})
	for (var i = optimize_opaque * 3; i < array_length(faces); i++) {
		ev_draw_face(draw_x, draw_y, size, faces[i]);
		delete faces[i];
	}
}


function ev_draw_face(draw_x, draw_y, size, face) {
	draw_sprite_pos(face.sprite, face.subimg, draw_x + (face.p2[0] * size), draw_y + (face.p2[1] * size), draw_x + (face.p1[0] * size), draw_y + (face.p1[1] * size),
			draw_x + (face.p3[0] * size), draw_y + (face.p3[1] * size), draw_x + (face.p4[0] * size), draw_y + (face.p4[1] * size), draw_get_alpha())
}

function ev_cube_face(p1, p2, p3, p4, sprite, subimg) constructor {
	self.p1 = p1;
	self.p2 = p2;
	self.p3 = p3;
	self.p4 = p4;
	self.sprite = sprite;
	self.subimg = subimg;
}

function ev_get_z_sum(face) {
	return (face.p1[2] + face.p2[2] + face.p3[2] + face.p4[2])
}

