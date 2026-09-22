// Functions used by the wall autotiling system 

// just to make it easier to know which wall/corner we're talking about
// D = DARK, L = LIT
#macro W_DOWN_D_RIGHT_D 	3 		// ◤
#macro W_LEFT_D_DOWN_L 		5		// ◥
#macro W_HORIZONTAL_D 		4		// ▬
#macro W_VERTICAL_D			6		// ▮
#macro W_DOWN_L_RIGHT_L		13		// ◤
#macro W_LEFT_L_DOWN_D		14		// ◥
#macro W_UP_D_RIGHT_L		9		// ◣
#macro W_LEFT_L_UP_L		11		// ◢ 	
#macro W_HORIZONTAL_L		10		// ▬
#macro W_VERTICAL_L			8		// ▮
#macro W_UP_L_RIGHT_D		16		// ◣
#macro W_LEFT_D_UP_D		17		// ◢ 

enum WallDirection {
    UP,
    DOWN,
    LEFT, 
    RIGHT
}


/**
 * Returns the direction from two points as a WallDirection
 *
 * noone is returned if the direction is not exactly one of (0, 1), (0, -1), (1, 0) (-1, 0)
 * (that way we can stop the autotiling process is there is an unexpected jump)
 */
function get_wall_direction(current_row, current_col, previous_row, previous_col)
{
	var dx = current_col - previous_col;
	var dy = current_row - previous_row;
	
	if dx == 0 {
		if dy == 1 {
			return WallDirection.DOWN
		} else if dy == -1 {
			return WallDirection.UP
		}
	} else if dy == 0 {
		if dx == 1 {
			return WallDirection.RIGHT
		} else if dx == -1 {
			return WallDirection.LEFT
		}
	}

	return noone
}

/**
 * Returns the updated wall index for the previous wall tile when placing a new wall tile
 * 
 * The previous wall direction is necessary because if, for example, you place a horizontal wall
 * and place the next one down, then two corners can join depending on if you were placing 
 * the horizontal wall from the left or the right 
 * 
 * If no previous direction has been recorded (e.g. the previous wall was the first one placed), 
 * then we can't decide which corner to use and default to an horizontal or vertical 
 * wall depending on the direction
 *
 * If the wall is vertical and the direction is left/right, it will be changed to a horizontal one.
 * The same thing is done if the wall is horizontal and the direction is up/down.
 * (That part is here so that you don't have to switch between horizontal/vertical walls manually)
 */
function get_previous_wall_tile_ind(previous_tile_state, wall_direction, previous_wall_direction)
{
	switch (previous_tile_state.properties.ind) {
		case W_HORIZONTAL_D:
			if wall_direction == WallDirection.UP {
				if previous_wall_direction == WallDirection.LEFT {
					return W_UP_L_RIGHT_D
				} else if previous_wall_direction == WallDirection.RIGHT {
					return W_LEFT_D_UP_D
				} else {
					return W_VERTICAL_D
				}
			} else if wall_direction == WallDirection.DOWN {
				if previous_wall_direction == WallDirection.LEFT {
					return W_DOWN_D_RIGHT_D
				} else if previous_wall_direction == WallDirection.RIGHT {
					return W_LEFT_D_DOWN_L
				} else {
					return W_VERTICAL_D
				}
			}
			break;
		case W_HORIZONTAL_L:
			if wall_direction == WallDirection.UP {
				if previous_wall_direction == WallDirection.LEFT {
					return W_UP_D_RIGHT_L
				} else if previous_wall_direction == WallDirection.RIGHT {
					return W_LEFT_L_UP_L
				} else {
					return W_VERTICAL_L
				}
			} else if wall_direction == WallDirection.DOWN {
				if previous_wall_direction == WallDirection.LEFT {
					return W_DOWN_L_RIGHT_L 
				} else if previous_wall_direction == WallDirection.RIGHT {
					return W_LEFT_L_DOWN_D
				} else {
					return W_VERTICAL_L
				}
			}
			break;
		case W_VERTICAL_D:
			if wall_direction == WallDirection.LEFT {
				if previous_wall_direction == WallDirection.UP {
					return W_LEFT_L_DOWN_D
				} else if previous_wall_direction == WallDirection.DOWN {
					return W_LEFT_D_UP_D
				} else {
					return W_HORIZONTAL_D
				}
			} else if wall_direction == WallDirection.RIGHT {
				if previous_wall_direction == WallDirection.UP {
					return W_DOWN_D_RIGHT_D
				} else if previous_wall_direction == WallDirection.DOWN {
					return W_UP_D_RIGHT_L
				} else {
					return W_HORIZONTAL_D
				}
			}
			break;
		case W_VERTICAL_L:
			if wall_direction == WallDirection.LEFT {
				if previous_wall_direction == WallDirection.UP {
					return W_LEFT_D_DOWN_L
				} else if previous_wall_direction == WallDirection.DOWN {
					return W_LEFT_L_UP_L
				} else {
					return W_HORIZONTAL_L
				}
			} else if wall_direction == WallDirection.RIGHT {
				if previous_wall_direction == WallDirection.UP {
					return W_DOWN_L_RIGHT_L
				} else if previous_wall_direction == WallDirection.DOWN {
					return W_UP_L_RIGHT_D
				} else {
					return W_HORIZONTAL_L
				}
			}
			break;
	}

	return previous_tile_state.properties.ind
}

