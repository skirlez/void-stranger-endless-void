//Data for command functions below
#region global.branefuck_command_tiles

global.branefuck_command_tiles = ds_map_create();
// 0 will be the special case for the pit
#region Tiles
global.branefuck_command_tiles[? 1] = {
	is_solid : false,
	is_voidrod_pickupable : true,
	is_wall_tile : false,
	is_edge_tile : false,
	obj_name : "obj_floor",
	tile_index : 0,
	obj_layer: "Floor",
	wall_type: 0,
	edge_type: 0,
	custom_sprite: "",
}
global.branefuck_command_tiles[? 2] = {
	is_solid : false,
	is_voidrod_pickupable : true,
	is_wall_tile : false,
	is_edge_tile : false,
	obj_name : "obj_glassfloor",
	tile_index : 0,
	obj_layer: "Floor_INS",
	wall_type: 0,
	edge_type: 0,
	custom_sprite: "",
}
global.branefuck_command_tiles[? 3] = {
	is_solid : false,
	is_voidrod_pickupable : true,
	is_wall_tile : false,
	is_edge_tile : false,
	obj_name : "obj_bombfloor",
	tile_index : 0,
	obj_layer: "Floor",
	wall_type: 0,
	edge_type: 0,
	custom_sprite: "",
}
global.branefuck_command_tiles[? 4] = {
	is_solid : false,
	is_voidrod_pickupable : true,
	is_wall_tile : false,
	is_edge_tile : false,
	obj_name : "obj_explofloor",
	tile_index : 0,
	obj_layer: "Floor",
	wall_type: 0,
	edge_type: 0,
	custom_sprite: "",
}
global.branefuck_command_tiles[? 5] = {
	is_solid : false,
	is_voidrod_pickupable : true,
	is_wall_tile : false,
	is_edge_tile : false,
	obj_name : "obj_floorswitch",
	tile_index : 0,
	obj_layer: "Floor",
	wall_type: 0,
	edge_type: 0,
	custom_sprite: "",
}
global.branefuck_command_tiles[? 6] = {
	is_solid : false,
	is_voidrod_pickupable : true,
	is_wall_tile : false,
	is_edge_tile : false,
	obj_name : "obj_copyfloor",
	tile_index : 0,
	obj_layer: "Floor",
	wall_type: 0,
	edge_type: 0,
	custom_sprite: "",
}
global.branefuck_command_tiles[? 7] = {
	is_solid : false,
	is_voidrod_pickupable : true,
	is_wall_tile : false,
	is_edge_tile : false,
	obj_name : "obj_exit",
	tile_index : 0,
	obj_layer: "Floor",
	wall_type: 0,
	edge_type: 0,
	custom_sprite: "",
}
global.branefuck_command_tiles[? 8] = {
	is_solid : false,
	is_voidrod_pickupable : true,
	is_wall_tile : false,
	is_edge_tile : false,
	obj_name : "obj_deathfloor",
	tile_index : 0,
	obj_layer: "Floor",
	wall_type: 0,
	edge_type: 0,
	custom_sprite: "",
}
//TODO:  The black floor tiles are super weird, my brain is dead
global.branefuck_command_tiles[? 9] = {
	is_solid : false,
	is_voidrod_pickupable : false,  //Also does nothing atm
	is_wall_tile : false,
	is_edge_tile : false,
	obj_name : "obj_floor",
	tile_index : 0,
	obj_layer: "Floor",
	wall_type: 0,
	edge_type: 0,
	custom_sprite: "spr_ev_blackfloor",  //Actually does nothing currently
}
//TODO: This should be the HUD tile
global.branefuck_command_tiles[? 10] = {
	is_solid : false,
	is_voidrod_pickupable : true,
	is_wall_tile : false,
	is_edge_tile : false,
	obj_name : "obj_",
	tile_index : 0,
	obj_layer: "Floor",
	wall_type: 0,
	edge_type: 0,
	custom_sprite: "",
}
global.branefuck_command_tiles[? 11] = {
	is_solid : true,
	is_voidrod_pickupable : true,
	is_wall_tile : false,
	is_edge_tile : false,
	obj_name : "obj_chest_small",
	tile_index : 0,
	obj_layer: "Floor",
	wall_type: 0,
	edge_type: 0,
	custom_sprite: "",
}
#endregion

