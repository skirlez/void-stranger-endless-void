if anim_state == window_anim_state.opening 
{
    var t = anim_counter / opening_time;
    var grow = animcurve_channel_evaluate(curve, t);
    x = lerp(source_x, target_x, grow);
    y = lerp(source_y, target_y, grow);
    image_xscale = lerp(source_image_xscale, target_image_xscale, grow);
    image_yscale = lerp(source_image_yscale, target_image_yscale, grow);

    if anim_counter == opening_time {
        x = target_x;
        y = target_y;
        image_xscale = target_image_xscale;
        image_yscale = target_image_yscale;
        anim_state = window_anim_state.displaying;
		event_user(0)
    }

    anim_counter++;
}
else if anim_state == window_anim_state.closing
{
    var t = anim_counter / closing_time;
    var grow = animcurve_channel_evaluate(curve, t)
    x = lerp(target_x, source_x, grow)
    y = lerp(target_y, source_y, grow)
    image_xscale = lerp(target_image_xscale, source_image_xscale, grow)
    image_yscale = lerp(target_image_yscale, source_image_yscale, grow)
    
    if anim_counter == closing_time {
        instance_destroy()
    }

    anim_counter++;
}
else if anim_state == window_anim_state.displaying
{
    event_inherited();
}