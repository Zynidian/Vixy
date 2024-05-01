
;these could be compressed/packed if i need space
;then, when a letter is selected, it would decompress and put the six bytes in ram
;just like how these are layed out so that preexisting letter code needs little change
LETTER_TILE_1_COLUMNS:
    ;single wide chrs go here
    .byte $00,$00,$00 ;space    0
    .byte $00,$00,$00 ;i        3
    .byte $0f,$04,$04 ;r        6
    .byte $00,$00,$00 ;
LETTER_TILE_2_COLUMNS:
    ;double wide go here
    .byte $2c,$2b,$2d,$2a,$2b,$2b ;0        12
    .byte $00,$00,$00,$2a,$2b,$2b ;1        18
    .byte $2c,$2c,$2d,$2a,$2b,$2a ;2        24
    .byte $2c,$2c,$2c,$2a,$2b,$2b ;3        30
    .byte $2a,$2d,$00,$2a,$2b,$2b ;4        36
    .byte $2c,$2d,$2c,$2a,$2a,$2b ;5        42
    .byte $2c,$2d,$2d,$2a,$2a,$2b ;6        48
    .byte $2c,$00,$00,$2a,$2b,$2b ;7        54
    .byte $2c,$2d,$2d,$2a,$2b,$2b ;8        60
    .byte $2c,$2d,$2c,$2a,$2b,$2b ;9        66
    ;letters
    .byte $0f,$04,$08,$0f,$05,$09 ;a        72
    .byte $0f,$04,$06,$0f,$07,$0f ;e        78
    .byte $08,$06,$04,$09,$07,$00 ;P        84
    .byte $0f,$06,$0f,$0f,$0f,$07 ;s        90
    .byte $0f,$00,$00,$06,$04,$04 ;t        96
    .byte $08,$1a,$0f,$1a,$09,$07 ;S        102
STRINGS:
    .byte 84,6,78,90,90,$ff ;Press
    .byte 102,96,72,6,96,$ff ;Start

;1 column chrs
;    ilr