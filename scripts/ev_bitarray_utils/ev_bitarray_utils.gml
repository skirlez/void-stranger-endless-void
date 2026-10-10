
/**
 * Add a array of boolean to a buffer
 * 
 * First, the array's length is written to the buffer as u8.
 * Then, the array is split into chunks of 8 bits, and each chunk
 * is turned into an 8-bits integer (u8) and written to the buffer.
 */
function buffer_write_bitarray(buffer, bitarray) {
	buffer_write(buffer, buffer_u8, array_length(bitarray))

	var byte = 0;
	for (var i = 0; i < array_length(bitarray); i += 1) {
		if bitarray[i] { byte |= (1 << (i & 7)); }

		if ((i & 7) == 7 || i == array_length(bitarray) - 1) {
			buffer_write(buffer, buffer_u8, byte);
			byte = 0
		}
	}
}

/**
 * Returns an array of boolean from a buffer.
 * 
 * Read `buffer_write_bitarray` to learn how a bitarray is encoded.
 */
function buffer_read_bitarray(buffer) {
	var bitarray_length = buffer_read(buffer, buffer_u8);
	var bitarray = array_create(bitarray_length, 0);

	var byte = 0;
	for (var i = 0; i < bitarray_length; i++) {
		show_debug_message(i)
		if ((i & 7) == 0) { byte = buffer_read(buffer, buffer_u8); }
		bitarray[i] = ((byte >> (i & 7)) & 1) == 1;
	}

	return bitarray;
}