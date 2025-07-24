// TARGET: LINENUMBER
// 22
switch set_e_direction
{
    case 0:
        sprite_index = spr_ev_orb_thing_left
        break
    case 1:
        sprite_index = spr_cv
        break
    case 2:
        sprite_index = spr_ev_orb_thing_right
        break
    case 3:
        sprite_index = spr_ev_orb_thing_up
        break
}

// TARGET: LINENUMBER_REPLACE
// 4
// Die
// TARGET: LINENUMBER_REPLACE
// 3
if instance_exists(obj_player) {player_x = obj_player.x player_y = obj_player.y}