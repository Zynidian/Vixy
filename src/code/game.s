_game_init:
	jsr _wait_for_vblank
	lda #$07
	;sta triangle_note_index
	sta despawn_item
	sta despawn_item+1
	sta despawn_item+2
	lda #$00
	ldx #$10
	:
		dex
		sta $10, x
		cpx #$00
		bne :-
	ldx #$70
	:
		dex
		sta $80, x
		cpx #$00
		bne :-

	lda #%10100000
	sta ppuctrl_config

	;initializing sprite 0
	lda #190 ;y
	sta $200
	lda #$36 ;tile
	sta $201
	lda #$02 ;color palette
	sta $202
	sta $206
	lda #$84 ;x
	sta $203

	;initializing spark sprite
	lda #$32 ;tile
	sta $225
	;x gets initialized when it appears
	;y and palette gets initialized a bit lower down to leech off of another load
	ldx #$06
	:
		lda NOTE_SCALE_LIST-1, x
		sta scale_notes-1, x
		dex
		bne :-
    ;blank screen
    ppu_disable_render
	lda #$1c		;setting up palette ID for vblank writes
	sta vbl_palette_offset
	;set y scroll
	lda #$d0
	sta vbl_y_scroll
	;loading palette 
	load_palette GAME_BKG_PALETTE
	lda #$3F
    sta PPUADDR
    lda #$00
    sta PPUADDR
	
    lda #$20
    jsr _ppu_clear_nametable
	lda #$24
	jsr _ppu_clear_nametable
	;setting up health bar on screen
	lda #$E2
	sta health_tile_x_addr
	lda #$0E
    sta blinky_health_tile
	sta health_tile
	;drawing the top part of the health bar
	lda #$22
	sta PPUADDR
	lda #$C2
	sta PPUADDR
	lda #$0F
	sta $226 ;spark palette init
	ldx #29
	:
		sta PPUDATA
		dex
		bne :-
;assigning a palette to the bottom of the screen
	bit PPUSTATUS
	;lda #$20
	;sta PPUCTRL ; is this necessary?
	lda #$23
	sta PPUADDR
	lda #$E8
	sta PPUADDR
	;writing decoration / part of health attributes
	lda #$F5
	sta seecret
	ldx #$08
	stx t3
	jsr _ppudata_write_x_times
	;writing part of health
	lda #$AF
	jsr _ppudata_write_x_times
	;writing score attributes 
	lda #$AA
	jsr _ppudata_write_x_times
	
	;right nametable
	bit PPUSTATUS
	;lda #$20
	;sta PPUCTRL ; is this necessary?
	lda #$27
	sta PPUADDR
	lda #$E8
	sta PPUADDR
	lda #$55
	jsr _ppudata_write_x_times

	lda #$72 ;tile
	sta random+1 ;seeding half of the rng

	;code to draw the terrain at the bottom of the screen, and the stamina bar
	ldy #$02
	@loop_design:
		bit PPUSTATUS

		tya ;if y is 1 (second loop), set bit 3 of the nametable hi addr
		and #%00000001
		asl
		asl 
		ora #$22
		sta PPUADDR
		lda #$60
		sta PPUADDR
		ldx #8
		lda #$03
		:
			sta PPUDATA
			sta PPUDATA
			sta PPUDATA
			sta PPUDATA
			dex
			bne :-
		dey
		bne @loop_design
    ;reenable rendering
	ppu_enable

    jsr _wait_for_vblank

_title_game_init:
	lda #$f7
    sta player_y
	lda #$40 ;vixy appearing animation timer
	sta tA+2
    lda #$00
	sta vixy_appear_timer
    sta skip_vblank
    ;sta new_high_score_flag
    lda #SCORE_NUMBERS_LOCATION
    jsr _reset_current_score

	lda starting_speed
    asl
    asl
    asl ;times 4
    clc
    adc #$1C
    sta playfield_scroll_speed

    lda #STARTING_STAMINA
    sta current_stamina
	lda #$00
	jsr _set_design_pattern
	
