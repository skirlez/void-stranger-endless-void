if state == 0 {
	alpha += 1/180
	if alpha >= 1 {
		
		var pack = new pack_struct();
		ev_stop_music()
		var root_node_state = new node_with_state(global.pack_editor.root_node, 0, 0)
		var str = "3|Pw==|||U2tpcmxleg==|2693408940|||0|flX19dfflX3glflX36st01flX2st05flX12st05flX14st05flX4crflX15|emeg1VGhpbmtpbmcgYWJvdXQgbGVhdmluZz8gQ2xpY2sgbWUh!emX23plemX15eg4V2VsY29tZSwgc3RyYW5nZXIuIFRoaXMgaXMgdGhlIGxvc3QgYW5kIGZvdW5kIGFyZWEu!VGhlIFZGUyBhbGxvY2F0ZXMgdGhpcyBzcGFjZSBmb3IgYW55IHRpbGVzIG9yIG9iamVjdHMgZXJhc2VkIGluIGFuIGVycm9yLi4u!VGhlIHN5c3RlbSBpcyBwcmV0dHkgc29saWQsIGhvd2V2ZXIuIEFzIHlvdSBjYW4gc2VlLCB0aGVyZSdzIGFsbW9zdCBub3RoaW5nIGhlcmUgZXhjZXB0IHVzLg==!V2hvIGFyZSB3ZT8gV2VsbC4uLiB5b3UgY2FuIHRoaW5rIG9mIHVzIGFzIG1haW50ZW5hbmNlIHdvcmtlcnMu!ad2!KzEwCj4KLGc6bGV2ZWxfdGltZSwKI21vZCMKPlsuXQo7IFsyMCwgdGltZSwgMF0KOyAgICAgICAgICAgICAKOyB3ZSBuZWVkOgo7IFsyMCwgdGltZSwgaW5kZXgsIHksIHhdCis4IDsgaW5kZXgKPgp2IDsgeSBwb3NpdGlvbiBvZiBkZWF0aCB0aWxlCj4KKzUKI3NldF90aWxlIwo8PAo7IG5vdyBjcmVhdGUgcmVndWxhciBmbG9vcgotOCsKPgoscDo0LAo+CiNzZXRfdGlsZSMKPHZeCj4scDozLCA7IGNvcHkgb2YgMSBmcmFtZSBiZWZvcmUKPCsgOyBpbmNyZWFzZSBmb3IgbmV4dCB0aW1lCnYtOApbCi4KXQpe!!emX31chemX2tsemX5lvemX14eg4SSB3YXMganVzdCBhZG1pcmluZyBteSBmYXZvcml0ZSBwYWNrLCB3aGVuIHN1ZGRlbmx5IHRoZSBzdHJhbmdlc3QgdGhpbmcgaGFwcGVuZWQh!VGhlIHBhY2sgYmVnYW4gYXMgbm9ybWFsLCBidXQgdGhlIG11c2ljIHdhcyB3cm9uZyEgKGFsdGhvdWdoIHF1aXRlIGNhdGNoeSkuIEkgYWxzbyBoYWQgZXZlcnkgc2luZ2xlIGJ1cmRlbiE=!Q29tZSB0byB0aGluayBvZiBpdCwgSSB3YXMgc3RhbmRpbmcgcm91Z2hseSBoZXJlIHdoZW4gaXQgaGFwcGVuZWQuLi4=!RG9uJ3QgYXNrLCBiZWNhdXNlIEkgZG9uJ3Qga25vdy4uLg==!emX27|0|-1"
		var level = import_level(str)
		
		var level_node_state = new node_with_state(global.pack_editor.level_node, 0, 0, {
			level : level,
		});
		array_push(root_node_state.exits, level_node_state)
		array_push(pack.starting_node_states, root_node_state)

		global.pack = pack;
		global.mouse_layer--;
		room_goto(global.pack_level_room)
		
		state = 1	
	}
}
else if state == 1 {
	alpha -= 1/240
	if alpha < 0.52 {
		alpha = 0.52;
		state = 2;
		
	}
}
else if state == 2 {
	/*
	if keyboard_check(ord("A")) {
		alpha += 0.01;
		log_info(alpha)
	}
	else if keyboard_check(ord("D")) {
		alpha -= 0.01
		log_info(alpha);
	}
	*/
}