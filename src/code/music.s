;taken from nesdev
.macro _init_apu
        ; Init $4000-4013
        ldy #$13
@loop:  lda APU_INIT_REGS,y
        sta $4000,y
        dey
        bpl @loop

        ; We have to skip over $4014 (OAMDMA)
        lda #$0f
        sta $4015
        lda #$40
        sta $4017  
.endmacro

APU_INIT_REGS:
    .byte %10000101,$08,$00,$00
    .byte %10000101,$08,$00,$00
    .byte $80,$00,$00,$00
    .byte $30,$00,$00,$00
    .byte $00,$00,$00,$00

.macro _play_gem_note
    sta $4002
    clc
    adc #$01
    sta $4006
    lda #$08
    sta $4003
    sta $4007
.endmacro

;.macro _play_triangle_note
;    sta $400A
;    lda #$9f
;    sta $4008
;    lda #$00
;    sta $400B
;.endmacro

;_check_triangle_note:
;    lda wall_column_cycle
;	bne @dont_change_triangle
;        lda triangle_note_index
;        and #%00000011 ;0-3
;        tay
;        lda scale_notes+2, y
;        _play_triangle_note
;	@dont_change_triangle:
;    rts

_play_wall_noise:
    jsr _generate_rng
    ora #%10000000
    sta $400E
    lda #$01
    sta $400F
    lda #$13
    sta $400C
    rts
NOTE_SCALE_LIST:
    .byte $54,$5E,$70,$7E,$9F,$BD ;further left is higher up
;note reference:
;     A  Bb   B   C  Db   D  Eb   E   F  Gb   G  Ab
; 4: FD  EF  E1  D5  C9  BD  B3  A9  9F  96  8E  86
; 5: 7E  77  70  6A  64  5E  59  54  4F  4B  47  43
; 6: 3F  3B  38  35  32  2F  2C  2A  27  25  23  21

NOTE_LIST:
    .byte $E1,$D5,$C9,$BD,$B3,$A9,$9F,$96,$8E,$86
    .byte $7E,$77,$70,$6A,$64,$5E,$59,$54,$4F,$4B,$47,$43

_make_scale:
    lda #$00
    sta t1 ;accumulates the index into the note list
    sta t0 ;holds previous note interval
    ldx #$06
@note_loop:
    jsr _generate_rng
    sec
@mod_3: ;putting interval in range 2-4
    sbc #$03
    bcs @mod_3
    adc #$05
    ;code making sure diminished and augmented intervals aren't allowed
    ;also converts what would be whole tone scales into sus 2 intervals
    ;(makes things sound nicer without taking up too much extra space)
    cmp t0 ;compare with the previous interval
    bne @notspecial ;skip if they're different
        eor #%00000111  ;4 into 3 (aug -> major)
                        ;3 into 4 (dim -> minor)
                        ;2 into 5 (potential whole tone -> sus 2)
@notspecial:
    cpx #$06 ;see if its the first note determining
    beq @dontstoreprev
        sta t0 ;store as previous
@dontstoreprev:
    clc
    adc t1
    sta t1 ;add interval to index
    tay
    lda NOTE_LIST-2, y ;get a note from the list
    sta scale_notes-1, x ;store into the scale ram
    dex
    bne @note_loop ;loop
    rts

SEECRET:
    .byte %00111101,%01011001,%01100100,%10011000
    .byte %00001001,%01010100,%01010001,%01010100
    .byte %00010001,%11010101,%01010101,%11010100
    .byte %00111100,%01010101,%01100101,%01010100
    .byte %00000001,%11000000,%00000000,%00000000
    .byte %00000000,%00000000,%00011111,%10011100