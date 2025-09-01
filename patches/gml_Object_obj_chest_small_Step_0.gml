// TARGET: REPLACE
var text, dst_hb;
if (global.pause == true)
    return;
glow_speed += 0.2
flash_speed += 0.5
if (chest_flash == true)
    flash_speed += 0.5
if (room == rm_e_023)
{
    if place_meeting(x, (y + 16), obj_floor_memory1)
    {
        if (ds_grid_get(obj_inventory.ds_equipment, 0, 0) == 1)
        {
            with (obj_riddle_006)
                check1 = 1
        }
    }
    else if place_meeting(x, (y + 16), obj_floor_memory2)
    {
        with (obj_riddle_006)
            check2 = 1
    }
    else if place_meeting(x, (y + 16), obj_floor_memory3)
    {
        with (obj_riddle_006)
            check3 = 1
    }
    else
    {
        with (obj_riddle_006)
        {
            check1 = 0
            check2 = 0
            check3 = 0
        }
    }
}
if (show_contents == false)
    depth = 300
else
    depth = 0
if (chest_secret == 1 && secret_revealed == false)
{
    if instance_exists(obj_player)
    {
        if (obj_player.didyamuv == true)
        {
            secret_timer = 0
            secret_knock = 0
        }
        if (secret_knock > 6)
            secret_timer = 0
        if (secret_knock == 6)
        {
            secret_timer++
            if (secret_timer == 360)
            {
                with (obj_boulder)
                {
                    if (special_message != 0)
                    {
                        b_talk_count = 1
                        alarm[0] = 2
                    }
                    if (b_form == 8)
                        event_perform(ev_other, ev_user1)
                }
                secret_revealed = true
            }
        }
    }
}
else if (chest_secret == 0 && contents == 1 && secret_revealed == false)
{
    if instance_exists(obj_player)
    {
        if (secret_bknock > 3)
        {
            secret_timer = 0
            secret_bknock = 0
        }
        if (secret_bknock == 3)
        {
            if place_meeting(x, (y - 8), obj_player)
            {
                secret_timer++
                if (obj_player.set_p_direction != 3)
                {
                    secret_bknock = 0
                    secret_timer = 0
                }
            }
            else if place_meeting(x, (y - 8), obj_enemy_cm)
            {
                secret_timer++
                var imimic = instance_place(x, (y - 8), obj_enemy_cm)
                if (imimic != noone)
                {
                    if (imimic.e_direction != 270)
                    {
                        secret_bknock = 0
                        secret_timer = 0
                    }
                }
            }
            else
            {
                secret_bknock = 0
                secret_timer = 0
            }
            if (secret_timer == 180)
            {
                with (obj_boulder)
                {
                    if (special_message != 0)
                    {
                        b_talk_count = 1
                        alarm[0] = 2
                    }
                }
                if (empty == false && contents == 1)
                {
                    contents = 6
                    alarm[2] = 1
                    chest_flash = true
                    if (!audio_is_playing(snd_resurrect))
                        audio_play_sound(snd_resurrect, 1, false)
                }
                secret_revealed = true
            }
        }
    }
}
if (checking == false)
    return;
