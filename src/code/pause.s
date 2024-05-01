_pause_init:
    lda #$1F ;color tint setting
    sta ppumask_config
    lda #$90 ;pause delay
    sta pause_cooldown_timer
    ;reset palette write to sprite palette 4
_pause_loop:
    jsr _wait_for_vblank
    jsr _readjoy
    jsr _wait_for_score_split

    jsr _wait_for_sprite_zero
    jsr _change_design_scroll

    lda pad_1_rising ;if start was pressed
	and #%00010000
	beq _pause_loop

    ;exit pause routine
    lda #$1e
    sta ppumask_config
    rts


;check_start_rising:
;    lda pad_1
;    and #%00010000 ;mask out start
;    cmp pad_1_prev
;    beq :+ ;skip if equal
;        bcc :+ ;skip if less than
;        ;if start is rising (just pressed)
;        ldy #$42 ;set y to $42
;    :
;    sta pad_1_prev
;    rts