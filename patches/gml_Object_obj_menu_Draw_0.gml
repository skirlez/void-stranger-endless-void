// TARGET: REPLACE
// bugged in UMT 0.7.0.0, replace is needed
// look for // EV comments to see what changed
if (!global.menu)
    exit;

draw_sprite(spr_black_screen, 0, 0, 0);
draw_set_font(global.text_font);
var gwidth = global.game_width;
var gheight = global.game_height;
var ds_grid = menu_pages[page];
var ds_height = ds_grid_height(ds_grid);
var y_buffer = 16;
var x_buffer = 8;
var start_y = (gheight / 2) - (((ds_height - 1) / 2) * y_buffer);
var start_x = gwidth / 2;

if (page == 0)
{
    if (!ev_got_any_burdens())
        start_y += (y_buffer / 2);
}

if (page == 2)
{
    if (!window_get_fullscreen())
        start_y += ((y_buffer / 2) * 2);
    else
        start_y += ((y_buffer / 2) * 1);
}

var c = 0;
draw_rectangle_color(0, 0, gwidth, gheight, c, c, c, c, false);

if (secret_timer > 0)
{
    var _delayframes = 7;
    var _bar_y = start_y + (menu_option[page] * y_buffer);
    var _bar_length = (secret_timer - _delayframes) * (224 / (60 - _delayframes));
    
    if (_bar_length > 0)
    {
        draw_set_color(c_gray);
        draw_rectangle(0, _bar_y - 8, _bar_length, _bar_y + 7, 0);
    }
}

draw_set_valign(fa_middle);
draw_set_halign(fa_right);
var ltx = start_x - x_buffer;
var _yoffset = 0;
var yy = 0;

repeat (ds_height)
{
    if (page == 0 && yy == 1)
    {
        if (!ev_got_any_burdens())
        {
            _yoffset -= 16;
            yy++;
            continue;
        }
    }
    
    if (page == 2)
    {
        if ((!window_get_fullscreen() && (yy == 2 || yy == 3)) || (window_get_fullscreen() && yy == 1))
        {
            _yoffset -= 16;
            yy++;
            continue;
        }
    }
    
    var lty = start_y + (yy * y_buffer) + _yoffset;
    c = 8421504;
    var xoffset = 0;
    
    if (yy == menu_option[page])
    {
        c = 16777215;
        
        if (page == 0 || page == 1 || page == 7)
            draw_sprite(ds_grid_get(ds_grid, 3, yy), image_speed, 112 + menu_art_x, menu_art_y);
    }
    
    draw_text_color(ltx + xoffset, lty, ds_grid_get(ds_grid, 0, yy), c, c, c, c, 1);
    yy++;
}

draw_set_halign(fa_left);
var rtx = start_x + x_buffer;
_yoffset = 0;
yy = 0;

