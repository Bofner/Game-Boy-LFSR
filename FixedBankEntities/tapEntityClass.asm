;.BANK 0 SLOT 0
.SECTION "Tap Entity Class"
TapEntityClass:
;================================================================================
; All subroutines and data related to the Tap Class
;================================================================================
;Change the following throughout the entire class
; Tap: 		Captial letter of the entity (Entity)
; TAP:	Constant values (ENTITY)
; tap: 		Lower case letter of the entity (entity)


;==============================================================
; Constants
;==============================================================
;Init Values
	.DEF 	TAP_START_Y				$0600 + $0100		;96 = $60.0 + yPos Offset
	.DEF	TAP_START_X	 			$0280 + $0080		;40 = $28.0 + xPos Offset
	.DEF	TAP_SPEED				$10							;$LSB,FRAC
	.DEF	TAP_TIMER_INIT_VALUE		$00

;Tap OBJ data
	.DEF	TAP_NUM_OBJS				$01
	.DEF	TAP_SIZE					$10
	.DEF	TAP_SHAPE				$11

;VRAM Absolute Data
	.DEF 	TAP_VRAM					$8400

;Attack Hitbox
	.DEF	TAP_ATK_HITBOX_WIDTH		$08		
	.DEF	TAP_ATK_HITBOX_HEIGHT	$10	

; TAP Positioning
	.DEF	TAP_0_Y					$20
	.DEF	TAP_0_X					$2E



;==============================================================
; Updates the Tap
;==============================================================
;
;
;Parameters: DE = tap.eventID (Should be coming from EntityList@UpdateEntities)
;Returns: None
;Affects: DE
@UpdateTap:
	;Grab Event ID 
	push de									;Save entity.eventID
	pop hl									;HL = entity.eventID
	push hl
	; Update the tap to either on or off
		ld bc, tapGraphicStructure.tapPosition - tapGraphicStructure.eventID
		add hl, bc								; HL =  cursor.bitPosition
		ld a, (hl)								; A = bitPosition
		ld b, a
		inc b									; Off by 1 error
		ld a, (tapsBitmap)
	; Shift the position to check if this bit should be a 0 or a 1
	-:
		rra 									;If carry set, the its a 1
		dec b
		jr nz, -
		jr c, @@TapOn

		@@TapOff:
		; The bit is 0
			ld bc, tapGraphicStructure.yPos - tapGraphicStructure.tapPosition
			add hl, bc								; HL =  cursor.bitPosition
			ld (hl), Y_OFFSCREEN

			jr @@SetOAM
		@@TapOn:
		; The bit is 1
			ld bc, tapGraphicStructure.yPos - tapGraphicStructure.tapPosition
			add hl, bc								; HL =  cursor.bitPosition
			ld (hl), TAP_0_Y



		@@SetOAM:
	pop hl
;Add Entity to the OAM Buffer
	call GeneralEntityEvents@OAMHandler

	
	ret


;==============================================================
; Initializes the Tap
;==============================================================
;
;Parameters: HL = tap.eventID 
;Affects: A, HL, DE
@Initialize:
;Initialize General properties
	push hl
	ld (temp8BitA), a
	;Set yPos
		ld de, initYPosVar
		ld a, hibyte(TAP_START_Y)
		ld (de), a
		inc de
		ld a, lobyte(TAP_START_Y)
		ld (de), a
	;Set xPos
		ld de, initXPosVar
		ld a, hibyte(TAP_START_X)
		ld (de), a
		inc de
		ld a, lobyte(TAP_START_X)
		ld (de), a
	;Set timer
		ld a, TAP_TIMER_INIT_VALUE
		ld (aux8BitVar), a
	;Set ObjectDataPointer
		ld bc, TapEntityClass@ObjectData
	;Set UpdateEntityPointer
		ld de, TapEntityClass@UpdateTap
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
		ld (hl), TAP_ATK_HITBOX_WIDTH
		inc hl									;HL = entity.atkHitbox.height
		ld (hl), TAP_ATK_HITBOX_HEIGHT
		inc hl									;HL = entity.atkHitbox.y1
		sub a, OBJ_YPOS_OFFSET						;Adjust for offset
		ld (hli), a								;HL = entity.atkHitbox.x1
		ld a, b
		sub a, OBJ_XPOS_OFFSET
		ld (hl), a
		ld de, tapGraphicStructure.tapPosition - tapGraphicStructure.atkHitbox.x1
		add hl, de								;HL = tapGraphic.tapPosition
		ld a, (temp8BitA)
		ld (hl), a
	pop hl

		ret


;==============================================================
; Tap's Object Data
;==============================================================
@ObjectData
	@@First:
	;-------------------
	;OAM Handler Data
	;-------------------
	;How many objects we need to write for this Entity
		.DB		TAP_NUM_OBJS								;numObjects
	;OBJ Size (8x8 or 8x16)
		.DB		TAP_SIZE 								;sizeOBJ
	;Shape of our Entity $WidthHeight (Measured in OBJs)
		.DB		TAP_SHAPE								;shape
	;-------------------
	;OAM Data
	;-------------------
	;Tile ID 1/2
		.DB 	lobyte(TAP_VRAM >> 4)					;tileID
	;Object attribute flags
		.DB 	OAMF_PAL0										;objectAtr
	;----
	;Tile ID 2/2
		.DB 	lobyte((TAP_VRAM + $20) >> 4)			;tileID
	;Object attribute flags
		.DB 	OAMF_PAL0										;objectAtr
;-----------------------------------------------------------------------------
	@@Second:
	;-------------------
	;OAM Handler Data
	;-------------------
	;How many objects we need to write for this Entity
		.DB		TAP_NUM_OBJS								;numObjects
	;OBJ Size (8x8 or 8x16)
		.DB		TAP_SIZE 								;sizeOBJ
	;Shape of our Entity $WidthHeight (Measured in OBJs)
		.DB		TAP_SHAPE								;shape
	;-------------------
	;OAM Data
	;-------------------
	;Tile ID 1/2
		.DB 	lobyte(TAP_VRAM >> 4)					;tileID
	;Object attribute flags
		.DB 	OAMF_PAL0										;objectAtr
	;----
	;Tile ID 2/2
		.DB 	lobyte((TAP_VRAM + $20) >> 4)			;tileID
	;Object attribute flags
		.DB 	OAMF_PAL0										;objectAtr

;-----------------------------------------------------------------------------

@Tiles:
;Just the one set
	.INCLUDE "..\\assets\\TestRoom\\OBJ\\tapTiles.inc"
	

.ENDS