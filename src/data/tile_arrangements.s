.align 16
PLAYER_SPRITE_TILES:
    .byte $20,$22,$00 ;3rd byte is attributes for the sprite
    .byte $24,$22,$00
    .byte $26,$22,$00

ITEM_SPRITE_TILES:
    .byte $2e,$30,$01

WALL_TL:
    .byte $00,$04,$08,$04,$03,$0C
WALL_TR:
    .byte $00,$05,$09,$05,$03,$0D
WALL_BL:
    .byte $00,$06,$04,$04,$03,$0C
WALL_BR:
    .byte $00,$07,$05,$05,$03,$0D

DESIGN_PATTERNS:
    .byte $03,$0a,$0b,$03
    .byte $0a,$02,$02,$0b
    .byte $1f,$0b,$1f,$0b

DESIGN_REFERENCES:
    .byte $00,$04
    .byte $07,$08