WALL_PATTERNS_LO:
    .byte %00000000
    .byte %10000100
    .byte %00111000
    .byte %00001100
    .byte %11100000
    .byte %00100000
    .byte %11000000
    .byte %11110000
    .byte %11000000
    .byte %00111100
    .byte %00001000
    .byte %00011100
    .byte %00000100
    .byte %10000000
    .byte %11110000
    .byte %11111100

;wall patterns are arranged:
; LO       HI
; 12345600 789A0000
; \____/   \__/
;   wall data

WALL_PATTERNS_HI:
    .byte %00000000
    .byte %11110000
    .byte %00000000
    .byte %10000000
    .byte %10000000
    .byte %11110000
    .byte %11110000
    .byte %00110000
    .byte %00110000
    .byte %10000000
    .byte %00000000
    .byte %11110000
    .byte %11110000
    .byte %01110000
    .byte %00000000
    .byte %00000000
