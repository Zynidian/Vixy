_title_init:
    lda #$f0
    sta item_1_y
    sta item_2_y
    sta item_3_y
    sta player_y
    ;wibble parameters  (should prob change how this works?)
    lda #$50
    sta wave_period_2
    lda #$11
    sta wave_period_1
    lda #$71
    sta mod_period_2
    lda #$40
    sta mod_period_1
    lda #$02
    sta wave_vol_adj_2
    sta mod_vol_adj_2
    ;sta options_mode
    lda #$01
    sta starting_speed
    sta wave_vol_adj_1

    lda #$a7
    sta speed_cap

	lda #$E0 ;x
	sta $203
	lda #$E9 ;x
	sta $207

_menu_init:
    ldx #%00011110 ;bit 1 controls if there's a column on the left side of the screen
	stx ppumask_config
    ;stx PPUMASK ;was causing the single frame render glitch on gameover
    lda #%10000000
	sta ppuctrl_config
    ; Bring the PPU back up.
	sta PPUCTRL

    _init_apu

    jsr _reset_wibble_buffer
    lda #43
    sta wibble_buffer_write
    lda #$00
    sta wibble_buffer_read
    sta wave_accumulator_1
    sta wave_accumulator_1+1
    sta mod_accumulator_1
    sta mod_accumulator_1+1
    sta wave_accumulator_2
    sta wave_accumulator_2+1
    sta mod_accumulator_2
    sta mod_accumulator_2+1

    lda #<STRINGS ;load pointer to where string data is
	sta tA
	lda #>STRINGS
	sta tA+1

    lda #84
    sta tA+3 ;write spaces
    sta vblank_character_to_write
_menu_loop:
    jsr _wait_for_vblank
    ;wait to split screen
    ;lda draw_character_in_vblank ;3
    ;beq :+ ;2+
    ;    nop
    ;    ldx #$ad ;3
    ;    bne @meet_chr ;3
    ; :
    ;ror t0      ;5
    ;ldx #$b6    ;3
    ; @meet_chr:
    ;ror t0
    ;rol t0
    ;ror t0 
    ldx #$03
    :
        dex
        bne :-
    nop

    lda #$00
    sta wibble_nudge_counter
    ldx #$bd
    jsr _delay_loop ;(x-1)*25 + 36
    ;render wibble effect
    jsr _render_wibbly_effect
    ;resetting scroll
    bit PPUSTATUS       ;4
    ;lda ppuctrl_config
    ;ora #%00000001
    ;sta PPUCTRL    
    lda #$80
    sta PPUSCROLL ;4
    sta PPUSCROLL ;4

    jsr _readjoy
    ;generating wibble waveform 1
    ldy #$10
    jsr _tick_pm_op
    ;buffering wave 1
    tay ;y contains wave sample
    lda wibble_buffer_write
    jsr _inc_mod_by_64
    sta wibble_buffer_write
    tya
    sta wibble_buffer_1, x

    ;generating wibble waveform 2
    ldy #$00
    jsr _tick_pm_op
    ;buffering wave 1
    ldx wibble_buffer_write
    sta wibble_buffer_2, x

    ;increment read index
    lda wibble_buffer_read
    jsr _inc_mod_by_64
    sta wibble_buffer_read

    ;lda vblank_flag
    ;and #$1f
    ;bne :++
    ;    lda $B8
    ;    bne :+
    ;        lda #$06
    ;        sta $B8
    ;    :
    ;    dec $B8
    ;    tax
    ;    lda scale_notes-1, x
    ;    ldx #$04
    ;    jsr _play_pulse_note
    ; :
    ;lda player_x ;testing if its game over or title:
    ;beq @not_game_over
       ;code only for game over
    ;    lda pad_1
    ;    cmp #$20
    ;    bne :+
    ;        lda #$03
    ;        sta options_mode
    ;    :
        
    @not_game_over:

	;lda options_mode
    ;just start the game if start is pressed
    ;beq @check_for_game_init
    ;cmp #$07
    ;bcs @check_for_game_init ;mode 5+ are treated like mode 0
    ;cmp #$02
    ;bne @not_option_2
    ;    jmp @dont_clear_text
    ; @not_option_2:
    ;cmp #$04
    ;bne @not_option_4
        lda pad_1_rising
        and #%11000000
        beq :+
            lda vibe_mode_flag
            eor #$01
            sta vibe_mode_flag
        :
    ;    jmp @dont_clear_text
    ; @not_option_4:
    ;cmp #$06
    ;bne @not_option_6
        lda pad_1_rising
        and #%00000110
        beq @not_decreasing
            lda starting_speed
            bne :+ ;if its 0
                lda #$0A ;set it to 9
                sta starting_speed
            :
            dec starting_speed ;decrease the speed
            jmp @check_for_game_init
        @not_decreasing:
         lda pad_1_rising
        and #%00001001
        beq @no_buttons_pressed
            lda starting_speed
            cmp #$09
            bne :+ ;if its 9
                lda #$ff ;set it to 0
                sta starting_speed
            :
            inc starting_speed ;increase the speed
        @no_buttons_pressed:
    ;        jmp @check_for_game_init
    ; @not_option_6:
    ;and #%00000001      ;if the mode is odd
    ;beq @dont_clear_text
    ;    inc options_mode
    ;    jmp @dont_check_game_init
    ; @dont_clear_text:
    ;    lda pad_1_rising
    ;    and #%00010000      ;if start is pressed
    ;    beq @dont_check_game_init
    ;        inc options_mode ;go to the next option
    ;        jmp @dont_check_game_init


    @check_for_game_init:
        lda pad_1_rising
        and #%00010000      ;if start is pressed
        beq @dont_check_game_init
            jmp _game_init ;start new game
    @dont_check_game_init:

    lda pad_1_rising
    and #%00100000
    beq :++
        lda seecret
        cmp #18
        bne :+
            jmp _seecret_screen
        :
        bcs :+
        inc seecret
    :
	;ldy #$00	;choose a string to draw
	;jsr _draw_string

    lda #$cd ;y
	sta $200
    sta $204
	lda #$01 ;color palette
	sta $202
    sta $206
	lda starting_speed ;tile
    ora #$10
	sta $201
	lda vibe_mode_flag ;tile
    ora #$10
	sta $205

    jsr _generate_rng
    jsr _refresh_palette

    ;jsr _post_logic_updates
    jmp _menu_loop

_seecret_screen:
    ppu_disable_render
    lda #$00
    sta t1
    sta PPUCTRL
    lda #$20
    jsr _ppu_clear_nametable
    jsr _spr_init
    lda #<SEECRET
	sta t2
	lda #>SEECRET
	sta t3
	lda #23
	sta t0
	lda #$20 ;hi ppuaddr
	ldx #$e0 ;lo ppuaddr
	jsr _draw_mono_bitmap
    ppu_enable
_seecret_loop:
    jsr _wait_for_vblank

    lda #$1C
    sta vbl_palette_offset
    jsr _refresh_palette

    lda vblank_flag
    and #%000000111
    bne @skip_gay
        lda t1
        clc
        adc #$01
        cmp #$0d
        bne :+
            lda #$01
        :
        sta t1
        ora #%00100000
        sta wall_color_2
    @skip_gay:

    jmp _seecret_loop