;.BANK 0 SLOT 0
.SECTION "Output Entity Class outputlate"
OutputEntityClass:
;================================================================================
; All subroutines and data related to the Output Class
;================================================================================
;Change the following throughout the entire class
; Output: 		Captial letter of the entity (Entity)
; OUTPUT:	Constant values (ENTITY)
; output: 		Lower case letter of the entity (entity)


;==============================================================
; Constants
;==============================================================
;Init Values
	.DEF 	OUTPUT_START_Y				$0600 + $0100		;96 = $60.0 + yPos Offset
	.DEF	OUTPUT_START_X	 			$0280 + $0080		;40 = $28.0 + xPos Offset
	.DEF	OUTPUT_SPEED				$10							;$LSB,FRAC
	.DEF	OUTPUT_TIMER_INIT_VALUE		$00

;Output OBJ data
	.DEF	OUTPUT_NUM_OBJS				$03
	.DEF	OUTPUT_SIZE					$10
	.DEF	OUTPUT_SHAPE				$31

;VRAM Absolute Data
	.DEF 	OUTPUT_VRAM					$8800

;Attack Hitbox
	.DEF	OUTPUT_ATK_HITBOX_WIDTH		$08		
	.DEF	OUTPUT_ATK_HITBOX_HEIGHT	$10	

; Object DATA
	.DEF	OUTPUT_OBJECT_DATA			$D000
	.DEF	OUTPUT_OBJECT_TILE_DATA		$D003
	.DEF	ZERO_GRAPHIC				$80
	.DEF	OUTPUT_Y					122 + 16
	.DEF	OUTPUT_X					64 + 8



;==============================================================
; Updates the Output
;==============================================================
;
;
;Parameters: DE = output.eventID (Should be coming from EntityList@UpdateEntities)
;Returns: None
;Affects: DE
@UpdateOutput:
	;Grab Event ID 
	push de									;Save entity.eventID
	pop hl									;HL = entity.eventID

; Convert our value into BCD
	ld a, (currentLFSRValue)
	ld c, a									; C = currentLFSR value
	xor a
; 1
	rrc c
	jr nc, +
	add a, $1
+:
; 2
	rrc c
	jr nc, +
	add a, $2
	daa
+:
; 4
	rrc c
	jr nc, +
	add a, $4
	daa
+:
; 8
	rrc c
	jr nc, +
	add a, $8
	daa
+:
; 16
	rrc c
	jr nc, +
	add a, $16
	daa
+:
; 32
	rrc c
	jr nc, +
	add a, $32
	daa
+:
; Save our first byte
	ld b, a					; B < 64
	xor a
; 64
	rrc c
	jr nc, +
	add a, $64
	daa
+:
	ld de, $00
	rrc c
	jr nc, +
	ld de, $0128
+:
	add a, e
	daa
	jr nc, +
	inc d
+:
	add a, b
	daa
	jr nc, +
	inc d
+:
	ld e, a					; DE = BCD Output
	push hl
		ld bc, entityStructure.state - entityStructure.eventID
		add hl, bc							; HL = output.state
		ld a, d
		ldi (hl), a
		ld a, e
		ld (hl), a
	; Update Output's object data
	; Hundreds
		ld a, d
		sla a								; A x 2
		add a, ZERO_GRAPHIC
		cp ZERO_GRAPHIC
		jr nz, +
		ld b, a
		sub a, $02
	+:
		ld hl, OUTPUT_OBJECT_TILE_DATA
		ldi (hl), a							; Hundreds data set
		ld a, OAMF_PAL0
		ldi (hl), a
	; Tens
	++:
		ld a, e
		and %11110000
		swap a								; A = Tens value
		sla a								; A x 2
		add a, ZERO_GRAPHIC
		cp ZERO_GRAPHIC
		jr nz, +
		cp b								; Check if Hundreds was also Zero
		jr nz, +
		sub a, $02
	+:
		ldi (hl), a							; Tens data set
		ld a, OAMF_PAL0
		ldi (hl), a
	; Ones
		ld a, e
		and %00001111						; A = Ones value
		sla a								; A x 2
		add a, ZERO_GRAPHIC
		ldi (hl), a							; Ones data set
		ld a, OAMF_PAL0
		ldi (hl), a

	pop hl
;Add Entity to the OAM Buffer
	call GeneralEntityEvents@OAMHandler

	
	ret


