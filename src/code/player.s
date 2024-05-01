_move_player:
    clc
    lda pad_1
    and #(BUTTON_UP+BUTTON_B)
    beq @goto_pressdown
        ;if the player is pressing up
        lda player_y_speed_neg
        adc #$01
        cmp #PLAYER_Y_SPEED_CAP
        bcs :+
            sta player_y_speed_neg
        :
        jmp @skip
    @goto_pressdown:
        lda player_y_speed_neg
        cmp #$06
        bcc :+
            dec player_y_speed_neg
            dec player_y_speed_neg
        :
    ;move player down
    lda pad_1
    and #(BUTTON_DOWN+BUTTON_A)
    beq @skip
        ;if the player is pressing down
        lda player_y_speed_pos
        adc #$01
        cmp #PLAYER_Y_SPEED_CAP
        bcs :+
            sta player_y_speed_pos
        :
        jmp _update_player_y
    @skip:
        ;decrease speed if there's no input
        lda player_y_speed_pos
        cmp #$06
        bcc :+
            dec player_y_speed_pos
            dec player_y_speed_pos
        :
    _update_player_y:
        lda player_y_speed_pos
        lsr
        lsr
        lsr
        clc
        adc player_y
        sta player_y
        lda player_y_speed_neg
        lsr
        lsr
        lsr
        clc
        eor #$ff
        adc player_y
        clc
        adc #$01
        
        ldx #$05
        cmp #PLAYER_TOP_CAP
        bcs :+  ;skip if greater than
            stx player_y_speed_neg    ;else cap position and kill upward momentum
            lda #PLAYER_TOP_CAP
        :
        cmp #PLAYER_BTM_CAP+1
        bcc :+  ;skip if less than
            stx player_y_speed_pos    ;else cap position and kill downward momentum
            lda #PLAYER_BTM_CAP
        :
        sta player_y
        rts

_check_item_collision:
    ldx #$00
@loop_through_items:
    sec
    lda item_1_y, x
    sbc player_y
    adc #$0D
    cmp #$1A
    bcs @no_collision
        ;if the difference between coords is < 15
        sec
        lda item_1_x, x
        sbc #PLAYER_X
        adc #$0D
        cmp #$1A
        bcs @no_collision
            ;if both x and y fall in the collision range
            ;check if the item is inactive
            lda despawn_item, x
            cmp #$07
            beq @no_collision
                ;if it is active, collect it
                ;setting up note to be played
                lda item_1_y, x
                sec
                sbc #$1e ;00 - 8f range
                lsr
                lsr
                lsr ;top 5 bits only
                jsr _divide_by_3 
                lda scale_notes, y
                _play_gem_note
                ;delete the item
                lda #$07
                sta item_1_crop, x
                sta item_1_y, x
                sta despawn_item, x

                sta item_collected ;store a nonzero value
                inc next_level_points
                jsr _increase_current_score
    @no_collision:
    inx
    cpx #$03
    bcc @loop_through_items
    rts

;result is in y register
;mod result is in a
_divide_by_3:
    clc
    adc #$03
    ldy #$00
    @divide_loop:
        sec
        sbc #$03
        cmp #$03
        bcc :+
        iny
        bcs @divide_loop
    :
    rts

;player_anim_pointer_lo points to animation frame to display
;#<PLAYER_SPRITE_TILES will be the number for frame 1, +3 will be frame 2, +6 frame 3 
;moving up will increase the speed of the animation (should be some factor of the og speed)
;moving down will stop on frame 1 when it reaches it in the animation cycle

_animate_wings:
    lda vblank_flag
    and #%00011111
    lsr
    tax
    lda ANIM_FRAME_TABLE, x
    sta player_anim_pointer_lo
    rts

ANIM_FRAME_TABLE:
    .byte <PLAYER_SPRITE_TILES, <PLAYER_SPRITE_TILES
    .byte <PLAYER_SPRITE_TILES, <PLAYER_SPRITE_TILES
    .byte <PLAYER_SPRITE_TILES, <PLAYER_SPRITE_TILES
    .byte <PLAYER_SPRITE_TILES+3, <PLAYER_SPRITE_TILES+3
    .byte <PLAYER_SPRITE_TILES+3, <PLAYER_SPRITE_TILES+6
    .byte <PLAYER_SPRITE_TILES+6, <PLAYER_SPRITE_TILES+6
    .byte <PLAYER_SPRITE_TILES+6, <PLAYER_SPRITE_TILES+3
    .byte <PLAYER_SPRITE_TILES+3, <PLAYER_SPRITE_TILES+3