_game_loop:
    jsr _wait_for_vblank
    jsr _readjoy
    jsr _wait_for_score_split
	
	lda stop_spawning_flag
	beq @spawning_not_stopped
		;setting new level colors
		cmp #$01
		bne :+
			jsr _generate_rng
			ldx current_level
			jsr _find_next_level_hue
			jsr _make_scale ;making a new scale for this area
		:
		;increasing speed if possible
		lda vibe_mode_flag ;if speeding up isnt allowed
		bne @skip_increasing_speed
		lda playfield_scroll_speed
		cmp speed_cap
		bcs @skip_increasing_speed
			lda stop_spawning_flag
			cmp #$60
			bne @skip_increasing_speed
				lda playfield_scroll_speed
				cmp #$40
				bcs :++
					cmp #$2A
					bcs :+
						inc playfield_scroll_speed
					:
					inc playfield_scroll_speed
				:
				inc playfield_scroll_speed
		@skip_increasing_speed:
		dec stop_spawning_flag
	@spawning_not_stopped:
	lda vixy_appear_timer
	cmp #$40
	bcs :+
		inc vixy_appear_timer
		dec tA+2
		lda tA+2
		lsr
		lsr
		lsr
		lsr
		sta tA+3
		lda player_y
		sec
		sbc tA+3
		sta player_y
	:
    
    jsr _check_wall_collision
	lda vixy_appear_timer
	cmp #$40
	bcc :+
    	jsr _move_player
	:
    jsr _update_playfield_scroll
    jsr _check_spawn_walls
    jsr _find_design_scroll_speed
    jsr _move_items
    jsr _update_wall_collision_timer
    jsr _check_spawn_item
    jsr _check_item_collision
    jsr _change_stamina
	lda vblank_flag
	and #$02
	beq :+
		jsr _update_health_tile
	:

    jsr _check_high_score
	jsr _animate_wings
    jsr _post_logic_updates

    jsr _wait_for_sprite_zero
    jsr _change_design_scroll
	jsr _find_design_tiles
	jsr _check_for_death
	jsr _refresh_palette

	lda #$ff
	sta $224 ;spark y position (disable if wall collision isnt happening)
	lda wall_collision_occuring
	beq :+
		lda random
		and #%00001111
		adc #PLAYER_X-4
		sta $227 ;spark x position

		jsr _play_wall_noise

		lda random ;random is different now
		and #%00001111
		adc player_y
		adc #$FB
		sta $224 ;spark y position
	:

	;jsr _check_triangle_note
	
    lda death_flag
    beq :+
        lda #$00
        sta death_flag
		jmp _death_anim_init
        ;jmp to death screen routine (also resets some things / revoke player ctrl)
        ;that will then let you jump to a reset game routine, which then jmp to _title_game_init 
    :
	
	;determining level thresholds
	ldx #20 ;level 0 needs only 200p
	lda current_level
	cmp #16 ;levels higher than 16 will need 1100p
	bcc :+
		ldx #110
		bne @level_meetup
	:
	cmp #8 ;levels 8 - 16 will need 800p
	bcc :+
		ldx #80
		bne @level_meetup
	:
	cmp #4 ;levels 4 - 7 will need 500p
	bcc :+
		ldx #50
		bne @level_meetup
	:
	cmp #1 ;levels 1 - 3 will need 300p
	bcc @level_meetup
		ldx #30
	@level_meetup:
	
	stx next_level_requirement

	lda next_level_points
	cmp next_level_requirement
	bcc :+
		lda #$00
		sta next_level_points
		lda current_level
		inc current_level
		lda #$F0
		sta stop_spawning_flag
	:

	@level_meet:
	lda pause_cooldown_timer
	beq :+ ;check if the pause cooldown is zero
		dec pause_cooldown_timer ;decrement it if not
		jmp _game_loop
	:
	lda pad_1_rising
	and #%00010000
	beq :+
		jsr _pause_init ;if it is, pause the game
	:
    jmp _game_loop
