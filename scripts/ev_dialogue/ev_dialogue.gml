
function ev_you_shouldnt_have_this() {
	var text;
	text[0] = "[...!?]"
	text[1] = "[...]"
	text[2] = "[You shouldn't have this]"
	moods = [neutral, neutral, neutral]
	speakers = [id, id, id]
	return text;
}

function ev_scrScript(num) {
	return agi("scrScript")(num)	
}

// you know it's not actually dialogue unless there's two people involved
// but i think it's still called dialogue in video games
function ev_sword_chest_dialogue() {
	var text;
	if (global.stranger == 2)
	{
	    switch global.blade_style
	    {
	        case 3:
	            text[0] = ev_scrScript(189)
	            text[1] = "[Something feels very, very different]"
	            text[2] = "[It's almost as if you're wielding creation itself]"
	            moods = [neutral, neutral, neutral]
	            speakers = [id, id, id]
	            return text
	        case 1:
	            text[0] = "[You reclaimed your sword]"
	            text[1] = "[...]"
	            text[2] = "[Is there an end to this?]"
	            moods = [neutral, neutral, neutral]
	            speakers = [id, id, id]
	            return text
	        case 0:
	            text[0] = ev_scrScript(243)
	            text[1] = ev_scrScript(244)
	            text[2] = ev_scrScript(245)
	            moods = [neutral, neutral, neutral]
	            speakers = [id, id, id]
	            return text
	        default:
	            return ev_you_shouldnt_have_this()
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
	            return text
	        case 1:
	            text[0] = "[You found Cif's sword]"
	            text[1] = "[...]"
	            text[2] = "[Fatty horns with a thin sword, huh?]"
	            moods = [neutral, neutral, neutral]
	            speakers = [id, id, id]
	            return text
	        case 0:
	            text[0] = ev_scrScript(243)
	            text[1] = ev_scrScript(244)
	            text[2] = "[Better not poke myself with it!]"
	            moods = [neutral, neutral, neutral]
	            speakers = [id, id, id]
	            return text
	        default:
	            return ev_you_shouldnt_have_this()
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
	            return text
	        case 3:
	            text[0] = "[You have restored a strange sword]"
	            text[1] = "[Its size suggests it was meant for something much bigger than you]"
	            text[2] = "[Nevertheless, maybe it'll come in handy in the long run]"
	            moods = [neutral, neutral, neutral]
	            speakers = [id, id, id]
	            return text
	        case 2:
	            text[0] = ev_scrScript(189)
	            text[1] = "[Its heavy weight makes it rather inconvenient to use]"
	            text[2] = ev_scrScript(175)
	            moods = [neutral, neutral, neutral]
	            speakers = [id, id, id]
	            return text
	        case 1:
	            text[0] = ev_scrScript(189)
	            text[1] = "[Its specialized balance makes it rather unwieldy to use]"
	            text[2] = ev_scrScript(175)
	            moods = [neutral, neutral, neutral]
	            speakers = [id, id, id]
	            return text
	        default:
	            text[0] = ev_scrScript(189)
	            text[1] = ev_scrScript(190)
	            text[2] = ev_scrScript(175)
	            moods = [neutral, neutral, neutral]
	            speakers = [id, id, id]
	            return text
	    }
	}
}

