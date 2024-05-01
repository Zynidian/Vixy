;check if it's time to spawn a wall
_check_spawn_walls:
    lda column_update_flag ;check if its on a wall tick
    beq skip_spawning_wall
        ldy #$00
        
        ;inc cycle and reset to 0 after 5 (0-5)
        ldx wall_column_cycle
        inx
        cpx #$06
        bne :+
            ldx #$00
        :
        stx wall_column_cycle
        ;check if it's cycle 0 (draw a wall)
        bne :+
            ;run code for drawing walls here
            ;jsr _increase_current_score
            jmp _spawn_wall
        :
        
        ;update tiles
        ldx #64
        lda #$00
        :
            dex
            sta tile_buffer_left, x
            bne :-
        ;writing the bottom row as opaque so that sprite zero can have a more precise split
        lda #$03
        sta tile_buffer_left+19
        sta tile_buffer_right+19
        rts
skip_spawning_wall:
    ;not displaying walls
    rts

_spawn_wall:
    ;picking random wall pattern
    ;inc triangle_note_index
    jsr _buffer_prev_walls
    jsr _generate_rng
    and #%00001111
    tax ;x contains 0-15 random wall selection
    ;check if it's a level transition (dont spawn walls)
    lda stop_spawning_flag
    beq :+ ;if nonzero, set the current wall to
        ldx #$00
    :
    ;loop through and dump the bits as bytes to an array
    ldy #$06
    lda WALL_PATTERNS_LO, x
    pha
    :
        pla
        asl
        pha
        lda #0
        adc #$00
        dey
        sta wall_data_buffer+4, y
        bne :-
    pla
    ldy #$04
    lda WALL_PATTERNS_HI, x
    pha
    :
        pla
        asl
        pha
        lda #0
        adc #$00
        dey
        sta wall_data_buffer, y
        bne :-
    pla
    ;creating wall metatiles and saving them to the display buffer
    ;finding if the top tile is a wall or an empty space
    lda wall_data_buffer+9
    sta t0
    ldx #10
    lda #0
    sta t3 ;contains offset into the tile buffer
    @loop:
        dex
        ;preserve loop counter
        stx t2
        ;get a tile from the wall buffer
        lda wall_data_buffer,x
        sta t1 ;save as previous for next loop
        
        ;make a number between 0-3 depending on the current and previous wall
        asl
        ora t0
        tay
        ;special case for bottom of the screen empty tiles (needed for spr0)
        cpx #0;if it's the last row
        bne @no_special_case
            cpy #3
            bne :+ ;if its | |
                ldy #$05
                jmp @no_special_case ;special opaque | | wall tile
            :
            cpy #$00
            bne @no_special_case
                ldy #$4 ;special opaque black tile
        @no_special_case:
        ;get tile buffer offset
        ldx t3
        ;top half of the metatile
        lda WALL_TL, y ;get the top right tile
        sta tile_buffer_left, x ;store to the tile buffer
        lda WALL_TR, y ;get the top right tile
        sta tile_buffer_right, x ;store to the tile buffer
        inx
        ;bottom half of the metatile
        lda WALL_BL, y ;get the top right tile
        sta tile_buffer_left, x ;store to the tile buffer
        lda WALL_BR, y ;get the top right tile
        sta tile_buffer_right, x ;store to the tile buffer
        inx
        stx t3
        ;set current wall tile as the previous
        lda t1
        sta t0
        ;load loop counter
        ldx t2
        bne @loop

    rts

_buffer_prev_walls:
    ;save first prev to second
    ldx #$00
:
    lda wall_data_buffer_prev, x
    sta wall_data_buffer_collision, x
    inx
    cpx #$0A
    bcc :-

    ;loop through the current collision wall, and put them in the right format
    ldx #$00
:
    lda wall_data_buffer_collision+1, x ;wall tile above current
    sta t0
    lda wall_data_buffer_collision, x ;current tile
    ora t0
    sta wall_data_buffer_collision, x
    inx
    cpx #$09
    bcc :-

    lda #$21
    sta wall_collision_valid_timer
    ;save current to first prev
    ldx #$00
:
    lda wall_data_buffer, x
    sta wall_data_buffer_prev, x
    inx
    cpx #$0A
    bcc :-
    rts

_update_wall_collision_timer:
    lda wall_collision_valid_timer
    cmp #$30
    bcs :+
        sec
        sbc playfield_scroll_change	;subtract the scroll difference
        sta wall_collision_valid_timer
    :
    rts

_check_wall_collision:
    ;check if the wall is lined up with the player
    lda wall_collision_valid_timer
    cmp #$20
    bcs :+
    ;test two wall tiles to see if there's a collision
    lda player_y
    adc #03
    jsr test_for_wall
    sta t0
    lda player_y
    adc #13
    jsr test_for_wall
    ora t0
    sta wall_collision_occuring
    rts
    :
    lda #$00
    sta wall_collision_occuring
    rts

test_for_wall:
    lsr
    lsr
    lsr
    lsr
    clc
    adc #$01
    eor #$0F
    sec
    sbc #3
    tax
    lda wall_data_buffer_collision, x
    rts