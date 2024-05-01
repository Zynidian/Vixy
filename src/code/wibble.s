_render_wibbly_effect:
    lda wibble_buffer_read ;both buffers use the same read pos
    sta t3
    tay
    ldx #41
_wibble_loop:
    stx t2 ;2
    
    jsr _render_buffer_1_scanline ;6
    ;delay
    ldx #16 ;2
    :
        dex  ;2
        bne :- ;2 (3 when done)
    lda t0,x ;4

    jsr _render_buffer_2_scanline ;6 ;change to buffer 2 (same as 1, but uses buffer 2)
    ;delay
    ldx #09 ;2
    :
        dex  ;2
        bne :- ;2 (3 when done)
    ;lda t0, x
    ;every 4th frame, add a cpu cycle (keeps it closest to right side of screen)
    nop
    inc wibble_nudge_counter ;5
    lda wibble_nudge_counter ;3
    and #%00000011           ;2
    bne :+                   ;2/3
        nop                  ;2
    :
    ;go to the next byte in the buffers
    clc             ;2  14
    lda t3          ;3
    adc #$01        ;2
    and #%00111111  ;2
    sta t3          ;3
    tay             ;2 ;contains offset into buffer
    ;loop counter updating
    ldx t2          ;3  8
    dex             ;2
    bne _wibble_loop;3 (pg boundary crossing is possible)
    rts

_render_buffer_1_scanline:
    bit PPUSTATUS       ;4
    lda wibble_buffer_1, y ;4
    sta PPUSCROLL ;4
    sta PPUSCROLL ;4
    rts             ;6

_render_buffer_2_scanline:
    bit PPUSTATUS       ;4
    lda wibble_buffer_2, y ;4
    sta PPUSCROLL ;4
    sta PPUSCROLL ;4
    rts             ;6

_inc_mod_by_64:
    clc
    adc #$01
    and #%00111111  ;putting write head in 0-63
    tax
    rts
    
;0c is centered on screen, 00 is furthest to right, 18 is furthest left
_tick_pm_op:
    ;lda #%00000000   WHY IS THIS HERE????
    ;sta PPUCTRL

    clc
    lda mod_accumulator_2, y
    adc mod_period_2, y
    sta mod_accumulator_2, y
    lda mod_accumulator_2+1, y
    adc mod_period_2+1, y
    sta mod_accumulator_2+1, y
    and #%00001111
    tax
    lda SINE_TABLE, x
    sta t0

    lda mod_vol_adj_2, y
    jsr _find_adj_vol
    
    clc
    lda wave_accumulator_2, y
    adc wave_period_2, y
    sta wave_accumulator_2, y
    lda wave_accumulator_2+1, y
    adc wave_period_2+1, y
    sta wave_accumulator_2+1, y
    clc
    adc t0
    and #%00011111
    tax
    lda SINE_TABLE, x
    sta t0

    lda wave_vol_adj_2, y
    jsr _find_adj_vol
    ;A contains sample
    rts

_find_adj_vol:
    tax ;x now has tbe number of times to shift t0
    lda WAVE_VOL_CENTER_ADJ, x ;recenter the waveform
    sta t1
    txa
    beq @skip
    @shift_loop:
        lsr t0 ;divide by 2
        dex
        bne @shift_loop
    @skip:
    clc
    lda t0
    adc t1
    sta t0
    rts

_reset_wibble_buffer:
    lda #$0d
    ldx #$80
    :
        dex
        sta wibble_buffer_1, X
        cpx #$00
        bne :-
    rts

WAVE_VOL_CENTER_ADJ:
    .byte $00, $06, $09, $0B, $0C

SINE_TABLE:
    .byte $0d,$0f,$11,$13,$15,$16,$17,$17,$17,$17,$16,$15,$13,$11,$0f,$0d
    .byte $0a,$08,$06,$04,$02,$01,$00,$00,$00,$00,$01,$02,$04,$06,$08,$0a
