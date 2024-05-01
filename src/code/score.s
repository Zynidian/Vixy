;optimization pass 1, 8/16/23, 0.06 K saved
_reset_scores:
    sta score_buffer
    sta score_buffer+1
    sta score_buffer+2
    sta score_buffer+3
    sta score_buffer+4
    sta score_buffer+5
_reset_current_score:
    sta score_buffer+22
    sta score_buffer+21
    sta score_buffer+20
    sta score_buffer+19
    sta score_buffer+18
    sta score_buffer+17
    rts

_increase_current_score:
    ldx #$05
    :
        clc
        dex
        lda score_buffer+17, x
        adc #$01
        sta score_buffer+17, x
        cmp #SCORE_NUMBERS_LOCATION+10 ;checking if the number carried
        bcc _score_exit
        lda #SCORE_NUMBERS_LOCATION
        sta score_buffer+17, x
        txa
        bne :-

        lda #SCORE_NUMBERS_LOCATION+9
        jmp _reset_scores

_check_high_score:
    ;compare current score to high score
    ldx #$00
_score_loop:
        lda score_buffer+17, x
        cmp score_buffer, x
        bcc _score_exit
        beq _score_equal
        bcs _score_is_greater
    _score_equal:
        inx
        cpx #$06
        bcc _score_loop
_score_exit:
    rts
_score_is_greater:
    ;if it's higher than the high score, replace the high score with the current one
    ldx #$05
    :
        lda score_buffer+17, x
        sta score_buffer, x
        dex
        bpl :-
    rts