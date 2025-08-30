/*
draw_set_font(global.ev_font)
draw_set_halign(fa_left)
draw_set_valign(fa_top)

var long_text = 
@"Controls:
Use your mouse.
Backspace - Exit out of a level.
CTRL + Z - Undo hotkey.
Shift - Switch between tiles and objects.
1-7 - Tile/object selection hotkeys.
Middle Click - Picker tool hotkey.

The action key, bound to Z by default, 
can modify properties of tiles and objects, like the rotation of Leeches,
or the contents of chests. Try it on all of them!

NOTE: You will be banned from the official server
for not using common sense.";

var size = 0.5
draw_set_color(c_black)
draw_text_transformed(4 + size, 5, long_text, size, size, 0)
draw_text_transformed(4 - size, 5, long_text, size, size, 0)
draw_text_transformed(4, 5 + size, long_text, size, size, 0)
draw_text_transformed(4, 5 - size, long_text, size, size, 0)

draw_set_color(c_white)
draw_text_transformed(4, 5, long_text, size, size, 0)
