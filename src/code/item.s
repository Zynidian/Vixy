;_sub_16:
;	sec ;a has hi byte
;	sbc t0 ;t0 has the hi byte being subtracted
;	sta t0 ;t0 contains hi byte result
;	lda t1 ;t1 has lo byte
;	sbc t2 ;t2 has lo byte being subtracted
;	sta t2 ;t2 contains lo byte result
;	rts

_move_items:
	;piggybacking the playfield scroll to find how much the scroll changed
	lda playfield_scroll
	tax
	sec
	sbc playfield_scroll_prev
	stx playfield_scroll_prev
	;playfield_scroll_change now contains the amount to subtract from every x coordinate
	sta playfield_scroll_change
	ldx #$00
@update_each_sprite:
	sec
	lda item_1_x, x ;load a sprite x coordinate
	sbc playfield_scroll_change	;subtract the scroll difference
	sta item_1_x, x
	tay
	;if carry is clear, it went off the side of the screen and wrapped
	bcs :+
		lda despawn_item, x
		ora #$03
		sta despawn_item, x
	:

	lda #$00
	cpy #$f8
	bcc :+
		lda #$02
	:
	eor despawn_item, x
	cmp #$03 ;make sprite always hidden once it despawns
	bcc :+
		lda #$07
		sta despawn_item, x
	:
	sta item_1_crop, x

	;area for checking if the sprite should be hidden offscreen
	inx
	cpx #$03
	bcc @update_each_sprite
	rts

_check_spawn_item:
	;check if it's a level transition (dont spawn walls)
    lda stop_spawning_flag
    beq :+ ;if nonzero, set the current wall to
        rts
    :
	;check if its in the right spot between walls to spawn
	lda wall_column_cycle
	cmp #$03
	beq :+
		lda #$00
		sta already_spawned_item
		@dont_spawn:
		rts
	:
	;if an item has the opportunity to spawn
	;check if it's already spawned an item this $03 wall cycle
	lda already_spawned_item
	bne @dont_spawn 
	inc already_spawned_item
	;test the odds of it spawning
	jsr _generate_rng
	and #ITEM_SPAWN_CHANCE_MASK
	cmp #ITEM_SPAWN_CHANCE_CMP
	bcs @dont_spawn

	;if the item should spawn
	;get random y coordinate
	lda random+1 

	;put it in the range 20-af (random % $90) + $20
	sec
@modulus:
	sbc #$90
	bcs @modulus
	adc #$b0
	and #%11111000
	;store y coord to the appropriate item
	ldx current_item_slot
	sta item_1_y, x
	;storing x coord and sprite cropping mode
	lda #$FF
	sta item_1_x, x
	lda #$02
	sta item_1_crop, x
	;setting it to show on screen
	lda #$00
	sta despawn_item, x
	;incrementing which item slot is being spawned into
	inx
	cpx #$03
	bcc :+
		ldx #$00
	:
	stx current_item_slot
	rts