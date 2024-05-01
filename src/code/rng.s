;
; 6502 LFSR PRNG - 16-bit
; Brad Smith, 2019
; httprainwarrior.ca
;

; A 16-bit Galois LFSR

; Possible feedback values that generate a full 65535 step sequence
; $2D = %00101101
; $39 = %00111001
; $3F = %00111111
; $53 = %01010011
; $BD = %10111101
; $D7 = %11010111

; $39 is chosen for its compact bit pattern

; simplest version iterates the LFSR 8 times to generate 8 random bits
; 133-141 cycles per call
; 19 bytes

_generate_rng:
	ldy #8
	lda random+0
:
	asl        ; shift the register
	rol random+1
	bcc :+
	eor #$39   ; apply XOR feedback whenever a 1 bit is shifted out
:
	dey
	bne :--
	sta random+0
	cmp #0     ; reload flags
	rts