;==============================================================
; Initializes the Output
;==============================================================
;
;Parameters: HL = output.eventID 
;Affects: A, HL, DE
@Initialize:
;Initialize General properties
	push hl
	;Set yPos
		ld de, initYPosVar
		ld a, hibyte(OUTPUT_START_Y)
		ld (de), a
		inc de
		ld a, lobyte(OUTPUT_START_Y)
		ld (de), a
	;Set xPos
		ld de, initXPosVar
		ld a, hibyte(OUTPUT_START_X)
		ld (de), a
		inc de
		ld a, lobyte(OUTPUT_START_X)
		ld (de), a
	;Set timer
		ld a, OUTPUT_TIMER_INIT_VALUE
		ld (aux8BitVar), a
	;Set ObjectDataPointer
		ld bc, OUTPUT_OBJECT_DATA
	;Set UpdateEntityPointer
		ld de, OutputEntityClass@UpdateOutput
		call GeneralEntityEvents@InitializeEntity
	pop hl
	push hl
	;Set up xPos, yPos, and atkHitbox
		call GeneralEntityEvents@UpdatePosition	
		ld (hl), $00							;entity.atkHitbox.columnsBitmap = $00
		;HL = atkHitbox
		dec hl									;HL = entity.xPos
		ld b, (hl)
		ld de, entityStructure.yPos - entityStructure.xPos
		add hl, de								;HL = entity.yPos
		ld a, (hl)
		ld de, entityStructure.atkHitbox.width - entityStructure.yPos
		add hl, de								;HL = entity.atkHitbox.width
		ld (hl), OUTPUT_ATK_HITBOX_WIDTH
		inc hl									;HL = entity.atkHitbox.height
		ld (hl), OUTPUT_ATK_HITBOX_HEIGHT
		inc hl									;HL = entity.atkHitbox.y1
		sub a, OBJ_YPOS_OFFSET						;Adjust for offset
		ld (hli), a								;HL = entity.atkHitbox.x1
		ld a, b
		sub a, OBJ_XPOS_OFFSET
		ld (hl), a
	; Object Data
		ld hl, OUTPUT_OBJECT_DATA
		ld (hl), OUTPUT_NUM_OBJS
		inc hl
		ld (hl), OUTPUT_SIZE
		inc hl
		ld (hl), OUTPUT_SHAPE
	pop hl
		

		ret


;==============================================================
; Output's Object Data
;==============================================================
@ObjectData
	@@First:
	;-------------------
	;OAM Handler Data
	;-------------------
	;How many objects we need to write for this Entity
		.DB		OUTPUT_NUM_OBJS								;numObjects
	;OBJ Size (8x8 or 8x16)
		.DB		OUTPUT_SIZE 								;sizeOBJ
	;Shape of our Entity $WidthHeight (Measured in OBJs)
		.DB		OUTPUT_SHAPE								;shape
	;-------------------
	;OAM Data
	;-------------------
	;Tile ID 1/2
		.DB 	lobyte(OUTPUT_VRAM >> 4)					;tileID
	;Object attribute flags
		.DB 	OAMF_PAL0										;objectAtr
	;----
	;Tile ID 2/2
		.DB 	lobyte((OUTPUT_VRAM + $20) >> 4)			;tileID
	;Object attribute flags
		.DB 	OAMF_PAL0										;objectAtr
;-----------------------------------------------------------------------------
	@@Second:
	;-------------------
	;OAM Handler Data
	;-------------------
	;How many objects we need to write for this Entity
		.DB		OUTPUT_NUM_OBJS								;numObjects
	;OBJ Size (8x8 or 8x16)
		.DB		OUTPUT_SIZE 								;sizeOBJ
	;Shape of our Entity $WidthHeight (Measured in OBJs)
		.DB		OUTPUT_SHAPE								;shape
	;-------------------
	;OAM Data
	;-------------------
	;Tile ID 1/2
		.DB 	lobyte(OUTPUT_VRAM >> 4)					;tileID
	;Object attribute flags
		.DB 	OAMF_PAL0										;objectAtr
	;----
	;Tile ID 2/2
		.DB 	lobyte((OUTPUT_VRAM + $20) >> 4)			;tileID
	;Object attribute flags
		.DB 	OAMF_PAL0										;objectAtr

;-----------------------------------------------------------------------------

@Tiles:
;Just the one set
	@@First:
		;.INCLUDE "..\\assets\\FixedBankEntities\\output\\outputFirstTiles.inc"
	@@FirstEnd:
	@@Second:
		;.INCLUDE "..\\assets\\FixedBankEntities\\output\\outputSecondTiles.inc"
	@@SecondEnd:

.ENDS