repeat (ds_height)
{
    if (page == 0 && yy == 1)
    {
        if (!ev_got_any_burdens())
        {
            _yoffset -= 16;
            yy++;
            continue;
        }
    }
    
    if (page == 2)
    {
        if ((!window_get_fullscreen() && (yy == 2 || yy == 3)) || (window_get_fullscreen() && yy == 1))
        {
            _yoffset -= 16;
            yy++;
            continue;
        }
    }
    
    var rty = start_y + (yy * y_buffer) + _yoffset;
    
    switch (ds_grid_get(ds_grid, 1, yy))
    {
        case 3:
            var current_val = ds_grid_get(ds_grid, 3, yy);
            var current_array = ds_grid_get(ds_grid, 4, yy);
            var left_shift = "<<";
            var right_shift = ">>";
            c = 8421504;
            
            if (current_val == 0)
                left_shift = "";
            
            if (current_val == (array_length(ds_grid_get(ds_grid, 4, yy)) - 1))
                right_shift = "";
            
            if (inputting && yy == menu_option[page])
            {
                counter++;
                
                if (counter <= 8)
                    c = 8421504;
                else
                    c = 16777215;
                
                if (counter > 16)
                    counter = 0;
                
                if (menu_pages[page] == ds_menu_language)
                {
                    var ilanguage = "ENGLISH";
                    
                    switch (current_val)
                    {
                        case 0:
                            ilanguage = "SELECT ENGLISH";
                            break;
                        
                        case 1:
                            ilanguage = "VALITSE SUOMI";
                            break;
                        
                        default:
                            ilanguage = "SELECT LANGUAGE";
                            break;
                    }
                    
                    draw_set_halign(fa_center);
                    draw_text_color(112, 48, ilanguage, c, c, c, c, 1);
                    draw_set_halign(fa_left);
                }
            }
            
            var _content = current_array[current_val];
            
            if (array_length(ds_grid_get(ds_grid, 4, yy)) >= 2)
            {
                if (ds_grid_get(ds_grid, 3, yy) == (array_length(ds_grid_get(ds_grid, 4, yy)) - 2))
                {
                    var _nextcontent = array_get(ds_grid_get(ds_grid, 4, yy), ds_grid_get(ds_grid, 3, yy) + 1);
                    
                    if (is_string(_nextcontent))
                    {
                        if (string_copy(_nextcontent, 1, 6) == "Secret")
                        {
                            if (secret_timer < 12)
                                right_shift = "";
                            else if (secret_timer < 16)
                                right_shift = "-";
                            else if (secret_timer < 22)
                                right_shift = ">";
                            else if (secret_timer < 26)
                                right_shift = ">-";
                            else
                                right_shift = ">>";
                        }
                    }
                }
            }
            
            if (is_string(_content))
            {
                if (string_copy(_content, 1, 6) == "Secret")
                    _content = string_delete(_content, 1, 6);
            }
            
            draw_text_color(rtx, rty, left_shift + _content + right_shift, c, c, c, c, 1);
            break;
        
        case 2:
            var len = 64;
            var current_val = ds_grid_get(ds_grid, 3, yy);
            var current_array = ds_grid_get(ds_grid, 4, yy);
            var circle_pos = ((current_val - current_array[0]) / current_array[1]) - current_array[0];
            c = 8421504;
            
            for (var i = 0; i < 10; i += 1)
                draw_sprite(spr_menu_page_icon_b, 0, rtx + (i * 8), rty - 4);
            
            if (inputting && yy == menu_option[page])
                slider_icon_speed += 0.25;
            
            var ispeed = 0;
            var icon_count = floor(circle_pos * 10);
            
            for (var i = 0; i < icon_count; i += 1)
            {
                if (i == (icon_count - 1) && inputting && yy == menu_option[page])
                    ispeed = slider_icon_speed;
                
                draw_sprite(spr_menu_page_icon_a, ispeed, rtx + (i * 8), rty - 4);
            }
            
            if (inputting && yy == menu_option[page])
            {
                counter++;
                
                if (counter <= 8)
                    c = 8421504;
                else
                    c = 16777215;
                
                if (counter > 16)
                    counter = 0;
            }
            
            draw_set_halign(fa_center);
            draw_text_color(rtx + 90, rty, string(floor(circle_pos * 10)), c, c, c, c, 1);
            draw_set_halign(fa_left);
            break;
        
        case 4:
            var current_val = ds_grid_get(ds_grid, 3, yy);
            c = 16777215;
            
            if (inputting && yy == menu_option[page])
            {
                counter++;
                
                if (counter <= 8)
                    c = 8421504;
                else
                    c = 16777215;
                
                if (counter > 16)
                    counter = 0;
            }
            
            var c1, c2;
            
            if (current_val == 0)
            {
                c1 = c;
                c2 = 8421504;
            }
            else
            {
                c1 = 8421504;
                c2 = c;
            }
            
			// EV
            if (ds_grid_get(obj_inventory.ds_equipment, 0, 4) != 0 && yy == 3 && ds_grid == ds_menu_equipment)
            {
                draw_text_color(rtx + 16, rty, scrScript(8), c, c, c, c, 1);
            }
            else
            {
                draw_text_color(rtx, rty, scrScript(8), c1, c1, c1, c1, 1);
                draw_text_color(rtx + 32, rty, scrScript(9), c2, c2, c2, c2, 1);
            }
            
            break;
        
        case 5:
            var current_val = ds_grid_get(ds_grid, 3, yy);
            var string_val;
            
            switch (current_val)
            {
                case 38:
                    string_val = "UP KEY";
                    break;
                
                case 37:
                    string_val = "LEFT KEY";
                    break;
                
                case 39:
                    string_val = "RIGHT KEY";
                    break;
                
                case 40:
                    string_val = "DOWN KEY";
                    break;
                
                case 90:
                    string_val = "Z";
                    break;
                
                case 13:
                    string_val = "ENTER";
                    break;
                
                case 16:
                    string_val = "SHIFT";
                    break;
                
                case 17:
                    string_val = "CTRL";
                    break;
                
                case 162:
                    string_val = "LEFT CTRL";
                    break;
                
                case 163:
                    string_val = "RIGHT CTRL";
                    break;
                
                case 8:
                    string_val = "BSPACE";
                    break;
                
                case 18:
                    string_val = "ALT";
                    break;
                
                case 32:
                    string_val = "SPACE";
                    break;
                
                case 9:
                    string_val = "TAB";
                    break;
                
                case 46:
                    string_val = "DEL";
                    break;
                
                default:
                    string_val = chr(current_val);
                    break;
            }
            
            c = 8421504;
            
            if (inputting && yy == menu_option[page])
            {
                counter++;
                
                if (counter <= 8)
                    c = 8421504;
                else
                    c = 16777215;
                
                if (counter > 16)
                    counter = 0;
            }
            
            draw_text_color(rtx, rty, string_val, c, c, c, c, 1);
            break;
        
        case 8:
            var current_val = ds_grid_get(ds_grid, 3, yy);
            var button_number;
            
            switch (current_val)
            {
                case 32769:
                    button_number = 0;
                    break;
                
                case 32770:
                    button_number = 1;
                    break;
                
                case 32771:
                    button_number = 2;
                    break;
                
                case 32772:
                    button_number = 3;
                    break;
                
                case 32781:
                    button_number = 8;
                    break;
                
                case 32782:
                    button_number = 9;
                    break;
                
                case 32783:
                    button_number = 10;
                    break;
                
                case 32784:
                    button_number = 11;
                    break;
                
                case 32774:
                    button_number = 4;
                    break;
                
                case 32773:
                    button_number = 5;
                    break;
                
                case 32776:
                    button_number = 6;
                    break;
                
                case 32775:
                    button_number = 7;
                    break;
                
                case 32778:
                    button_number = 12;
                    break;
                
                case 32779:
                    button_number = 13;
                    break;
                
                case 32780:
                    button_number = 14;
                    break;
                
                default:
                    button_number = 15;
                    break;
            }
            
            c = 8421504;
            var icon_index = global.current_controller_sprite;
            
            if (inputting && yy == menu_option[page])
            {
                counter++;
                
                if (counter <= 8)
                    icon_index = scr_get_dark_controller_sprite(global.current_controller_sprite);
                else
                    icon_index = global.current_controller_sprite;
                
                if (counter > 16)
                    counter = 0;
            }
            
            draw_sprite(icon_index, button_number, rtx, rty - 8);
            break;
        
        case 6:
            break;
        
        case 7:
            break;
    }
    
    yy++;
}