if (empty == false)
{
    if (contents == 0)
    {
        text[0] = scrScript(171)
        moods = [neutral]
        speakers = [id]
    }
    else if (contents == 1)
    {
        if (global.locust == false)
        {
            if (global.stranger == 2)
            {
                text[0] = scrScript(173)
                text[1] = scrScript(229)
                text[2] = scrScript(231)
                moods = [neutral, neutral, neutral]
                speakers = [id, id, id]
            }
            else if (global.stranger == 7)
            {
                text[0] = scrScript(173)
                text[1] = "[What a delectable find!]"
                text[2] = "[You swear you put this one somewhere else, though]"
                moods = [neutral, neutral, neutral]
                speakers = [id, id, id]
            }
            else
            {
                text[0] = scrScript(173)
                text[1] = scrScript(174)
                text[2] = scrScript(175)
                moods = [neutral, neutral, neutral]
                speakers = [id, id, id]
            }
        }
        else if (locust_overflow == false)
        {
            if (global.stranger == 2)
            {
                text[0] = scrScript(232)
                moods = [neutral]
                speakers = [id]
            }
            else
            {
                text[0] = scrScript(176)
                moods = [neutral]
                speakers = [id]
            }
        }
        else
        {
            text[0] = scrScript(173)
            text[1] = scrScript(227)
            text[2] = scrScript(228)
            text[3] = scrScript(226)
            moods = [neutral, neutral, neutral, neutral]
            speakers = [id, id, id, id]
        }
    }
    else if (contents == 2)
    {
        if (global.blade_get == 0)
        {
            if (global.stranger == 2)
            {
                switch global.blade_style
                {
                    case 3:
                        text[0] = scrScript(189)
                        text[1] = "[Something feels very, very different]"
                        text[2] = "[It's almost as if you're wielding creation itself]"
                        moods = [neutral, neutral, neutral]
                        speakers = [id, id, id]
                        break
                    case 1:
                        text[0] = "[You reclaimed your sword]"
                        text[1] = "[...]"
                        text[2] = "[Is there an end to this?]"
                        moods = [neutral, neutral, neutral]
                        speakers = [id, id, id]
                        break
                    case 0:
                        text[0] = scrScript(243)
                        text[1] = scrScript(244)
                        text[2] = scrScript(245)
                        moods = [neutral, neutral, neutral]
                        speakers = [id, id, id]
                        break
                    default:
                        text[0] = "[...!?]"
                        text[1] = "[...]"
                        text[2] = "[You shouldn't have this]"
                        moods = [neutral, neutral, neutral]
                        speakers = [id, id, id]
                        break
                }

            }
            else if (global.stranger == 7)
            {
                switch global.blade_style
                {
                    case 4:
                        text[0] = "[You have restored a strange drill]"
                        text[1] = "[Something feels very, very different]"
                        text[2] = "[Let's get fired up!]"
                        moods = [neutral, neutral, neutral]
                        speakers = [id, id, id]
                        break
                    case 1:
                        text[0] = "[You found Cif's sword]"
                        text[1] = "[...]"
                        text[2] = "[Fatty horns with a thin sword, huh?]"
                        moods = [neutral, neutral, neutral]
                        speakers = [id, id, id]
                        break
                    case 0:
                        text[0] = scrScript(243)
                        text[1] = scrScript(244)
                        text[2] = "[Better not poke myself with it!]"
                        moods = [neutral, neutral, neutral]
                        speakers = [id, id, id]
                        break
                    default:
                        text[0] = "[...!?]"
                        text[1] = "[...]"
                        text[2] = "[You shouldn't have this]"
                        moods = [neutral, neutral, neutral]
                        speakers = [id, id, id]
                        break
                }

            }
            else
            {
                switch global.blade_style
                {
                    case 4:
                        text[0] = "[You have restored a strange sword]"
                        text[1] = "[Honestly, it's a stretch to call it a sword at all]"
                        text[2] = "[Nevertheless, maybe it'll come in handy in the long run]"
                        moods = [neutral, neutral, neutral]
                        speakers = [id, id, id]
                        break
                    case 3:
                        text[0] = "[You have restored a strange sword]"
                        text[1] = "[Its size suggests it was meant for something much bigger than you]"
                        text[2] = "[Nevertheless, maybe it'll come in handy in the long run]"
                        moods = [neutral, neutral, neutral]
                        speakers = [id, id, id]
                        break
                    case 2:
                        text[0] = scrScript(189)
                        text[1] = "[Its heavy weight makes it rather inconvenient to use]"
                        text[2] = scrScript(175)
                        moods = [neutral, neutral, neutral]
                        speakers = [id, id, id]
                        break
                    case 1:
                        text[0] = scrScript(189)
                        text[1] = "[Its specialized balance makes it rather unwieldy to use]"
                        text[2] = scrScript(175)
                        moods = [neutral, neutral, neutral]
                        speakers = [id, id, id]
                        break
                    default:
                        text[0] = scrScript(189)
                        text[1] = scrScript(190)
                        text[2] = scrScript(175)
                        moods = [neutral, neutral, neutral]
                        speakers = [id, id, id]
                        break
                }

            }
        }
        else
        {
            text[0] = "[...!?]"
            text[1] = "[...]"
            text[2] = "[You shouldn't have this]"
            moods = [neutral, neutral, neutral]
            speakers = [id, id, id]
        }
    }
    else if (contents == 3)
    {
        if (global.wings_get == 0)
        {
            if (global.stranger == 2)
            {
                switch global.wings_style
                {
                    case 3:
                        text[0] = "[You have restored a pair of strange wings]"
                        text[1] = "[...]"
                        text[2] = "[They feel as if they could propel you towards a brighter future]"
                        moods = [neutral, neutral, neutral]
                        speakers = [id, id, id]
                        break
                    case 1:
                        text[0] = "[You reclaimed your wings]"
                        text[1] = "[...]"
                        text[2] = "[Just what kind of place is this?]"
                        moods = [neutral, neutral, neutral]
                        speakers = [id, id, id]
                        break
                    case 0:
                        text[0] = scrScript(233)
                        text[1] = scrScript(234)
                        text[2] = "[Can't think about it now...]"
                        moods = [neutral, neutral, neutral]
                        speakers = [id, id, id]
                        break
                    default:
                        text[0] = "[...!?]"
                        text[1] = "[...]"
                        text[2] = "[You shouldn't have this]"
                        moods = [neutral, neutral, neutral]
                        speakers = [id, id, id]
                        break
                }

            }
            else if (global.stranger == 7)
            {
                switch global.wings_style
                {
                    case 4:
                        text[0] = "[You have restored a pair of strange wings]"
                        text[1] = "[...]"
                        text[2] = "[Can't stop blazing!!]"
                        moods = [neutral, neutral, neutral]
                        speakers = [id, id, id]
                        break
                    case 1:
                        text[0] = "[You found Cif's wings]"
                        text[1] = "[Better try not to get caught using them]"
                        text[2] = "[It's more than likely]"
                        moods = [neutral, neutral, neutral]
                        speakers = [id, id, id]
                        break
                    case 0:
                        text[0] = scrScript(233)
                        text[1] = scrScript(234)
                        text[2] = "[Well, if nobody's watching...]"
                        moods = [neutral, neutral, neutral]
                        speakers = [id, id, id]
                        break
                    default:
                        text[0] = "[...!?]"
                        text[1] = "[...]"
                        text[2] = "[You shouldn't have this]"
                        moods = [neutral, neutral, neutral]
                        speakers = [id, id, id]
                        break
                }

            }
            else
            {
                switch global.wings_style
                {
                    case 4:
                        text[0] = "[You have restored a pair of strange wings]"
                        text[1] = "[They have a versatile power output]"
                        text[2] = scrScript(194)
                        moods = [neutral, neutral, neutral]
                        speakers = [id, id, id]
                        break
                    case 3:
                        text[0] = "[You have restored a pair of strange wings]"
                        text[1] = "[They have a focused power output]"
                        text[2] = scrScript(194)
                        moods = [neutral, neutral, neutral]
                        speakers = [id, id, id]
                        break
                    case 2:
                        text[0] = scrScript(192)
                        text[1] = "[They feel rough and unwieldy]"
                        text[2] = scrScript(194)
                        moods = [neutral, neutral, neutral]
                        speakers = [id, id, id]
                        break
                    case 1:
                        text[0] = scrScript(192)
                        text[1] = "[They feel like nothing but warmth]"
                        text[2] = scrScript(194)
                        moods = [neutral, neutral, neutral]
                        speakers = [id, id, id]
                        break
                    default:
                        text[0] = scrScript(192)
                        text[1] = scrScript(193)
                        text[2] = scrScript(194)
                        moods = [neutral, neutral, neutral]
                        speakers = [id, id, id]
                        break
                }

            }
        }
        else
        {
            text[0] = "[...!?]"
            text[1] = "[...]"
            text[2] = "[You shouldn't have this]"
            moods = [neutral, neutral, neutral]
            speakers = [id, id, id]
        }
    }
    else if (contents == 4)
    {
        if (global.memory_get == 0)
        {
            if (global.stranger == 2)
            {
                switch global.memory_style
                {
                    case 3:
                        text[0] = "[You have restored a strange power]"
                        text[1] = "[...]"
                        text[2] = "[None of this is really here, is it...?]"
                        moods = [neutral, neutral, neutral]
                        speakers = [id, id, id]
                        break
                    case 1:
                        text[0] = "[You reclaimed your slave unit]"
                        text[1] = "[...]"
                        text[2] = "[Just when did you lose this...?]"
                        moods = [neutral, neutral, neutral]
                        speakers = [id, id, id]
                        break
                    case 0:
                        text[0] = scrScript(237)
                        text[1] = scrScript(238)
                        text[2] = "[Is this what you wanted...?]"
                        moods = [neutral, neutral, neutral]
                        speakers = [id, id, id]
                        break
                    default:
                        text[0] = "[...!?]"
                        text[1] = "[...]"
                        text[2] = "[You shouldn't have this]"
                        moods = [neutral, neutral, neutral]
                        speakers = [id, id, id]
                        break
                }

            }
            else if (global.stranger == 7)
            {
                switch global.memory_style
                {
                    case 4:
                        text[0] = "[You have restored a strange power]"
                        text[1] = "[...]"
                        text[2] = "[Something is different, in a good way]"
                        moods = [neutral, neutral, neutral]
                        speakers = [id, id, id]
                        break
                    case 1:
                        text[0] = "[You found Cif's core]"
                        text[1] = "[...]"
                        text[2] = "[Time to find Cif!]"
                        moods = [neutral, neutral, neutral]
                        speakers = [id, id, id]
                        break
                    case 0:
                        text[0] = scrScript(237)
                        text[1] = scrScript(238)
                        text[2] = "[Why did you leave...?]"
                        moods = [neutral, neutral, neutral]
                        speakers = [id, id, id]
                        break
                    default:
                        text[0] = "[...!?]"
                        text[1] = "[...]"
                        text[2] = "[You shouldn't have this]"
                        moods = [neutral, neutral, neutral]
                        speakers = [id, id, id]
                        break
                }

            }
            else
            {
                switch global.memory_style
                {
                    case 4:
                    case 3:
                        text[0] = "[You have restored a strange power]"
                        text[1] = "[Your mind feels *****ish]"
                        text[2] = "[So this is the power of ...]"
                        moods = [neutral, neutral, neutral]
                        speakers = [id, id, id]
                        break
                    case 2:
                        text[0] = scrScript(196)
                        text[1] = scrScript(197)
                        text[2] = "[... You're overcome by envy]"
                        moods = [neutral, neutral, neutral]
                        speakers = [id, id, id]
                        break
                    case 1:
                        text[0] = scrScript(196)
                        text[1] = scrScript(197)
                        text[2] = "[... You feel a sense of pride]"
                        moods = [neutral, neutral, neutral]
                        speakers = [id, id, id]
                        break
                    default:
                        text[0] = scrScript(196)
                        text[1] = scrScript(197)
                        text[2] = scrScript(198)
                        moods = [neutral, neutral, neutral]
                        speakers = [id, id, id]
                        break
                }

            }
        }
        else
        {
            text[0] = "[...!?]"
            text[1] = "[...]"
            text[2] = "[You shouldn't have this]"
            moods = [neutral, neutral, neutral]
            speakers = [id, id, id]
        }
    }
    else if (contents == 6)
    {
        if (locust_overflow == false)
        {
            if (global.stranger == 2)
            {
                text[0] = scrScript(221)
                text[1] = scrScript(247)
                moods = [neutral, neutral]
                speakers = [id, id]
            }
            else if (global.stranger == 7)
            {
                text[0] = scrScript(221)
                text[1] = "[T A S T Y !]"
                moods = [neutral, neutral]
                speakers = [id, id]
            }
            else
            {
                text[0] = scrScript(221)
                text[1] = scrScript(222)
                moods = [neutral, neutral]
                speakers = [id, id]
            }
        }
        else
        {
            text[0] = scrScript(221)
            text[1] = scrScript(224)
            text[2] = scrScript(225)
            text[3] = scrScript(226)
            moods = [neutral, neutral, neutral, neutral]
            speakers = [id, id, id, id]
        }
    }
    else if (contents == 7)
    {
        text[0] = "..."
        text[1] = "... ..."
        moods = [neutral, neutral]
        speakers = [id, id]
    }
    else if (contents == 8)
    {
        text[0] = scrScript(249)
        moods = [neutral]
        speakers = [id]
        counter++
        if (counter == 42)
            audio_play_sound(snd_kbjingle, 1, false)
    }
    else if (contents == 9)
    {
        text[0] = scrScript(262)
        text[1] = scrScript(263)
        moods = [neutral, neutral]
        speakers = [id, id]
    }
    else if (contents == 10)
    {
        if (global.stranger == 2)
        {
            text[0] = scrScript(243)
            text[1] = scrScript(244)
            text[2] = scrScript(245)
            moods = [neutral, neutral, neutral]
            speakers = [id, id, id]
        }
        else
        {
            text[0] = scrScript(189)
            text[1] = scrScript(190)
            text[2] = scrScript(175)
            moods = [neutral, neutral, neutral]
            speakers = [id, id, id]
        }
    }
	else if (contents == 495)
	{
        text[0] = "[...!?]"
        text[1] = "[...]"
        text[2] = "[You shouldn't have this]"
        moods = [neutral, neutral, neutral]
        speakers = [id, id, id]	
	}
}
if (empty == true)
{
    if (special == false)
    {
        if (contents == 2)
        {
            if (global.stranger == 2)
            {
                text[0] = scrScript(170)
                text[1] = scrScript(178)
                text[2] = scrScript(179)
                text[3] = scrScript(180)
                text[4] = scrScript(200)
                text[5] = scrScript(202)
                text[6] = scrScript(203)
                text[7] = scrScript(204)
                text[8] = scrScript(205)
                text[9] = scrScript(206)
                text[10] = scrScript(1255)
                text[11] = scrScript(241)
                moods = [neutral, neutral, neutral, neutral, neutral, neutral, neutral, neutral, neutral, neutral, neutral, neutral]
                speakers = [id, id, id, id, id, id, id, id, id, id, 585, 585]
            }
            else if (global.voider == false)
            {
                text[0] = scrScript(170)
                text[1] = scrScript(178)
                text[2] = scrScript(179)
                text[3] = scrScript(187)
                text[4] = scrScript(180)
                text[5] = scrScript(200)
                text[6] = scrScript(202)
                text[7] = scrScript(203)
                text[8] = scrScript(204)
                text[9] = scrScript(205)
                text[10] = scrScript(206)
                text[11] = scrScript(185)
                moods = [neutral, neutral, neutral, neutral, neutral, neutral, neutral, neutral, neutral, neutral, neutral, neutral]
                speakers = [id, id, id, id, id, id, id, id, id, id, id, id]
            }
            else
            {
                text[0] = scrScript(170)
                moods = [neutral]
                speakers = [id]
            }
        }
        else if (contents == 3)
        {
            if (global.stranger == 2)
            {
                text[0] = scrScript(170)
                text[1] = scrScript(178)
                text[2] = scrScript(179)
                text[3] = scrScript(180)
                text[4] = scrScript(201)
                text[5] = scrScript(208)
                text[6] = scrScript(209)
                text[7] = scrScript(210)
                text[8] = scrScript(211)
                text[9] = scrScript(1255)
                text[10] = scrScript(241)
                moods = [neutral, neutral, neutral, neutral, neutral, neutral, neutral, neutral, neutral, neutral, neutral]
                speakers = [id, id, id, id, id, id, id, id, id, 585, 585]
            }
            else if (global.voider == false)
            {
                text[0] = scrScript(170)
                text[1] = scrScript(178)
                text[2] = scrScript(179)
                text[3] = scrScript(187)
                text[4] = scrScript(180)
                text[5] = scrScript(201)
                text[6] = scrScript(208)
                text[7] = scrScript(209)
                text[8] = scrScript(210)
                text[9] = scrScript(211)
                text[10] = scrScript(185)
                moods = [neutral, neutral, neutral, neutral, neutral, neutral, neutral, neutral, neutral, neutral, neutral]
                speakers = [id, id, id, id, id, id, id, id, id, id, id]
            }
            else
            {
                text[0] = scrScript(170)
                moods = [neutral]
                speakers = [id]
            }
        }
        else if (contents == 4)
        {
            if (global.stranger == 2)
            {
                text[0] = scrScript(170)
                text[1] = scrScript(178)
                text[2] = scrScript(179)
                text[3] = scrScript(180)
                text[4] = scrScript(213)
                text[5] = scrScript(214)
                text[6] = scrScript(215)
                text[7] = scrScript(216)
                text[8] = scrScript(1255)
                text[9] = scrScript(241)
                moods = [neutral, neutral, neutral, neutral, neutral, neutral, neutral, neutral, neutral, neutral]
                speakers = [id, id, id, id, id, id, id, id, 585, 585]
            }
            else if (global.voider == false)
            {
                text[0] = scrScript(170)
                text[1] = scrScript(178)
                text[2] = scrScript(179)
                text[3] = scrScript(187)
                text[4] = scrScript(180)
                text[5] = scrScript(213)
                text[6] = scrScript(214)
                text[7] = scrScript(215)
                text[8] = scrScript(216)
                text[9] = scrScript(185)
                moods = [neutral, neutral, neutral, neutral, neutral, neutral, neutral, neutral, neutral, neutral]
                speakers = [id, id, id, id, id, id, id, id, id, id]
            }
            else
            {
                text[0] = scrScript(170)
                moods = [neutral]
                speakers = [id]
            }
        }
        else if (contents == 8)
        {
            text[0] = scrScript(250)
            text[1] = scrScript(251)
            text[2] = scrScript(252)
            moods = [neutral, neutral, neutral]
            speakers = [id, id, id]
        }
        else if (contents == 10)
        {
            text[0] = scrScript(170)
            moods = [neutral]
            speakers = [id]
        }
        else if (inspection_count < 3)
        {
            text[0] = scrScript(170)
            moods = [neutral]
            speakers = [id]
        }
        else
        {
            text[0] = "?? ??? ?"
            moods = [neutral]
            speakers = [id]
        }
    }
    else if (special == true && global.voider == false)
    {
        if (global.stranger == 2)
        {
            text[0] = scrScript(170)
            text[1] = scrScript(178)
            text[2] = scrScript(179)
            text[3] = scrScript(180)
            text[4] = scrScript(181)
            text[5] = scrScript(182)
            text[6] = scrScript(183)
            text[7] = scrScript(184)
            text[8] = scrScript(1255)
            text[9] = scrScript(241)
            moods = [neutral, neutral, neutral, neutral, neutral, neutral, neutral, neutral, neutral, neutral]
            speakers = [id, id, id, id, id, id, id, id, 585, 585]
        }
        else
        {
            text[0] = scrScript(170)
            text[1] = scrScript(178)
            text[2] = scrScript(179)
            text[3] = scrScript(187)
            text[4] = scrScript(180)
            text[5] = scrScript(181)
            text[6] = scrScript(182)
            text[7] = scrScript(183)
            text[8] = scrScript(184)
            text[9] = scrScript(185)
            moods = [neutral, neutral, neutral, neutral, neutral, neutral, neutral, neutral, neutral, neutral]
            speakers = [id, id, id, id, id, id, id, id, id, id]
        }
    }
    else
    {
        text[0] = scrScript(170)
        moods = [neutral]
        speakers = [id]
    }
}
if (active_textbox == noone)
{
    var tbox = create_textbox(text, speakers, moods)
    active_textbox = tbox
    if (empty == false && contents == 1 && global.locust == true && locust_overflow == false)
        instance_destroy(active_textbox)
    else if (empty == false && contents == 2 && global.blade_get == true)
        instance_destroy(active_textbox)
    else if (empty == false && contents == 3 && global.wings_get == true)
        instance_destroy(active_textbox)
    else if (empty == false && contents == 4 && global.memory_get == true)
        instance_destroy(active_textbox)
    else if (empty == false && contents == 6 && global.luckylocust != 0 && locust_overflow == false)
        instance_destroy(active_textbox)
    else if (empty == false && contents == 495 && global.swapper_get == true)
        instance_destroy(active_textbox)
}
else if (!instance_exists(active_textbox))
{
    if (empty == false)
    {
        with (obj_player_intro)
        {
            sprite_index = spr_down
            state = (0 << 0)
        }
        with (obj_player)
        {
            set_p_direction = 3
            alarm[3] = 12
            sprite_index = spr_m_down
        }
    }
    else
    {
        if (secret_inspection == true)
            inspection_count++
        if (inspection_count <= 3)
        {
            with (obj_player_intro)
            {
                state = (0 << 0)
                sprite_index = spr_down
            }
            if instance_exists(obj_player)
            {
                if (special != false)
                    special = false
                obj_player.alarm[3] = 12
            }
        }
        else
        {
            alarm[3] = 60
            alarm[4] = 132
        }
    }
    if (contents == 1 || contents == 6 || contents == 9)
    {
        global.locust = true
        if (ds_grid_get(obj_inventory.ds_player_info, 1, 1) > 99)
            ds_grid_set(obj_inventory.ds_player_info, 1, 1, 99)
        if (chest_flash == true)
            chest_flash = false
    }
    if (contents == 6)
        global.luckylocust = 1
    active_textbox = -4
    show_contents = false
    empty = true
    checking = false
    switch contents
    {
        case 2:
            global.blade_get = true
            break
        case 3:
            global.wings_get = true
            break
        case 4:
            global.memory_get = true
            break
        case 495:
            global.swapper_get = true
            break			
    }
}

