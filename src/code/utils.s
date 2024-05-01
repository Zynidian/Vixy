_wait_for_vblank:
    lda vblank_flag
@notYet:
    cmp vblank_flag
    beq @notYet
    rts

_delay_loop: ;(x-1)*25 + 30
    :
        ror t0
        rol t0
		ror t0
        rol t0
		dex
        bne :-
    rts

_wait_for_score_split:
	ldx #153
	jsr _delay_loop

	;setting primary scroll position
    bit PPUSTATUS
    lda playfield_scroll
    sta PPUSCROLL
    sta PPUSCROLL

	lda ppuctrl_config
    and #%11111110
    ora playfield_scroll+1
    sta ppuctrl_config
	sta PPUCTRL
    ;setting base nametable for scroll
	rts

_wait_for_sprite_zero:
	bit PPUSTATUS ;V flag contains sprite zero hit state
	bvc _wait_for_sprite_zero
	rts

_ppu_clear_nametable:
	;a contains base nametable
	ldx #$00			
	bit PPUSTATUS
	sta PPUADDR ; Upper byte of VRAM Address
	stx PPUADDR ; Lower byte of VRAM Address

    lda #$00
	ldy #$04
	@loop:
		:
			sta PPUDATA
			inx
			bne :-
		dey
		bne @loop
	rts

_post_logic_updates:
    ;draw player
	ldx #$00
	;changing this pointer's lo byte would change animation frames
	lda player_anim_pointer_lo
	sta t0
	lda #>PLAYER_SPRITE_TILES
	sta t1
	lda #$00 ;sprite crop settings (0 means no crop)
	sta t2
	lda player_y
	ldy #PLAYER_X
	jsr _draw_2x2_sprite

	;drawing item sprites
	ldx #$08
	lda #<ITEM_SPRITE_TILES
	sta t0
	lda #>ITEM_SPRITE_TILES
	sta t1
	lda item_1_crop
	sta t2
	lda item_1_y
	ldy item_1_x
	
	jsr _draw_2x2_sprite

	ldx #$10
	lda item_2_crop
	sta t2
	lda item_2_y
	ldy item_2_x
	jsr _draw_2x2_sprite
	ldx #$18
	lda item_3_crop
	sta t2
	lda item_3_y
	ldy item_3_x
	jsr _draw_2x2_sprite
	
	rts


; Controller reading code from NESDev
; Out: A=buttons pressed, where bit 0 is A button

_readjoy:
	lda pad_1
	sta pad_1_prev
    lda #$01
    ; While the strobe bit is set, buttons will be continuously reloaded.
    ; This means that reading from JOYPAD1 will only return the state of the
    ; first button: button A.
    sta $4016
    sta pad_1
    lsr a        ; now A is 0
    ; By storing 0 into JOYPAD1, the strobe bit is cleared and the reloading stops.
    ; This allows all 8 buttons (newly reloaded) to be read from JOYPAD1.
    sta $4016
@loop:
    lda $4016
    lsr a	       ; bit 0 -> Carry
    rol pad_1  ; Carry -> bit 0; bit 7 -> Carry
    bcc @loop

_filter_joy_rising:
	lda pad_1
	and pad_1_prev
	sta t0
	lda pad_1
	eor #$FF
	ora t0
	eor #$FF
	sta pad_1_rising
	rts
	
; temp is a zero-page variable 

; Clear the OAM table
_spr_init:
	ldx #$00
	lda #$FF
@clroam_loop:
	sta OAM_BASE, x
	inx
	bne @clroam_loop
	rts

