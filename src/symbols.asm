t0 = $00
t1 = $01
t2 = $02
t3 = $03
tA = $04    ;temp array

starting_speed = $08
vibe_mode_flag = $09
title_tile_1 = $0a
despawn_item = $0d ;3
;1
player_y = $10
player_y_speed_pos = $11
player_y_speed_neg = $12
seecret = $13

playfield_scroll_prev = $14
already_spawned_item = $15
current_item_slot = $16
item_1_y = $17
item_2_y = $18
item_3_y = $19 
item_1_x = $1a
item_2_x = $1b
item_3_x = $1c
item_1_crop = $1d
item_2_crop = $1e
item_3_crop = $1f

;2 3 4 5
tile_buffer_left = $20 ;32
tile_buffer_right = $40 ;32
;6
score_buffer = $60 ;24
score_number_string = $77 ;7
;7E
string_ppu_pointer = $7e
;8
next_level_points = $80
design_tiles = $81; 2
design_type_offset_top = $83
design_type_offset_btm = $84

current_level = $8a
next_level_requirement = $8b
vixy_appear_timer = $8c
design_scroll_old = $8d
;9
wave_period_2 = $90 ;2
wave_accumulator_2 = $92 ;2
mod_period_2 = $94 ;2
mod_accumulator_2 = $96 ;2
wave_vol_adj_2 = $98
mod_vol_adj_2 = $99

vbl_palette_buffer = $9A ;4
vbl_palette_offset = $9E
;full_palette_offset = $9F
;A
;triangle_note_index = $A0
wave_period_1 = $A0 ;2
wave_accumulator_1 = $A2 ;2
mod_period_1 = $A4 ;2
mod_accumulator_1 = $A6 ;2
wave_vol_adj_1 = $A8
mod_vol_adj_1 = $A9
scale_notes = $AA
wibble_nudge_counter = $AD
wibble_buffer_write = $AE
wibble_buffer_read = $AF

;B C D (0-9)
vblank_character_to_write = $B0
vblank_character_index = $B1
options_timer = $B2
wall_data_buffer_collision = $B0 ;10
wall_collision_valid_timer = $BA
playfield_scroll_change = $BB
item_collected = $BC
wall_collision_occuring = $BD
death_anim_timer = $BE
current_stamina = $BF ;0-6F positive, dead if >= $80

wall_data_buffer_prev = $C0 ;10
health_tile_x_addr = $CA
health_tile = $CB
health_bar_amount = $CC
health_bar_dirchange = $CD
stamina_inc_delay = $CE
stamina_inc_timer = $CF

wall_data_buffer = $D0 ;10
design_nametable_addr = $DA ;2
pause_cooldown_timer = $DC
vbl_y_scroll = $DD
blinky_health_tile = $DE
stamina_dec_timer = $DF

;E
playfield_scroll_counter = $E0  ;2
playfield_scroll = $E2  ;2
playfield_scroll_speed = $E4
column_addr_prev = $E5
column_addr = $E6   ;2
column_update_flag = $E8 ;zero/nonzero bool

wall_column_cycle = $E9
;EA
design_scroll_counter = $EB ;2
design_scroll = $ED ;2
design_scroll_speed = $EF
;F

skip_vblank = $F0
death_flag = $F1
stop_spawning_flag = $F2
walls_slow_you_down_flag = $F3
player_anim_pointer_lo = $F4
;vblank_pointer = $F3 ;2
pad_1_rising = $F5
pad_1 = $F6
pad_1_prev = $F7
random = $F8 ;2
speed_cap = $FA
options_mode = $FB
;draw_character_in_vblank = $FC
ppuctrl_config = $FD
ppumask_config = $FE
vblank_flag = $FF

;stack RAM
;100
;300
full_palette_buffer = $100 ;32
wall_color_1 = $101
wall_color_2 = $102
design_color = $87
gem_color = $88
vixy_color = $111

wibble_buffer_1 = $140 ;64
wibble_buffer_2 = $180 ;64
