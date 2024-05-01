;include code for:
    ;✔adding stamina when an item is collected
    ;✔decreasing stamina when a wall is hit, based on how fast the speed is
    ;✔checking for death situation
    ;✔flashing stamina bar when it gets low
    ;✔death occurs when the bar is empty (very low stamina goes slow, but not super slow)
    ;~making stamina and speed decrease/increase smoothly
    ;✔stamina handles changes only one at a time (use a timer), with increases always taking priority

    ;draw will contain the code to actually draw the stamina bar
_change_stamina:
    lda item_collected
    beq :+ ;if an item was just collected
        lda #STAMINA_GAIN_TIME
        sta stamina_inc_timer
        lda #$00
        sta item_collected ;reset item collected flag

    :
    lda stamina_inc_timer
    beq @skip_stamina_inc ;if stamina is being increased:
        dec stamina_inc_timer

        lda stamina_inc_delay
        bne :++ ;if the delay counter is zero
            inc current_stamina ;increment stamina

            lda current_stamina
            jsr _check_for_death
            ;capping stamina value to 112 (28*4)
            cmp #112
            bcc :+
                lda #111
                sta current_stamina
            :

            lda #STAMINA_GAIN_DELAY ;set gain delay
            sta stamina_inc_delay
            jmp @meetup

        : ;else:
            dec stamina_inc_delay ;decrement gain delay counter

        @meetup:
        ;rts ;remove this if both increasing stamina from an item and decreasing from a wall are allowed simultaneously
    @skip_stamina_inc: ;if stamina isnt currently increasing
    jsr _decrease_stamina
    rts

_decrease_stamina:
    lda wall_collision_occuring
    beq @exit ;leave if false

    ;if wall collision is occuring
    lda stamina_dec_timer ;check if the timer is 0
    beq _start_stamina_hurt_timer ;if it's zero, reset timer and deal damage
    dec stamina_dec_timer ;otherwise just decrement the timer
    @exit:  ;turns out cheap local labels must be within the same routine label, so in this case, _decrease_stamina
    rts     ;if @exit was in, say _start_stamina_hurt_timer, it wouldnt work
    
_start_stamina_hurt_timer:
    lda #STAMINA_HURT_TIME
    sta stamina_dec_timer ;set timer to amount of frames to wait till damage is dealt again

    lda playfield_scroll_speed
    lsr
    lsr 
    lsr ;divide current speed by 8
    tax
    lda STAMINA_DEC_VALUES, x ;look up a damage value from the table below
    sta t0

    sec
    lda current_stamina
    sbc t0 ;do damage based on how much stamina you have
    sta current_stamina
    rts

_check_for_death: ;A has current_stamina
    lda current_stamina
    ;checking if it underflowed (death)
    cmp #$D0
    bcc @not_dead
        ;make sure health bar is also empty (except last tile)
        lda health_bar_amount
        bne @not_dead
            inc death_flag
            ;empty the last tile
            lda #$00
            sta blinky_health_tile     
    @not_dead:
    rts


;when used, store these in RAM so that they can change based on walls slowing down option?
STAMINA_DEC_VALUES:
    .byte $04,$06,$08,$0a,$0c,$0e,$10,$12,$14,$16,$19,$1b,$1e,$20,$22

_update_health_tile:
    lda current_stamina
    lsr
    lsr ;divide by 4
    cmp #29
    bcc :+ ;skip if less than 29
        lda #$00
    :
    cmp health_bar_amount
    bcs @not_lessthan ;if current stamina is < health_bar_amount
        lda health_bar_dirchange
        bne :+
            dec health_bar_amount
        :
        lda #$00
        tax     ;state 0: <
        jmp @set_health_tile

    @not_lessthan:
    beq @not_greaterthan ;if it's greater
        lda health_bar_dirchange
        cmp #$01
        bne :+
            inc health_bar_amount
        :
        lda #$0E
        ldx #$01 ;state 1: >
        @set_health_tile:
            sta health_tile
            stx health_bar_dirchange
            jmp @meetup
    @not_greaterthan: ;if they're equal
        lda #$02 ;state 2: =
        sta health_bar_dirchange
    @meetup:

    lda health_bar_amount
    clc
    adc #$E2
    sta health_tile_x_addr
    ;blinky tile for <4 hp
    ;lda health_bar_amount
    ;bne @skip_blink ;if not 0
    ;    lda vblank_flag
    ;    and #$10 ;blink every 16 frames
    ;    bne @skip_blink
    ;        lda #$00
    ;        beq @blink_meet
    ;    @skip_blink:
    ;        lda #$0E
    ;    @blink_meet:
    ;        sta blinky_health_tile
    ;        rts
    lda #$0E
    sta blinky_health_tile
    rts
