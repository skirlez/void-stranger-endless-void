// TARGET: LINENUMBER_REPLACE
// 109
} else if (global.stranger == 5) {
    spr_m_right = spr_prin_wed_r
    spr_m_up = spr_prin_wed_u
    spr_m_left = spr_prin_wed_l
    spr_m_down = spr_ev_lily_down
    spr_blink = spr_ev_lily_blink
    spr_hurt = spr_ev_lily_hit
    spr_sleep = 53
    spr_wakey = 54
    spr_enter = 45
    spr_item = spr_ev_lily_item_get
    spr_a_right = spr_ev_lily_attack_r
    spr_a_up = spr_ev_lily_attack_u
    spr_a_left = spr_ev_lily_attack_l
    spr_a_down = spr_ev_lily_attack_d
	voice = snd_princess
    wake_speed = 6
}
else if (global.stranger == 6) {
    spr_m_right = spr_ev_ninnie
    spr_m_up = spr_ev_ninnie
    spr_m_left = spr_ev_ninnie
    spr_m_down = spr_ev_ninnie
    spr_blink = spr_ev_ninnie
    spr_hurt = spr_ev_ninnie
    spr_sleep = 53
    spr_wakey = 54
    spr_enter = 45
    spr_item = spr_ev_ninnie
    spr_a_right = spr_ev_ninnie
    spr_a_up = spr_ev_ninnie
    spr_a_left = spr_ev_ninnie
    spr_a_down = spr_ev_ninnie
    wake_speed = 6
}
else if (global.stranger == 7) {
    spr_m_right = spr_ev_bee_right
    spr_m_up = spr_ev_bee_up
    spr_m_left = spr_ev_bee_left
    spr_m_down = spr_ev_bee_down
    spr_blink = spr_baal_flicker
    spr_hurt = spr_baal_shaken
    spr_sleep = 53
    spr_wakey = 54
    spr_enter = 45
    spr_item = spr_ev_bee_item_get
    spr_a_right = spr_ev_bee_attack_r
    spr_a_up = spr_ev_bee_attack_u
    spr_a_left = spr_ev_bee_attack_l
    spr_a_down = spr_ev_bee_attack_d
	voice = snd_baal
    wake_speed = 6
}
switch global.wings_style
{
    case 4:
        spr_wings = spr_ev_void_wings_two
        break
    case 3:
        spr_wings = spr_ev_void_wings_one
        break
    case 2:
        spr_wings = spr_ev_void_wings_lev
        break
    case 1:
        // don't worry about it
        spr_wings = spr_void_wings_cif - 1
        spr_wings++
        break
    default:
        spr_wings = spr_void_wings
        break
}
switch global.blade_style
{
    case 4:
        spr_blade = spr_ev_void_sword_two
        break
    case 3:
        spr_blade = spr_ev_void_sword_one
        break
    case 2:
        spr_blade = spr_ev_void_sword_lev
        break
    case 1:
        // don't worry about it
        spr_blade = spr_void_sword_cif - 1
        spr_blade++
        break
    default:
        spr_blade = spr_void_sword
        break
}
swap_stage = 0
swapper_flash_counter = 0

// No steam achievements. These lines don't exist in the itch version, so a string replace target doesn't do any damage if they're not present
// TARGET: STRING
scr_steam_achievement_get()> { /* do nothing*/ }
// TARGET: STRING
scr_steam_achievement_clear()> { /* do nothing*/ }

// TARGET: STRING
spr_wings = 2595> { /* do nothing*/ }
// TARGET: STRING
spr_blade = 1700> { /* do nothing*/ }

// TARGET: TAIL
// Set up exit number variable for packs
ev_exit_numbers = []