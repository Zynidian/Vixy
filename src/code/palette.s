;A contains low addr, Y contains hi addr
_copy_palette_to_buffer:
    sta tA
    sty tA+1
    ldy #$00
    :
        lda (tA),y
        sta full_palette_buffer, x
        iny
        inx
        cpy tA+2
        bne :-
    rts

_refresh_palette:
    ;move to the next palette in the list
    clc
    lda vbl_palette_offset
    adc #$04
    and #%00011111
    sta vbl_palette_offset
    tax
    ;copy the current palette to the buffer
    ldy #$00
    :
        lda full_palette_buffer, x
        sta vbl_palette_buffer, y
        inx
        iny
        cpy #$04
        bne :-
    rts
    
;A has the byte for the 1st hue
_find_next_level_hue:
    tay
    and #%00001111
    tax
    tya
    and #%10000000
    pha
    tya
    and #%00100000
    sta t2

    lda WALL_HUES, x
    sta wall_color_1
    lda VIXY_HUES, x
    sta vixy_color
    pla
    beq :+
        inx
    :
    lda WALL_HUES, x
    ldy t2
    bne :+
        clc
        adc #$10
    :
    sta wall_color_2
    rts

WALL_HUES:
    .byte $11,$12,$13,$14,$15,$16,$17,$18,$19,$1a,$1b,$1c,$11,$13,$15,$16,$17
VIXY_HUES:
    .byte $13,$13,$14,$14,$14,$15,$15,$14,$14,$14,$14,$13,$13,$14,$15,$16