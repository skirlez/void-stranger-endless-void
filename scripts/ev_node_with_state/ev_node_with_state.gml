function node_with_state(node, pos_x, pos_y, properties = node.properties_generator()) constructor {
	self.node = node;
	self.pos_x = pos_x;
	self.pos_y = pos_y;
	self.exits = [];
	self.connected_to_me = [];
	self.properties = properties;
	
	function write(node_index_map) {
		var position_string = string(floor(pos_x)) + "," + string(floor(pos_y))
		var properties_string = node.write_function(properties);
		if array_length(exits) == 0
			return node.node_id + "#" + position_string + "##" + properties_string;
			
		var exits_string = string(ds_map_find_value(node_index_map, exits[0]))
		for (var i = 1; i < array_length(exits); i++) {
			exits_string += "," + string(ds_map_find_value(node_index_map, exits[i]))
		}
		
		
		return node.node_id + "#" + position_string + "#" + exits_string + "#" + properties_string;
	}
	
	function create_instance(node_id = noone) {
		if node_id == noone {
			global.pack_editor.last_nid++;
			node_id = global.pack_editor.last_nid;	
		}
		return instance_create_layer(pos_x, pos_y, 
			"Nodes",
			node.object_ind, 
			{ 
				properties : properties, 
				node_id : node_id 
			});
	}
	
	self.intermediary_numbered_exits = [];
}