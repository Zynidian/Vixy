_draw_2x2_sprite:
    ;spawn player
    ;x contains sprite offset (multiple of 16)
    
    clc
    ;y coord is already in A
    sta $204, x
    sta $208, x

    ;x coord of player in Y
    tya
    sta $207, x
    adc #$08
    sta $20b, x
    ;hiding sprites on edges of the screen
    lda t2
    and #%00000101
    beq :+
        lda #$f8
        sta $204, x ;hide first sprite if first sprite's
    :
    lda t2
    and #%00000110
    beq :+
        lda #$f8
        sta $208, x ;hide second sprite if first sprite's
    :

    ldy #$00
    lda (t0), y   ;sprite tile
    sta $205, x
    iny
    lda (t0), y   ;sprite tile
    sta $209, x
    iny
    lda (t0), y   ;sprite attributes (palette)
    sta $206, x    ;attributes
    sta $20a, x
    rts

_ppudata_write_x_times:
    ldx t3
	:
		sta PPUDATA
		dex
		bne :-
    rts

;must be run with write rows ppuctrl
;A = attr fill byte
;X = write mode
;t2+t3 points to attr data list
_write_menu_attrs:
    bit PPUSTATUS
    stx PPUADDR
    lda #$d8 ;d8 to ff
    sta PPUADDR
    ;t2 and t3 contain pointer to attr data
    ldy #$00 ;indexes into the attr data
    @loop_attr:
        jsr _write_2_attr_bytes
        jsr _write_2_attr_bytes
        jsr _write_2_attr_bytes
        jsr _write_2_attr_bytes
        cpy #31
        bcc @loop_attr
        rts

_write_2_attr_bytes:
    lda (t2), y
    sta PPUDATA
    iny
    lda (t2), y
    sta PPUDATA
    iny
    rts

_update_playfield_scroll:
    clc ;adding to the scroll position
    lda playfield_scroll_counter
    adc playfield_scroll_speed
    sta playfield_scroll_counter
    pha
    lda playfield_scroll_counter+1
    adc #$00
    and #%00111111
    sta playfield_scroll_counter+1

    asl ;bit shifting until it's formatted for PPUSCROLL
    asl
    asl
    sta t0
    lda #$00
    sta column_update_flag
    rol
    sta playfield_scroll+1
    pla
    and #%11100000
    rol
    rol
    rol
    rol
    ora t0
    sta playfield_scroll
_find_column_addr:
    lda playfield_scroll_counter+1
    and #%00011110
    cmp column_addr_prev
    beq :+
        sta column_addr
        sta column_addr_prev
        ldx playfield_scroll+1
        lda nametable_base_addrs,x
        sta column_addr+1
        sta column_update_flag ;nonzero value
    :
    rts
nametable_base_addrs:
    .byte $24, $20


;can only be ran when ppu is disabled
_draw_mono_bitmap:
    bit PPUSTATUS
    sta PPUADDR
    stx PPUADDR
	ldy #$ff
	@tile_loop:
		iny
		lda (t2), y ;t2 and t3 contain pointer to screen data
		ldx #$08
		@tilebits_loop:
			asl
			pha
			bcs :+
				lda #TITLE_TILE_0
				sta PPUDATA
				jmp @title_meetup
			:
				lda title_tile_1
				sta PPUDATA
			@title_meetup:
				pla
				dex
				bne @tilebits_loop
		cpy t0
		bne @tile_loop
    rts
