_death_anim_init:
    lda #$80
    sta death_anim_timer
    lda #$00
    sta blinky_health_tile
    sta tA
    sta tA+1
_death_anim:
    jsr _wait_for_vblank
    jsr _wait_for_score_split

    ;reset palette write to sprite palette 4
    lda #$1c
    sta vbl_palette_offset
    
    ;jsr _move_player
    jsr _update_playfield_scroll
    jsr _check_spawn_walls
    jsr _find_design_scroll_speed
    jsr _make_player_fall
    jsr _move_items
    ;jsr _check_triangle_note
    ;jsr _check_item_collision

    lda #$ff
	sta $224 ;disable sparks

    jsr _check_high_score
    jsr _post_logic_updates

    jsr _wait_for_sprite_zero
    jsr _change_design_scroll

    dec death_anim_timer
    beq _gameover_init ;if the timer reaches 0

    jmp _death_anim

_gameover_init:
    lda #$d3
    sta pad_1_prev ;2 byte hack for making it so holding start before gmovr doesnt start new game
	sta vbl_y_scroll

    lda #$01
    sta skip_vblank
    jsr _wait_for_vblank
    ;setting random periods for the wibble
    ldx #$02
    ldy #$00
    :
        sty t0
        jsr _generate_rng
        ldy t0
        and #%01111111
        sta wave_period_1,y
        lda random+1
        and #%11111111
        sta wave_period_2,y
        ldy #$04
        dex
        bne :-
    ;setting volumes

    ldx #$04
    jsr _generate_rng
    @loop_vols:
        lda VOL_ADJ_OFFSETS, x
        tay

        ror random
        bcs :+
            lda #$01
            bcc @vols_meet
        :
            lda #$02
        @vols_meet:
        sta wave_vol_adj_2, y
        dex
        bne @loop_vols
    
    lda #$0F
    sta vbl_palette_buffer
    sta vbl_palette_buffer+3
    lda #$15
    sta vbl_palette_buffer+1
    lda #$25
    sta vbl_palette_buffer+2

    jsr _format_gameover_score
    
    ppu_disable_render ;disable rendering
	lda #$00
    ;sta options_mode
	sta PPUCTRL ;disable nmi

    load_palette GAMEOVER_PALETTE
	lda #$3F
    sta PPUADDR
    lda #$00
    sta PPUADDR
    sta vbl_palette_offset

    lda #$20
    jsr _ppu_clear_nametable
    lda #$24
    jsr _ppu_clear_nametable

    lda #TITLE_TILE_1
	sta title_tile_1
    ;drawing the game over text
	lda #<GAMEOVER_SCREEN_DATA
	sta t2
	lda #>GAMEOVER_SCREEN_DATA
	sta t3
    lda #39 ;size
	sta t0
    lda #$20 ;hi ppuaddr
	ldx #$00 ;lo ppuaddr
	jsr _draw_mono_bitmap
    
    ;jsr 

    ;title picture (bottom right)
	lda #$02
	sta title_tile_1
	lda #<TITLE_PICTURE_DATA
	sta t2
	lda #>TITLE_PICTURE_DATA
	sta t3
	lda #51
	sta t0
	lda #$25 ;hi ppuaddr
	ldx #$80 ;lo ppuaddr
	jsr _draw_mono_bitmap

    ;score attributes
	bit PPUSTATUS
	lda #$23
	sta PPUADDR
	lda #$d8
	sta PPUADDR
	lda #$AA
	ldx #32
	stx t3
	jsr _ppudata_write_x_times

    ;gameover picture attrs
    lda #<TITLE_PICTURE_ATTRS
	sta t2
	lda #>TITLE_PICTURE_ATTRS
	sta t3
    ldx #$27
	lda #$FF
    sta score_number_string+6 ;for drawing score
	jsr _write_menu_attrs

    ;draw score to the screen
    lda #$24
	sta PPUCTRL ;write columns
	lda #$22	;load PPU adress where the string will be
	sta string_ppu_pointer
	lda #$13
	sta string_ppu_pointer+1

	lda #<score_number_string ;load pointer to where string data is
	sta tA
	
	ldy #$00	;choose a string to draw
    sty tA+1
    sty tA+3	;draw a space between each character
	jsr _draw_string

    jsr _spr_init

    lda #$16 ;x
	sta $203
	lda #$1f ;x
	sta $207

    jmp _menu_init

VOL_ADJ_OFFSETS:
    .byte $00,$00,$01,$10,$11

_make_player_fall:
    lda tA+1
    bne @skip

    inc tA
    lda tA
    lsr
    clc
    adc player_y
    sta player_y
    bcc @skip
        inc tA+1
        lda #$ff
        sta player_y
        rts
    @skip:
    rts

;_find_score_text:
;    lda 