
; Turn off rendering
.macro ppu_disable_render
	; Disable rendering
	lda #$00
	sta PPUMASK
.endmacro

; Turn on rendering
.macro ppu_enable

	; Restore PPUMASK configration.
	lda ppumask_config
	sta PPUMASK

	; Re-enable NMI
	lda ppuctrl_config
	sta PPUCTRL
.endmacro

.macro load_palette palette_data
	ppu_load_addr #$3f, #$00
	ldx #$00
:
	cpx #$10
	bcc @still_background
		lda TITLE_SCREEN_FULL_PALETTE, x ;loading sprite palettes
		bcs @meetup
	@still_background:
		lda palette_data, x
	@meetup:
	sta full_palette_buffer, x
	sta PPUDATA
	inx
	cpx #$20
	bne :-
.endmacro