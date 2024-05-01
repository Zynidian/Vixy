
_find_design_scroll_speed:
    clc
    lda playfield_scroll_speed
    lsr ;divide by 2
    adc playfield_scroll_speed ;add half to the original (1.5x)
    sta design_scroll_speed

_update_design_scroll:
    clc ;adding to the scroll position
    lda design_scroll_counter
    adc design_scroll_speed
    sta design_scroll_counter
    pha
    lda design_scroll_counter+1
    adc #$00
    and #%00111111
    sta design_scroll_counter+1

    asl ;bit shifting until it's formatted for PPUSCROLL
    asl
    asl
    sta t0
    lda #$00
    sta column_update_flag
    rol
    ora #$a8
    sta design_scroll+1
    pla
    and #%11100000
    rol
    rol
    rol
    rol
    ora t0
    sta design_scroll
    rts

_change_design_scroll:
    lda design_scroll+1
    sta PPUCTRL

    bit PPUSTATUS
    lda design_scroll
    sta PPUSCROLL
    sta PPUSCROLL
    ;this isnt working any better, i need to find out how to do clean x split
    ;lda design_scroll  ; Combine bits 7-3 of new X with 2-0 of old X
    ;eor design_scroll_old
    ;and #%11111000
    ;eor design_scroll_old
    ;sta $2005  ; Write old fine X and new coarse X
    ;bit $2002  ; Clear first/second write toggle
    ;lda design_scroll  
    ;sta design_scroll_old
    ;nop        ; Wait for the next write to land in hblank
    ;nop
    ;sta $2005  ; Write entire new X
    ;bit $2002  ; Clear first/second write toggle

	ldx #$d1 ;wait to split screen again for the stamina bar
	:
        lda t0,y
		dex
		bne :-

	bit PPUSTATUS
    lda #$04 ;x
    sta PPUSCROLL
    sta PPUSCROLL

    lda ppuctrl_config
    and #%11111100
    sta PPUCTRL
	rts

_find_design_tiles:
    ;finding design tile address
    ;hi byte
    ldx #$26 ;a8 case
    lda design_scroll+1
    cmp #$A8
    beq :+
        ldx #$22 ;a9 case
    :
    stx design_nametable_addr+1

    ;lo byte
    lda design_scroll
    and #%11111000
    lsr
    lsr
    lsr
    ora #$80
    sta design_nametable_addr

    ;finding what 2 tiles should be drawn
    ;(use the nametable addr lo byte to determine what x offset into the design should be drawn)
    and #%00000011
    ;clc
    tax
    adc design_type_offset_top
    tay
    lda DESIGN_PATTERNS, Y
    sta design_tiles

    txa
    adc design_type_offset_btm
    tay
    lda DESIGN_PATTERNS, Y
    sta design_tiles+1
    rts

_set_design_pattern:
    ;A contains the design number we want
    and #%00000010
    tax
    lda DESIGN_REFERENCES, x
    sta design_type_offset_top
    inx
    lda DESIGN_REFERENCES, x
    sta design_type_offset_btm
    rts