function ev_wings_chest_dialogue() {
	var text;
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
	            return text
	        case 1:
	            text[0] = "[You reclaimed your wings]"
	            text[1] = "[...]"
	            text[2] = "[Just what kind of place is this?]"
	            moods = [neutral, neutral, neutral]
	            speakers = [id, id, id]
	            return text
	        case 0:
	            text[0] = ev_scrScript(233)
	            text[1] = ev_scrScript(234)
	            text[2] = "[Can't think about it now...]"
	            moods = [neutral, neutral, neutral]
	            speakers = [id, id, id]
	            return text
	        default:
		        return ev_you_shouldnt_have_this()
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
	            return text
	        case 1:
	            text[0] = "[You found Cif's wings]"
	            text[1] = "[Better try not to get caught using them]"
	            text[2] = "[It's more than likely]"
	            moods = [neutral, neutral, neutral]
	            speakers = [id, id, id]
	            return text
	        case 0:
	            text[0] = ev_scrScript(233)
	            text[1] = ev_scrScript(234)
	            text[2] = "[Well, if nobody's watching...]"
	            moods = [neutral, neutral, neutral]
	            speakers = [id, id, id]
	            return text
	        default:
	            return ev_you_shouldnt_have_this()
	    }

	}
	else
	{
	    switch global.wings_style
	    {
	        case 4:
	            text[0] = "[You have restored a pair of strange wings]"
	            text[1] = "[They have a versatile power output]"
	            text[2] = ev_scrScript(194)
	            moods = [neutral, neutral, neutral]
	            speakers = [id, id, id]
	            return text
	        case 3:
	            text[0] = "[You have restored a pair of strange wings]"
	            text[1] = "[They have a focused power output]"
	            text[2] = ev_scrScript(194)
	            moods = [neutral, neutral, neutral]
	            speakers = [id, id, id]
	            return text
	        case 2:
	            text[0] = ev_scrScript(192)
	            text[1] = "[They feel rough and unwieldy]"
	            text[2] = ev_scrScript(194)
	            moods = [neutral, neutral, neutral]
	            speakers = [id, id, id]
	            return text
	        case 1:
	            text[0] = ev_scrScript(192)
	            text[1] = "[They feel like nothing but warmth]"
	            text[2] = ev_scrScript(194)
	            moods = [neutral, neutral, neutral]
	            speakers = [id, id, id]
	            return text
	        default:
	            text[0] = ev_scrScript(192)
	            text[1] = ev_scrScript(193)
	            text[2] = ev_scrScript(194)
	            moods = [neutral, neutral, neutral]
	            speakers = [id, id, id]
	            return text
	    }
	}	
}

function ev_memory_chest_dialogue() {
	var text;
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
	            return text
	        case 1:
	            text[0] = "[You reclaimed your slave unit]"
	            text[1] = "[...]"
	            text[2] = "[Just when did you lose this...?]"
	            moods = [neutral, neutral, neutral]
	            speakers = [id, id, id]
	            return text
	        case 0:
	            text[0] = ev_scrScript(237)
	            text[1] = ev_scrScript(238)
	            text[2] = "[Is this what you wanted...?]"
	            moods = [neutral, neutral, neutral]
	            speakers = [id, id, id]
	            return text
	        default:
	            return ev_you_shouldnt_have_this()
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
	            return text
	        case 1:
	            text[0] = "[You found Cif's core]"
	            text[1] = "[...]"
	            text[2] = "[Time to find Cif!]"
	            moods = [neutral, neutral, neutral]
	            speakers = [id, id, id]
	            return text
	        case 0:
	            text[0] = ev_scrScript(237)
	            text[1] = ev_scrScript(238)
	            text[2] = "[Why did you leave...?]"
	            moods = [neutral, neutral, neutral]
	            speakers = [id, id, id]
	            return text
	        default:
	            return ev_you_shouldnt_have_this()
				
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
	            return text
	        case 2:
	            text[0] = ev_scrScript(196)
	            text[1] = ev_scrScript(197)
	            text[2] = "[... You're overcome by envy]"
	            moods = [neutral, neutral, neutral]
	            speakers = [id, id, id]
	            return text
	        case 1:
	            text[0] = ev_scrScript(196)
	            text[1] = ev_scrScript(197)
	            text[2] = "[... You feel a sense of pride]"
	            moods = [neutral, neutral, neutral]
	            speakers = [id, id, id]
	            return text
	        default:
	            text[0] = ev_scrScript(196)
	            text[1] = ev_scrScript(197)
	            text[2] = ev_scrScript(198)
	            moods = [neutral, neutral, neutral]
	            speakers = [id, id, id]
	            return text
	    }

	}
}