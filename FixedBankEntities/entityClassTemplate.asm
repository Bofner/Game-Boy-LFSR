;.BANK 0 SLOT 0
.SECTION "何でも Entity Class Template"
何でもEntityClass:
;================================================================================
; All subroutines and data related to the 何でも Class
;================================================================================
;Change the following throughout the entire class
; 何でも: 		Captial letter of the entity (Entity)
; CONST_TEMP:	Constant values (ENTITY)
; temp: 		Lower case letter of the entity (entity)


;==============================================================
; Constants
;==============================================================
;Init Values
	.DEF 	CONST_TEMP_START_Y				$0600 + $0100		;96 = $60.0 + yPos Offset
	.DEF	CONST_TEMP_START_X	 			$0280 + $0080		;40 = $28.0 + xPos Offset
	.DEF	CONST_TEMP_SPEED				$10							;$LSB,FRAC
	.DEF	CONST_TEMP_TIMER_INIT_VALUE		$00

;何でも OBJ data
	.DEF	CONST_TEMP_NUM_OBJS				$01
	.DEF	CONST_TEMP_SIZE					$10
	.DEF	CONST_TEMP_SHAPE				$11

;VRAM Absolute Data
	.DEF 	CONST_TEMP_VRAM					$8000

;Attack Hitbox
	.DEF	CONST_TEMP_ATK_HITBOX_WIDTH		$08		
	.DEF	CONST_TEMP_ATK_HITBOX_HEIGHT	$10	



;==============================================================
; Updates the 何でも
;==============================================================
;
;
;Parameters: DE = temp.eventID (Should be coming from EntityList@UpdateEntities)
;Returns: None
;Affects: DE
@Update何でも:
	;Grab Event ID 
	push de									;Save entity.eventID
	pop hl									;HL = entity.eventID


;Add Entity to the OAM Buffer
	call GeneralEntityEvents@OAMHandler

	
	ret


;==============================================================
; Initializes the 何でも
;==============================================================
;
;Parameters: HL = temp.eventID 
;Affects: A, HL, DE
@Initialize:
;Initialize General properties
	push hl
	;Set yPos
		ld de, initYPosVar
		ld a, hibyte(CONST_TEMP_START_Y)
		ld (de), a
		inc de
		ld a, lobyte(CONST_TEMP_START_Y)
		ld (de), a
	;Set xPos
		ld de, initXPosVar
		ld a, hibyte(CONST_TEMP_START_X)
		ld (de), a
		inc de
		ld a, lobyte(CONST_TEMP_START_X)
		ld (de), a
	;Set timer
		ld a, CONST_TEMP_TIMER_INIT_VALUE
		ld (aux8BitVar), a
	;Set ObjectDataPointer
		ld bc, 何でもEntityClass@ObjectData
	;Set UpdateEntityPointer
		ld de, 何でもEntityClass@Update何でも
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
		ld (hl), CONST_TEMP_ATK_HITBOX_WIDTH
		inc hl									;HL = entity.atkHitbox.height
		ld (hl), CONST_TEMP_ATK_HITBOX_HEIGHT
		inc hl									;HL = entity.atkHitbox.y1
		sub a, OBJ_YPOS_OFFSET						;Adjust for offset
		ld (hli), a								;HL = entity.atkHitbox.x1
		ld a, b
		sub a, OBJ_XPOS_OFFSET
		ld (hl), a
	pop hl

		ret


;==============================================================
; 何でも's Object Data
;==============================================================
@ObjectData
	@@First:
	;-------------------
	;OAM Handler Data
	;-------------------
	;How many objects we need to write for this Entity
		.DB		CONST_TEMP_NUM_OBJS								;numObjects
	;OBJ Size (8x8 or 8x16)
		.DB		CONST_TEMP_SIZE 								;sizeOBJ
	;Shape of our Entity $WidthHeight (Measured in OBJs)
		.DB		CONST_TEMP_SHAPE								;shape
	;-------------------
	;OAM Data
	;-------------------
	;Tile ID 1/2
		.DB 	lobyte(CONST_TEMP_VRAM >> 4)					;tileID
	;Object attribute flags
		.DB 	OAMF_PAL0										;objectAtr
	;----
	;Tile ID 2/2
		.DB 	lobyte((CONST_TEMP_VRAM + $20) >> 4)			;tileID
	;Object attribute flags
		.DB 	OAMF_PAL0										;objectAtr
;-----------------------------------------------------------------------------
	@@Second:
	;-------------------
	;OAM Handler Data
	;-------------------
	;How many objects we need to write for this Entity
		.DB		CONST_TEMP_NUM_OBJS								;numObjects
	;OBJ Size (8x8 or 8x16)
		.DB		CONST_TEMP_SIZE 								;sizeOBJ
	;Shape of our Entity $WidthHeight (Measured in OBJs)
		.DB		CONST_TEMP_SHAPE								;shape
	;-------------------
	;OAM Data
	;-------------------
	;Tile ID 1/2
		.DB 	lobyte(CONST_TEMP_VRAM >> 4)					;tileID
	;Object attribute flags
		.DB 	OAMF_PAL0										;objectAtr
	;----
	;Tile ID 2/2
		.DB 	lobyte((CONST_TEMP_VRAM + $20) >> 4)			;tileID
	;Object attribute flags
		.DB 	OAMF_PAL0										;objectAtr

;-----------------------------------------------------------------------------

@Tiles:
;Just the one set
	@@First:
		;.INCLUDE "..\\assets\\FixedBankEntities\\temp\\tempFirstTiles.inc"
	@@FirstEnd:
	@@Second:
		;.INCLUDE "..\\assets\\FixedBankEntities\\temp\\tempSecondTiles.inc"
	@@SecondEnd:

.ENDS