draw_set_valign(fa_top);

if (draw_puumerkki == true)
{
    for (var i = 0; i < 36; i += 1)
    {
        var idim = 1;
        var ix = idim * i;
        var iy;
        
        if (i > 29)
        {
            iy = idim * 5;
            ix -= (idim * 30);
        }
        else if (i > 23)
        {
            iy = idim * 4;
            ix -= (idim * 24);
        }
        else if (i > 17)
        {
            iy = idim * 3;
            ix -= (idim * 18);
        }
        else if (i > 11)
        {
            iy = idim * 2;
            ix -= (idim * 12);
        }
        else if (i > 5)
        {
            iy = idim * 1;
            ix -= (idim * 6);
        }
        else
        {
            iy = 0;
        }
        
        var ipx = ix;
        var ipy = iy;
        var igrid = ds_grid_get(puumerkki_grid, ipx, ipy);
        
        if (igrid != 0)
            draw_sprite(puumerkki_index, igrid, pm_x + ix, pm_y + iy);
    }
}

if (gor_appears == true)
{
    for (var ig = 0; ig < 3; ig++)
    {
        var ic = choose(12632256, 8421504, 0);
        var ix = irandom_range(-2, 2);
        var iy = irandom_range(-2, 2);
        gpu_set_fog(true, ic, 0, 0);
        draw_sprite(gor_ec_index, 0, gor_x + ix, gor_y + iy);
        gpu_set_fog(false, c_white, 0, 0);
    }
    
    var igx = irandom_range(-1, 1);
    var igy = irandom_range(-1, 1);
    draw_sprite(gor_ec_index, gor_ec_speed, gor_x + igx, gor_y + igy);
    draw_set_halign(fa_center);
    
    if (gor_char_count != 0)
    {
        for (var is = 0; is < gor_char_count; is++)
        {
            var icc = 16777215;
            var ichar = string_char_at(gor_string, is + 1);
            var ichar_x = gor_string_x[is] + irandom_range(-2, 2);
            var ichar_y = gor_string_y[is] + irandom_range(-2, 2);
            draw_text_color(ichar_x, ichar_y, ichar, icc, icc, icc, icc, 1);
        }
    }
    
    draw_set_halign(fa_left);
}