var wall_tile_indices = [3, 4, 5, 6, 8, 9, 10, 11, 13, 14, 16, 17]
#region Walls
// Normal Walls
for (var i = 0; i < array_length(wall_tile_indices); i++) {
  global.branefuck_command_tiles[? 101 + i] = {
	  is_solid : true,
	  is_wall_tile : true,
	  is_edge_tile : false,
	  obj_name : "",
	  tile_index : wall_tile_indices[i],
	  obj_layer: "",
	  wall_type: wall_types.normal,
	  edge_type: 0,
  }
}
// EX Walls
for (var i = 0; i < array_length(wall_tile_indices); i++) {
  global.branefuck_command_tiles[? 113 + i] = {
	  is_solid : true,
	  is_wall_tile : true,
	  is_edge_tile : false,
	  obj_name : "",
	  tile_index : wall_tile_indices[i],
	  obj_layer: "",
	  wall_type: wall_types.ex,
	  edge_type: 0,
  }
}
// DIS Walls
for (var i = 0; i < array_length(wall_tile_indices); i++) {
  global.branefuck_command_tiles[? 125 + i] = {
	  is_solid : true,
	  is_wall_tile : true,
	  is_edge_tile : false,
	  obj_name : "",
	  tile_index : wall_tile_indices[i],
	  obj_layer: "",
	  wall_type: wall_types.dis,
	  edge_type: 0,
  }
}
// Mon Walls
for (var i = 0; i < array_length(wall_tile_indices); i++) {
  global.branefuck_command_tiles[? 137 + i] = {
	  is_solid : true,
	  is_wall_tile : true,
	  is_edge_tile : false,
	  obj_name : "",
	  tile_index : wall_tile_indices[i],
	  obj_layer: "",
	  wall_type: wall_types.mon,
	  edge_type: 0,
  }
}
#endregion

#region Edges
//Normal Edges
for (var i = 0; i < 46; i++) {
	global.branefuck_command_tiles[? 201 + i] = {
		is_solid : false,
		is_wall_tile : false,
		is_edge_tile : true,
		obj_name : "",
		tile_index : i + 2,
		obj_layer: "",
		wall_type: 0,
		edge_type: edge_types.normal,
	}
}
//DIS Edges
for (var i = 0; i < 46; i++) {
	global.branefuck_command_tiles[? 247 + i] = {
		is_solid : false,
		is_wall_tile : false,
		is_edge_tile : true,
		obj_name : "",
		tile_index : i + 2,
		obj_layer: "",
		wall_type: 0,
		edge_type: edge_types.dis,
	}
}
#endregion

#endregion

//Command functions below
global.branefuck_command_functions = ds_map_create();

global.branefuck_command_functions[? "show"] = function(memory, pointer){
	ev_notify($"Slot {pointer}: {memory[pointer]}");
}
global.branefuck_command_functions[? "log"] = function(memory, pointer){
	log_info($"Slot {pointer}: {memory[pointer]}");
}
global.branefuck_command_functions[? "abs"] = function(memory, pointer){
	command_return(memory, pointer, abs(memory[pointer]))
}

global.branefuck_command_functions[? "mul"] = function(memory, pointer) {
	var params = get_command_parameters(memory, pointer, 2)
	command_return(memory, pointer, params[0] * params[1])
}

global.branefuck_command_functions[? "div"] = function(memory, pointer) {
	var params = get_command_parameters(memory, pointer, 2)
	var dividend = params[0]
	var divisor = params[1];
	if divisor == 0 {
		ev_notify("Division by 0 not allowed")
		return;
	}
	command_return(memory, pointer, dividend div divisor)
}
global.branefuck_command_functions[? "mod"] = function(memory, pointer) {
	var params = get_command_parameters(memory, pointer, 2)
	var dividend = params[0]
	var divisor = params[1];
	if divisor == 0 {
		ev_notify("Division by 0 not allowed")
		return;
	}
	command_return(memory, pointer, int64(dividend % divisor))
}
global.branefuck_command_functions[? "instance_position"] = function(memory, pointer) {
	var params = get_command_parameters(memory, pointer, 3)
	var pos_x = params[0]
	var pos_y = params[1];
	var object = params[2];
	var list = ds_list_create();
	var count = instance_position_list(pos_x, pos_y, object, list, false);
	var arr = ds_list_to_array(list);
	ds_list_destroy(list)
	array_insert(arr, 0, count)
	
	command_return(memory, pointer, arr)
}
global.branefuck_command_functions[? "instance_exists"] = function(memory, pointer) {
	var params = get_command_parameters(memory, pointer, 0)
	var object = params[0];
	command_return(memory, pointer, instance_exists(object) ? int64(1) : int64(0))
}

