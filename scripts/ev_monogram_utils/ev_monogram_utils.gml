function _get_monogram_line_hints(tiles, col, width, height, get_index) {
    var line_hints = []
    var count = 0;
    for (var row = 0; row < height; row += 1) {
        if !tiles[get_index(width, height, row, col)] {
            count += 1
        } else if count > 0 {
            array_push(line_hints, count)
            count = 0
        }
    }

    if count > 0 {
        array_push(line_hints, count)
    } else if array_length(line_hints) == 0 {
        array_push(line_hints, 0)
    }

    return line_hints
}

function _get_monogram_lines_hints(tiles, width, height, get_index) {
    var hints = [];

	for (var col = 0; col < width; col += 1) {
		array_push(hints, _get_monogram_line_hints(tiles, col, width, height, get_index));
	}

	return hints;
}

/** 
 * Returns a list of hints (array of number from top to bottom) for the columns of the monogram
 */
function get_monogram_columns_hints(tiles, width, height) {
    return _get_monogram_lines_hints(tiles, width, height, function (width, height, row, col) { return width * row + col })
}

/** 
 * Returns a list of hints (array of number from left to right) for the rows of the monogram
 */
function get_monogram_rows_hints(tiles, width, height) {
    return _get_monogram_lines_hints(tiles, height, width, function (width, height, row, col) { return height * col + row })
}

/**
 * Encode the monogram properties to a base 64 string
 * 
 * Monogram's properties are buffered the following way before encoding it:
 * - type (u8)
 * - width (u8)
 * - height (u8)
 * - target_col (u8)
 * - target_row (u8)
 * - tiles (bitarray of u8): read the documentation of `buffer_write_bitarray` to learn more
 */
function encode_monogram(properties) {
	var buffer_size = 
		6 + // type, width, height, target_col, target_width, bitarray length
		((properties.width * properties.height) div 8) + // complete chunks
		((properties.width * properties.height) mod 8 > 0 ? 1 : 0); // incomplete chunk
		
	var buffer = buffer_create(buffer_size, buffer_fixed, 1);
	buffer_write(buffer, buffer_u8, properties.type);
	buffer_write(buffer, buffer_u8, properties.width);
	buffer_write(buffer, buffer_u8, properties.height);
	buffer_write(buffer, buffer_u8, properties.target_col);
	buffer_write(buffer, buffer_u8, properties.target_row);
	buffer_write_bitarray(buffer, properties.tiles)

	var monogram_str = buffer_base64_encode(buffer, 0, buffer_get_size(buffer));
	buffer_delete(buffer);
	return monogram_str
}

/**
 * Decode the monogram properties from a base 64 string
 * 
 * Read the documentation of `encode_monogram` to learn how it's encoded
 */
function decode_monogram(monogram_str) {
	var buffer = buffer_base64_decode(monogram_str);
	var type = buffer_read(buffer, buffer_u8);
	var width = buffer_read(buffer, buffer_u8);
	var height = buffer_read(buffer, buffer_u8);
	var target_col = buffer_read(buffer, buffer_u8);
	var target_row = buffer_read(buffer, buffer_u8);
	var tiles = buffer_read_bitarray(buffer);

	buffer_delete(buffer);

	return {
		type: type,
		width: width,
		height: height,
		tiles: tiles,
		target_col: target_col,
		target_row: target_row,
	}
}