if (menu_pages[page] == 9)
{
    if (draw_controller_info == 1)
    {
        draw_set_halign(fa_center);
        draw_set_font(controller_font);
        
        switch (found_controller)
        {
            case 0:
                var irx1 = ctrl_r_x1;
                var irx2 = ctrl_r_x2;
                var iry1 = ctrl_y + ctrl_r_y1 + 8;
                var iry2 = ctrl_y + ctrl_r_y2 + 8;
                draw_rectangle_color(irx1, iry1 - 16, irx2, iry2 - 16, cr_c, cr_c, cr_c, cr_c, false);
                draw_text_color(ctrl_x, ctrl_y - 16, scrScript(47), ct_c, ct_c, ct_c, ct_c, ct_a);
                draw_rectangle_color(irx1, iry1, irx2, iry2, cr_c, cr_c, cr_c, cr_c, false);
                draw_text_color(ctrl_x + ctrl_scroll_x, ctrl_y, ctrl_string, ct_c2, ct_c2, ct_c2, ct_c2, ct_a);
                draw_text_color(ctrl_x + ctrl_scroll_x + ctrl_scroll_add, ctrl_y, ctrl_string, ct_c2, ct_c2, ct_c2, ct_c2, ct_a);
                break;
            
            case 1:
                var gp_num = gamepad_get_device_count();
                var gp_count = global.controller_count;
                var iyh = gp_count * 8;
                var irx1 = ctrl_r_x1;
                var irx2 = ctrl_r_x2;
                var iry1 = ((ctrl_y + ctrl_r_y1) - iyh) + 8;
                var iry2 = ((ctrl_y + ctrl_r_y2) - iyh) + 8;
                draw_rectangle_color(irx1, iry1 - 16, irx2, iry2 - 16, cr_c, cr_c, cr_c, cr_c, false);
                draw_text_color(ctrl_x, ctrl_y - 16 - iyh, scrScript(50), ct_c, ct_c, ct_c, ct_c, ct_a);
                var irow_add = 0;
                
                for (var i = 0; i < gp_num; i++)
                {
                    if (global.gp[i] == true)
                    {
                        var isslot = "SLOT[" + string(i) + "] - ";
                        var irow_y = irow_add * 16;
                        irow_add++;
                        var idesc = gamepad_get_description(i);
                        var ilength = string_length(idesc);
                        
                        if (ilength > 24)
                            idesc = string_copy(idesc, 1, 21) + "...";
                        
                        draw_rectangle_color(irx1, iry1 + irow_y, irx2, iry2 + irow_y, cr_c, cr_c, cr_c, cr_c, false);
                        draw_text_color(ctrl_x, (ctrl_y + irow_y) - iyh, isslot + idesc, ct_c2, ct_c2, ct_c2, ct_c2, ct_a);
                    }
                }
                
                draw_rectangle_color(irx1, iry1 + (gp_count * 16), irx2, iry2 + (gp_count * 16), cr_c, cr_c, cr_c, cr_c, false);
                draw_text_color(ctrl_x + ctrl_scroll_x, (ctrl_y + (gp_count * 16)) - iyh, ctrl_string, ct_c2, ct_c2, ct_c2, ct_c2, ct_a);
                draw_text_color(ctrl_x + ctrl_scroll_x + ctrl_scroll_add, (ctrl_y + (gp_count * 16)) - iyh, ctrl_string, ct_c2, ct_c2, ct_c2, ct_c2, ct_a);
                break;
        }
        
        draw_set_halign(fa_left);
    }
}

if (draw_add_info == 1)
{
    draw_set_halign(fa_center);
    draw_set_font(controller_font);
    var irx1 = add_r_x1;
    var irx2 = add_r_x2;
    var iry1 = add_y + add_r_y1 + 8;
    var iry2 = add_y + add_r_y2 + 8;
    draw_rectangle_color(irx1, iry1, irx2, iry2, a_c, a_c, a_c, a_c, false);
    draw_text_color(add_x + add_scroll_x, add_y, add_string, a_c2, a_c2, a_c2, a_c2, a_a);
    draw_text_color(add_x + add_scroll_x + add_scroll_add, add_y, add_string, a_c2, a_c2, a_c2, a_c2, a_a);
    draw_set_halign(fa_left);
}

for (var ip = 0; ip < pageicon_count; ip++)
{
    var ip_index = 22;
    
    if (ip == (pageicon_count - 1))
        ip_index = 206;
    
    draw_sprite(ip_index, 0, pi_x + (8 * ip), pi_y);
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_font(vn_font);
var ivn_string_length = string_length(version_number);

for (var i = 0; i < ivn_string_length; i++)
{
    var ivn_char = string_char_at(version_number, i + 1);
    var isep = 0;
    
    if (ivn_char == ".")
        isep = 2;
    
    if (ivn_string_length < 7)
        draw_text_color(vn_x + (8 * i) + isep, vn_y, ivn_char, vn_c, vn_c, vn_c, vn_c, 1);
    else
        draw_text_color((vn_x - 16) + (8 * i) + isep, vn_y, ivn_char, vn_c, vn_c, vn_c, vn_c, 1);
}

draw_set_valign(fa_top);

