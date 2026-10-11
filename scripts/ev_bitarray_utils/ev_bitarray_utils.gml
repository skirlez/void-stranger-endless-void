
/**
 * Write an array of booleans to a buffer
 * 
 * The array is split into chunks of 8 elements, and each chunk
 * is turned into an 8-bits integer and written to the buffer.
 */
function buffer_write_bitarray(buffer, array) {
	var size = array_length(array);

	var byte = 0;
	for (var i = 0; i < size; i += 1) {
		if array[i] { byte |= (1 << (i & 7)); }

		if ((i & 7) == 7 || i == size - 1) {
			buffer_write(buffer, buffer_u8, byte);
			byte = 0
		}
	}
}

/**
 * Reads an array of booleans from a buffer.
 * 
 * Documentation for `buffer_write_bitarray`' explain how a bitarray is encoded.
 */
function buffer_read_bitarray(buffer, size) {
	var array = array_create(size, 0);

	var byte = 0;
	for (var i = 0; i < size; i++) {
		if ((i & 7) == 0) { byte = buffer_read(buffer, buffer_u8); }
		array[i] = ((byte >> (i & 7)) & 1) == 1;
	}

	return array;
}