// ds_grid_get(x, y)
// Sets a tile at a given position to one from an custom array at a given index
global.branefuck_command_functions[? "ds_grid_get"] = function(memory, pointer) {
	var params = get_command_parameters(memory, pointer, 3)
	var grid = params[0]
	if !ds_exists(grid, ds_type_grid) {
		ev_notify("ds_grid_get used on non grid")
		return;	
	}
	var cell_x = params[1]
	if cell_x < 0 {
		ev_notify($"{cell_x}, (x > 0)")
		ev_notify($"ds_grid_get x out of bounds")
		return;
	}
	else if cell_x >= ds_grid_width(grid) {
		ev_notify($"{cell_x}, (x < ${ds_grid_width(grid)})")
		ev_notify($"ds_grid_get x out of bounds")
		return;
	}
	var cell_y = params[2]
	if cell_y < 0 {
		ev_notify($"{cell_y}, (y > 0)")
		ev_notify($"ds_grid_get y out of bounds")
		return;
	}
	else if cell_y >= ds_grid_height(grid) {
		ev_notify($"{cell_y}, (y < {ds_grid_height(grid)})")
		ev_notify($"ds_grid_get y out of bounds")
		return;
	}
	command_return(memory, pointer, ds_grid_get(grid, cell_x, cell_y))
}

//move(direction)
global.branefuck_command_functions[? "move"] = function(memory, pointer, executer) {
	if executer.object_index != agi("obj_ev_branefucker") {
		ev_notify("Command unsuitable for branefuck node")
		return;
	}
	var params = get_command_parameters(memory, pointer, 1)
	var p_move_x = 0
	var p_move_y = 0
	switch params[0]{
		case 0: //Right
			p_move_x = 16
			break
		case 1: //Up
			p_move_y = -16
			break
		case 2: //Left
			p_move_x = -16
			break
		case 3: //Down
			p_move_y = 16
			break
	}
	// Invalid direction?  Exit.
	if p_move_x == 0 && p_move_y == 0 {
		return;
	}
	
	with (executer.add_inst) {
		if place_meeting((x + p_move_x), (y + p_move_y), agi("obj_collision"))
		{
			//Collided, don't move
			//Removed the sound that played here cause it was really bad when it spammed....
		}
		else if place_meeting((x + p_move_x), (y + p_move_y), agi("obj_boulder"))
		{
			var b_push_x = p_move_x
			var b_push_y = p_move_y
			with (instance_place((x + p_move_x), (y + p_move_y), agi("obj_boulder")))
			{
				if (shaken == false){
					o_move_x += b_push_x
					o_move_y += b_push_y
					o_state = (10 << 0)
				}
			}
		}
		else if place_meeting((x + p_move_x), (y + p_move_y), agi("obj_demonlords_statue"))
		{
			with (instance_place((x + p_move_x), (y + p_move_y), agi("obj_demonlords_statue")))
				o_state = (10 << 0)
		}
		else if place_meeting((x + p_move_x), (y + p_move_y), agi("obj_npc_tail_void_hori"))
		{
			with (instance_place((x + p_move_x), (y + p_move_y), agi("obj_npc_tail_void_hori")))
				o_state = (10 << 0)
		}
		else if place_meeting((x + p_move_x), (y + p_move_y), agi("obj_npc_tail_void_vert"))
		{
			with (instance_place((x + p_move_x), (y + p_move_y), agi("obj_npc_tail_void_vert")))
				o_state = (10 << 0)
		}
		else if place_meeting((x + p_move_x), (y + p_move_y), agi("obj_npc_talk"))
		{
			var n_push_x = p_move_x
			var n_push_y = p_move_y
			with (instance_place((x + p_move_x), (y + p_move_y), agi("obj_npc_talk")))
			{
				if (shaken == false){
					o_move_x += n_push_x
					o_move_y += n_push_y
					o_state = (10 << 0)
				}
			}
			with (instance_place((x + p_move_x), (y + p_move_y), agi("obj_rest")))
				counter = 0
		}
		else if (place_meeting((x + p_move_x), (y + p_move_y), agi("obj_enemy_parent")) || place_meeting((x + p_move_x), (y + p_move_y), agi("obj_npc_parent")))
		{
			x += p_move_x
			y += p_move_y
		}
		else if place_meeting((x + p_move_x), (y + p_move_y), agi("obj_pit"))
		{
			x += p_move_x
			y += p_move_y
		}
		else if place_meeting((x + p_move_x), (y + p_move_y), agi("obj_player"))
		{
			//tl;dr, mimics pushing boulders into the player just causes a collision
			//gonna use that as the behaviour here I guess....
		}
		else if place_meeting((x + p_move_x), (y + p_move_y), agi("obj_fakewall"))
		{
			//Collide with the fake hologram rockeggs, similar to other boulders/statues
		}
		else
		{
			var _explofloor_stepped = instance_place((x + p_move_x), (y + p_move_y), agi("obj_explofloor"))
			if (_explofloor_stepped != noone)
			{
				with (_explofloor_stepped)
					self.fnc_explofloor__check_if_stepped_on()
			}
			x += p_move_x
			y += p_move_y
		}
		//Update global variables for the statue's location
		global.add_current_x = x div 16
		global.add_current_y = y div 16
	}
	
}

