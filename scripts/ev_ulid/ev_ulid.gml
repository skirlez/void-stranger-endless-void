// https://github.com/ulid/spec

// I have no idea how good this implementation is. But it seems to generate similar output to
// ULID generating sites if given the same timestamp, so it's probably accurate.
function generate_ulid() {
	var ulid = ""; // could be a buffer
	static characterset =
		["0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
		"A", "B", "C", "D", "E", "F", "G", "H", "J", "K", "M", 
		"N", "P", "Q", "R", "S", "T", "V", "W", "X", "Y", "Z"]
	
	// probably could do without this buffer, which would simplify the code a little
	var buffer = buffer_create(16, buffer_fixed, 1)
	
	var epoch = global.unix_time + int64(current_time)
	var epoch_32 = (epoch >> 16) & 0xFFFFFFFF;
	var epoch_16 = epoch & 0xFFFF;
	
	// compensate for buffers being LE
	var epoch_32_swapped =
		((epoch_32 & 0xFF) << 24) |
		((epoch_32 & 0xFF00) << 8) |
		((epoch_32 & 0xFF0000) >> 8) |
		((epoch_32 & 0xFF000000) >> 24)
	var epoch_16_swapped = 
		((epoch_16 & 0xFF) << 8) | (epoch_16 >> 8)
	
	buffer_write(buffer, buffer_u32, epoch_32_swapped)
	buffer_write(buffer, buffer_u16, epoch_16_swapped)

	// don't care about buffers being LE here because it's random anyways
	var rand_16 = int64(irandom(65536 - 1))
	var rand_32_1 = int64(irandom(4294967296 - 1))
	var rand_32_2 = int64(irandom(4294967296 - 1))
	
	buffer_write(buffer, buffer_u16, rand_16)
	buffer_write(buffer, buffer_u32, rand_32_1)
	buffer_write(buffer, buffer_u32, rand_32_2)
	
	buffer_seek(buffer, buffer_seek_start, 0);
	
	// add 2 here to make it 130 bits for 26 characters (they will be read as 0)
	var bits_unread = 10;
	var num = buffer_read(buffer, buffer_u8)
	for (var i = 0; i < 26; i++) {
		var index;
		if bits_unread < 5 {
			static masks = [0, 1, 3, 7, 15, 31]
			var previous = num;
			num = buffer_read(buffer, buffer_u8)
			index = (((previous) & masks[bits_unread]) << (5 - bits_unread)) | ((num >> (8 - (5 - bits_unread))) & masks[5 - bits_unread]);
		}
		else {
			index = (num >> (bits_unread - 5)) & 31;
		}
		ulid += characterset[index];
		bits_unread -= 5;
		if bits_unread < 0
			bits_unread += 8
	}
	buffer_delete(buffer)
	return ulid;
	
	
}