/**
 * Choose the wall index for the tile we're currently trying to place
 *
 * The previous wall tile should be updated with `get_previous_wall_tile_ind` 
 * before calling this function and updating the current tile. 
 * 
 * The current wall can only be a vertical or a horizontal wall (dark or lit),
 * because you can't guess the future directions.
 * 
 * The main rule is:
 * - if the direction is up/down, the wall is vertical
 * - if the direction is left/right, the wall is horizontal
 * The shading of the wall is then selected to match the previous wall/corner 
 */
function get_current_wall_tile_ind(current_tile_state, previous_tile_state, wall_direction)
{
	switch (wall_direction) 
	{
		case WallDirection.UP:
			switch (previous_tile_state.properties.ind)
			{
				case W_VERTICAL_D: 
				case W_HORIZONTAL_D:
					return W_VERTICAL_D
				case W_VERTICAL_L:
				case W_HORIZONTAL_L:
					return W_VERTICAL_L
				case W_UP_D_RIGHT_L: return W_VERTICAL_D
				case W_LEFT_L_UP_L: return W_VERTICAL_L
				case W_UP_L_RIGHT_D: return W_VERTICAL_L
				case W_LEFT_D_UP_D: return W_VERTICAL_D
			}
			break;
		case WallDirection.DOWN: 
			switch (previous_tile_state.properties.ind)
			{
				case W_VERTICAL_D: 
				case W_HORIZONTAL_D:
					return W_VERTICAL_D
				case W_VERTICAL_L:
				case W_HORIZONTAL_L: 
					return W_VERTICAL_L
				case W_DOWN_D_RIGHT_D: return W_VERTICAL_D
				case W_LEFT_D_DOWN_L: return W_VERTICAL_L
				case W_DOWN_L_RIGHT_L: return W_VERTICAL_L
				case W_LEFT_L_DOWN_D: return W_VERTICAL_D
			}
			break;
		case WallDirection.RIGHT:
			switch (previous_tile_state.properties.ind)
			{
				case W_HORIZONTAL_D: 
				case W_VERTICAL_D:
					return W_HORIZONTAL_D
				case W_HORIZONTAL_L: 
				case W_VERTICAL_L:
					return W_HORIZONTAL_L
				case W_DOWN_D_RIGHT_D: return W_HORIZONTAL_D
				case W_DOWN_L_RIGHT_L: return W_HORIZONTAL_L
				case W_UP_D_RIGHT_L: return W_HORIZONTAL_L
				case W_UP_L_RIGHT_D: return W_HORIZONTAL_D
			}
			break;
		case WallDirection.LEFT:
			switch (previous_tile_state.properties.ind)
			{
				case W_HORIZONTAL_D: 
				case W_VERTICAL_D:
					return W_HORIZONTAL_D
				case W_HORIZONTAL_L: 
				case W_VERTICAL_L:
					return W_HORIZONTAL_L
				case W_LEFT_D_DOWN_L: return W_HORIZONTAL_D
				case W_LEFT_L_DOWN_D: return W_HORIZONTAL_L
				case W_LEFT_L_UP_L: return W_HORIZONTAL_L
				case W_LEFT_D_UP_D: return W_HORIZONTAL_D
			}
			break;
	}

	return current_tile_state.properties.ind
}