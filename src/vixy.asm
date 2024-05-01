 ; iNES Header
.include "header.asm"

;=-=-=-=-=-=-=-=-=-=-=-=
;        V I X Y
;   Zynidian 8/16/23
;=-=-=-=-=-=-=-=-=-=-=-=

; =============================
; Zero-page and main RAM
; Variables, flags, etc.
; =============================
.segment "ZEROPAGE"
.segment "RAM"
;Symbols
.include "symbols.asm"
.include "cool_macros.asm"
.include "macros.asm"
.include "const.asm"

.segment "PRGROM"
.include "data/title_scr_data.s"
.include "data/gmovr_scr_data.s"
.include "data/title_pic_data.s"
.include "data/letter_data.s"
.include "data/palettes.s"
.include "data/wall_pattern.s"
.include "data/tile_arrangements.s"
.include "code/wibble.s"
.include "code/music.s"
.include "code/utils.s"
.include "code/vblank.s"
.include "code/rng.s"
.include "code/design.s"
.include "code/draw.s"
.include "code/letters.s"
.include "code/score.s"
.include "code/stamina.s"
.include "code/wall.s"
.include "code/item.s"
.include "code/player.s"
.include "code/pause.s"
.include "code/palette.s"
.include "code/title.s"
.include "code/game.s"
.include "code/gameover.s"

; ============================
; Entry vector
; ============================

_reset_vector:
	sei				; ignore IRQs
	cld				; No decimal mode, it isn't supported
	ldx #%00000100
	stx $4017			; Disable APU frame IRQ

	ldx #$ff
	txs				; Set up stack

; Clear some PPU registers
	inx				; X = 0 now
	stx PPUCTRL			; Disable NMI
	stx PPUMASK			; Disable rendering
	stx DMCFREQ			; Disable DMC IRQs

; Wait for first vblank
	bit PPUSTATUS

@waitvbl1:
	bit PPUSTATUS
	bpl @waitvbl1

; Wait for the PPU to go stable
	txa
@clrmem:
	sta $000, x
	sta $100, x
	;sta $700, x

	inx
	bne @clrmem

	lda $700		;seeding rng
	sta random+1

	lda #$1c		;setting up palette ID for vblank writes
	sta vbl_palette_offset

;checking region, taken from https://forums.nesdev.org/viewtopic.php?t=13776 
;;; use the power-on wait to detect video system-
	ldx #0
	ldy #0
@vwait1:
	bit $2002
	bpl @vwait1  ; at this point, about 27384 cycles have passed
@vwait2:
	inx
	bne @noincy
	iny
@noincy:
	bit $2002
	bpl @vwait2  ; at this point, about 57165 cycles have passed
	cpx #$C0
	bcc :+
		run_pal:
		;routine to run if a pal console is detected:
		lda #$00
		sta $9e
		@palloop:
		lda #$02
		sta $9B
		jsr _tick_pm_op
		sta $4011
		jmp @palloop
	:


; PPU configuration for actual use
	;ldx #%00011110 ;bit 1 controls if there's a column on the left side of the screen
	;stx ppumask_config
	;stx PPUMASK

	;ldx #%10101000
	;stx ppuctrl_config
	;stx PPUCTRL
	
	;jmp _main_entry ; GOTO main loop

_main_entry:
	; The PPU must be disabled before we write to VRAM. This is done during
	; the vertical blanking interval typically, so we do not need to blank
	; the video in the middle of a frame.
	ppu_disable_render ;disable rendering
	lda #$00
	sta PPUCTRL ;disable nmi
	;set y scroll
	lda #$d3
	sta vbl_y_scroll

	; Clear sprites
	jsr _spr_init
	lda #$10
	sta skip_vblank
	jsr _reset_scores
	; Put scroll at 0, 0
	;bit PPUSTATUS
	;lda #$00
	;sta PPUSCROLL ; X scroll
	;sta PPUSCROLL ; Y scroll
	
	;lda #$FE
	;sta $4012

	;load title screen palettes + sprite palettes
	load_palette TITLE_SCREEN_FULL_PALETTE
	;ppu_load_full_palette TITLE_SCREEN_FULL_PALETTE

	lda #$3F
    sta PPUADDR
    lda #$00
    sta PPUADDR
    
	lda #$20
	jsr _ppu_clear_nametable
	lda #$24
	jsr _ppu_clear_nametable

	lda #TITLE_TILE_1
	sta title_tile_1
	;drawing the wibbly title text
	lda #<TITLE_SCREEN_DATA
	sta t2
	lda #>TITLE_SCREEN_DATA
	sta t3
	lda #39
	sta t0
	lda #$20 ;hi ppuaddr
	ldx #$00 ;lo ppuaddr
	jsr _draw_mono_bitmap

	;text attributes
	bit PPUSTATUS
	lda #$27
	sta PPUADDR
	lda #$d8
	sta PPUADDR
	lda #$FF
	ldx #32
	stx t3
	jsr _ppudata_write_x_times
	
	;add some palette writes (just bkg palette)
	;attributes
	lda #<TITLE_PICTURE_ATTRS
	sta t2
	lda #>TITLE_PICTURE_ATTRS
	sta t3
	ldx #$23
	lda #$FF
	jsr _write_menu_attrs

	;title picture (bottom left)
	lda #$02
	sta title_tile_1
	lda #<TITLE_PICTURE_DATA
	sta t2
	lda #>TITLE_PICTURE_DATA
	sta t3
	lda #51
	sta t0
	lda #$21 ;hi ppuaddr
	ldx #$80 ;lo ppuaddr
	jsr _draw_mono_bitmap
	;drawing press start text
	;prerequisites to calling draw_string
	lda #$24
	sta tA+3	;draw a space between each character
	sta PPUCTRL ;write columns
	lda #$25	;load PPU adress where the string will be
	sta string_ppu_pointer
	lda #$c1
	sta string_ppu_pointer+1
	
	lda #<STRINGS ;load pointer to where string data is
	sta tA
	lda #>STRINGS
	sta tA+1
	
	ldy #$00	;choose a string to draw
	jsr _draw_string

	lda #$26
	sta string_ppu_pointer
	lda #$41
	sta string_ppu_pointer+1

	ldy #$06	;choose a string to draw
	jsr _draw_string

	;ldx #$00
	; @loop_random_list:
	;	jsr _generate_rng
	;	sta level_color_buffer, x
	;	dex
	;	bne @loop_random_list

	;jsr _wait_for_vblank
_main:
	; routines i need:
	;✔title screen code
	;✔starting level code
	;✔RNG routine
	;✔controller reading
	;✔movement routines
	;~collision with walls (slows player down)
	;✔scrolling screen w/ variable scroll speed
	; scrolling star sprites
	;✔generating new obstacles
	;✔blood vile gen
	;✔collision with blood vile
	;✔score / high scores
	;✔blood meter
	; SFX
	; music
	;✔dying and death message (show using spr0 split scroll?)
	jmp _title_init


.segment "VECTORS"
	.addr	_nmi_vector	; vblank
	.addr	_reset_vector	; reset
	.addr	_reset_vector	; IRQ


.segment "CHRROM"
	.incbin "resources/vampire.chr"