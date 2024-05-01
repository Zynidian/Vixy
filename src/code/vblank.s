
_nmi_vector:
	pha				; Preseve Registers
	tya
	pha
	txa
	pha

	ldx #$24        ; write columns, not rows
	stx PPUCTRL		; Disable NMI

	lda #$02	;copys $200 OAM to PPU Memory
	sta $4014
    
    ; update 2 columns of tiles
    ;left column
    lda skip_vblank
    beq :+
        jmp _vbl_skip
    :
    bit PPUSTATUS
    lda column_addr+1
    sta PPUADDR
    lda column_addr
    sta PPUADDR
    ldx #$00
    :
        lda tile_buffer_left,x
        sta PPUDATA
        inx
        cpx #20
        bcc :-

    ;right column
    bit PPUSTATUS
    lda column_addr+1
    sta PPUADDR
    ldx column_addr
    inx
    stx PPUADDR

    ldx #$00
    :
        lda tile_buffer_right,x
        sta PPUDATA
        inx
        cpx #20
        bcc :-

    ;drawing design at the bottom of the screen
    bit PPUSTATUS
    lda design_nametable_addr+1
    sta PPUADDR
    lda design_nametable_addr
    sta PPUADDR
    lda design_tiles
    sta PPUDATA
    lda design_tiles+1
    sta PPUDATA

    ;updating score
    bit PPUSTATUS
    lda #$20        ; write rows

	sta PPUCTRL
    lda #$23
    sta PPUADDR
    lda #$84
    sta PPUADDR
    ldx #$00
    :
        lda score_buffer,x
        sta PPUDATA
        inx
        cpx #$17
        bcc :-
    ; update a single palette color
	; update arbitrary tiles (stamina bar)
    clc
    bit PPUSTATUS
    lda #$22
    sta PPUADDR
    lda health_tile_x_addr
    adc #$01
    sta PPUADDR
    lda health_tile
    sta PPUDATA

    bit PPUSTATUS
    lda #$22
    sta PPUADDR
    lda #$e2
    sta PPUADDR
    lda blinky_health_tile
    sta PPUDATA
    
_vbl_skip:
    ;lda #$24        ; write columns
	;sta PPUCTRL

    ;6 if not, 881 if so
    ;lda draw_character_in_vblank ;3
    ;beq :+ ;3 if no, 2 if yes
    ;    lda vblank_character_to_write ;3
    ;    jsr _draw_single_text_chr ;876
    ; :

    lda #$20        ; write rows
	sta PPUCTRL

    bit PPUSTATUS
    lda #$3F
    sta PPUADDR
    lda vbl_palette_offset
    sta PPUADDR
	ldx #$00
:
	lda vbl_palette_buffer, x
	sta PPUDATA
	inx
	cpx #$04
	bne :-

    lda #$3F    ;2
    sta PPUADDR ;4
    lda #$00    ;2
    sta PPUADDR ;4
    sta PPUADDR ;4
    sta PPUADDR ;4

    bit PPUSTATUS
	lda #$00
	sta PPUSCROLL ; X scroll
    lda vbl_y_scroll
	sta PPUSCROLL ; Y scroll

	;lda #$80
_vbl_done:
	bit PPUSTATUS			; Check if vblank has finished
	;bne _vbl_done			; Repeat until vblank is over

	lda ppumask_config
	sta PPUMASK
	lda ppuctrl_config
	ora #%10000000
    and #%11111110
	sta PPUCTRL			; Re-enable NMI

	inc vblank_flag
    
	pla				; Restore registers
	tax
	pla
	tay
	pla

	rti