//set_tile(x, y, index)
//Sets a tile at a given position to one from an custom array at a given index
global.branefuck_command_functions[? "set_tile"] = function(memory, pointer){
	var params = get_command_parameters(memory, pointer, 3)
	var cell_x = params[0]
	var cell_y = params[1]
	var tile_index = params[2]
	
	//Out of range of level, exit early
	//TODO: Determine if this should do something like a DIS error or an ev_notify
	if (cell_x < 0 || cell_x > 13 || cell_y < 0 || cell_y > 8){
		return
	}
	
	//tile_index not found
	if !ds_map_exists(global.branefuck_command_tiles, tile_index) {
		return
	}
	
	var tile_x = cell_x * 16 + 8
	var tile_y = cell_y * 16 + 8
	
	//Destroy any floor instances already there
	var _list = ds_list_create();
	var _num = instance_position_list(tile_x, tile_y, all, _list, false);
	if _num > 0 {
		for (var i = 0; i < _num; ++i;) {
			if (_list[| i].layer == layer_get_id("Floor")
			 || _list[| i].layer == layer_get_id("Floor_INS")){
				instance_destroy(_list[| i]);
			}
		}
	}
	ds_list_destroy(_list);
	
	//Destroy any wall tiles already there
	//layers and layers and layers...
	for (var i = 0; i < array_length(global.wall_tilemaps); ++i;) {
		var map_id = global.wall_tilemaps[i]
		var data = tilemap_get(map_id, cell_x, cell_y)
		data = tile_set_empty(data)
		tilemap_set(map_id, data, cell_x, cell_y)
	}
	for (var i = 0; i < array_length(global.edge_tilemaps); ++i;) {
		var map_id = global.edge_tilemaps[i]
		var data = tilemap_get(map_id, cell_x, cell_y)
		data = tile_set_empty(data)
		tilemap_set(map_id, data, cell_x, cell_y)
	}
	
	//Destroy wall collision
	var collision = instance_position(tile_x, tile_y, agi("obj_collision"))
	with (instance_position(tile_x, tile_y, agi("obj_collision")))
		instance_destroy(collision)
	
	//Finally set tile
	if tile_index == 0 {
		// Pits are a special case, since they don't fit cleanly into the whole global.branefuck_command_tiles thing
		instance_create_layer(tile_x, tile_y, "Pit", agi("obj_pit"))
		return
	}
	else if global.branefuck_command_tiles[? tile_index].is_wall_tile {
		var map_id = global.wall_tilemaps[global.branefuck_command_tiles[? tile_index].wall_type]
		var data = tilemap_get(map_id, cell_x, cell_y)
		data = tile_set_index(data, global.branefuck_command_tiles[? tile_index].tile_index)
		tilemap_set(map_id, data, cell_x, cell_y)
	}
	else if global.branefuck_command_tiles[? tile_index].is_edge_tile {
		var map_id = global.edge_tilemaps[global.branefuck_command_tiles[? tile_index].edge_type]
		var data = tilemap_get(map_id, cell_x, cell_y)
		data = tile_set_index(data, global.branefuck_command_tiles[? tile_index].tile_index)
		tilemap_set(map_id, data, cell_x, cell_y)
	}
	else{
		instance_create_layer(tile_x, tile_y, global.branefuck_command_tiles[? tile_index].obj_layer, agi(global.branefuck_command_tiles[? tile_index].obj_name))
	}
	
	//Clear pit tiles
	var pit_tile = instance_position(tile_x, tile_y, agi("obj_pit"))
	with (instance_position(tile_x, tile_y, agi("obj_pit")))
		instance_destroy(pit_tile)
	
	//Set solid collision if applicable
	if global.branefuck_command_tiles[? tile_index].is_solid {
		instance_create_layer(tile_x, tile_y, "Instances", agi("obj_collision"))
	}
}





function get_command_parameters(memory, pointer, param_count){
	var params = array_create(param_count)
	
	var p = pointer
	for(var i = 0; i < param_count; i++){
		params[@ i] = memory[p]
		p -= 1
		if (p < 0) {
			p += array_length(memory)
		}
	}
	
	return params;
}
function command_return(memory, pointer, data) {
	if !is_array(data)
		data = [data];
	
	var p = pointer + 1;
	for (var i = 0; i < array_length(data); i++){
		memory[@ p] = data[i];
		p += 1
		if (p >= array_length(memory)) {
			p -= array_length(memory)
		}
	}
}
