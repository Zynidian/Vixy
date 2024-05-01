;needs to include a routine for drawing one letter
;called by a routine that loops through a string of text
;positioning the text once before the loop, then just feeding letters to the routine

;pressing select 3 times on title screen brings you to credit screen
;holding A for 5 seconds, then pressing start will bring you to the seecret screen (w/ sound test)

_draw_single_text_chr: ;876 during vblank
    ;A contains what character to draw
    ;see if A is a 1 or 2 wide character
    tax ;current letter is copied to y  ;2
    ;if zero, draw just a space
    beq @draw_space                     ;2++ ;drawing space takes 78+6 for jsr
    cmp #(LETTER_TILE_2_COLUMNS-LETTER_TILE_1_COLUMNS) ;2
    ;if less than, draw only one column
    bcc @draw_one_column                ;2++ ;dont use 1 column when during vblank
    ;else draw 2 columns
        jsr _draw_single_text_column   ;65
    @draw_one_column:
        jsr _draw_single_text_column   ;65
        lda tA+3                        ;3
        bne @draw_space                 ;2++ 3 ;always draw space after each character when during vblank
        rts                             ;6
    @draw_space:
        ldx #0                          ;2
        jsr _draw_single_text_column   ;65
        rts                             ;6

_draw_single_text_column: ;59 cycles
    bit PPUSTATUS ;4
    lda string_ppu_pointer      ;3 ;where to draw the column 
    sta PPUADDR ;4
    lda string_ppu_pointer+1      ;3
    sta PPUADDR ;4
    ;draw 3 tiles
    lda LETTER_TILE_1_COLUMNS, x ;4
    sta PPUDATA                  ;4
    inx                          ;2
    lda LETTER_TILE_1_COLUMNS, x ;4
    sta PPUDATA                  ;4
    inx                          ;2
    lda LETTER_TILE_1_COLUMNS, x ;4
    sta PPUDATA                  ;4
    inx                          ;2

    inc string_ppu_pointer+1 ;5 ;move the pointer to the next column for the next call
    rts    ;6


_draw_string:
    ;x contains offset into string list (selects string)
    ;PPUCTRL is already on write columns
    ;string_ppu_pointer contains the hi and lo bytes of PPUADDR resp.
    @loop:
        ;get a character id from the string
        lda (tA), Y
        ;check if the string terminates
        cmp #$FF
        beq @exit
        ;draw it to the screen
        jsr _draw_single_text_chr
        ;get the next character
        iny
        bne @loop
    @exit:
    rts

_draw_string_vblank:
    ldy vblank_character_index
    lda (tA), Y
    sta vblank_character_to_write
    inc vblank_character_index
    rts

_format_gameover_score:
    ;loops 6 times
    ldx #0
    @loop:
        lda score_buffer+17, x ;get a digit from score
        and #%00001111  ;make the number 0-9
        ;multiply number by 6 to get offset into letter table
        clc
        sta t2  ;n
        asl     ;2n
        adc t2  ;2n+n = 3n
        asl     ;3n*2 = 6n
        ;add constant to get the index into the letter table
        adc #(LETTER_TILE_2_COLUMNS-LETTER_TILE_1_COLUMNS)
        sta score_number_string, x ;store chr into the score string
        
        ;loop condition check
        inx
        cpx #$06
        bcc @loop ;loop if less than 6
    rts
