// Replace Cif's challenge grade sprite with our own Bullshit
// TARGET: STRING
draw_sprite(grade_eyecatch_index, grade, ge_x, ge_y)>ev_draw_tis_eyecatch(grade, ge_x, ge_y)

// TARGET: STRING
draw_sprite(grade_eyecatch_index, grade, (ge_x + ie * 32 - 96), ge_y)>ev_draw_tis_eyecatch(grade, (ge_x + ie * 32 - 96), ge_y)