;.BANK 0 SLOT 0
.SECTION "Bit Entity Class bitlate"
BitEntityClass:
;================================================================================
; All subroutines and data related to the Bit Class
;================================================================================
;Change the following throughout the entire class
; Bit: 		Captial letter of the entity (Entity)
; BIT:	Constant values (ENTITY)
; bit: 		Lower case letter of the entity (entity)


;==============================================================
; Constants
;==============================================================
;Init Values
	.DEF 	BIT_START_Y				$0600 + $0100		;96 = $60.0 + yPos Offset
	.DEF	BIT_START_X	 			$0280 + $0080		;40 = $28.0 + xPos Offset
	.DEF	BIT_SPEED				$10							;$LSB,FRAC
	.DEF	BIT_TIMER_INIT_VALUE		$00

	.DEF 	BIT_0_Y					$32
	.DEF	BIT_0_X					$2F
	

;Bit OBJ data
	.DEF	BIT_NUM_OBJS				$01
	.DEF	BIT_SIZE					$10
	.DEF	BIT_SHAPE					$11

;VRAM Absolute Data
	.DEF 	BIT_VRAM					$8800

;Attack Hitbox
	.DEF	BIT_ATK_HITBOX_WIDTH		$08		
	.DEF	BIT_ATK_HITBOX_HEIGHT		$10	



;==============================================================
; Updates the Bit
;==============================================================
;
;
;Parameters: DE = bit.eventID (Should be coming from EntityList@UpdateEntities)
;Returns: None
;Affects: DE
@UpdateBit:
	;Grab Event ID 
	push de									;Save entity.eventID
	pop hl									;HL = entity.eventID
	push hl
	; Update the bit to either 1 or 0
		ld bc, bitGraphicStructure.bitPosition - bitGraphicStructure.eventID
		add hl, bc								; HL =  cursor.bitPosition
		ld a, (hl)								; A = bitPosition
		ld b, a
		inc b									; Off by 1 error
		ld a, (currentLFSRValue)
	; Shift the position to check if this bit should be a 0 or a 1
	-:
		rra 									;If carry set, the its a 1
		dec b
		jr nz, -
		jr c, @@SetOne

		@@SetZero:
		; The bit is 0
			ld bc, bitGraphicStructure.objectDataPointer - bitGraphicStructure.bitPosition
			add hl, bc								; HL =  cursor.bitPosition
			ld (hl), lobyte(BitEntityClass@ObjectData@Zero)
			inc hl
			ld (hl), hiByte(BitEntityClass@ObjectData@Zero)

			jr @@SetOAM
		@@SetOne:
		; The bit is 1
			ld bc, bitGraphicStructure.objectDataPointer - bitGraphicStructure.bitPosition
			add hl, bc								; HL =  cursor.bitPosition
			ld (hl), lobyte(BitEntityClass@ObjectData@One)
			inc hl
			ld (hl), hiByte(BitEntityClass@ObjectData@One)


		@@SetOAM:
	pop hl
;Add Entity to the OAM Buffer
	call GeneralEntityEvents@OAMHandler

	
	ret


;==============================================================
; Initializes the Bit
;==============================================================
;
;Parameters: HL = bit.eventID, A = Bit Position (0-7)
;Affects: A, HL, DE
@Initialize:
;Initialize General properties
	push hl
	ld (temp8BitA), a
	;Set yPos
		ld de, initYPosVar
		ld a, hibyte(BIT_START_Y)
		ld (de), a
		inc de
		ld a, lobyte(BIT_START_Y)
		ld (de), a
	;Set xPos
		ld de, initXPosVar
		ld a, hibyte(BIT_START_X)
		ld (de), a
		inc de
		ld a, lobyte(BIT_START_X)
		ld (de), a
	;Set timer
		ld a, BIT_TIMER_INIT_VALUE
		ld (aux8BitVar), a
	;Set ObjectDataPointer
		ld bc, BitEntityClass@ObjectData
	;Set UpdateEntityPointer
		ld de, BitEntityClass@UpdateBit
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
		ld (hl), BIT_ATK_HITBOX_WIDTH
		inc hl									;HL = entity.atkHitbox.height
		ld (hl), BIT_ATK_HITBOX_HEIGHT
		inc hl									;HL = entity.atkHitbox.y1
		sub a, OBJ_YPOS_OFFSET						;Adjust for offset
		ld (hli), a								;HL = entity.atkHitbox.x1
		ld a, b
		sub a, OBJ_XPOS_OFFSET
		ld (hl), a
		ld de, bitGraphicStructure.bitPosition - bitGraphicStructure.atkHitbox.x1
		add hl, de								;HL = bitGraphic.bitPosition
		ld a, (temp8BitA)
		ld (hl), a
	pop hl

		ret


;==============================================================
; Bit's Object Data
;==============================================================
@ObjectData
	@@Zero:
	;-------------------
	;OAM Handler Data
	;-------------------
	;How many objects we need to write for this Entity
		.DB		BIT_NUM_OBJS								;numObjects
	;OBJ Size (8x8 or 8x16)
		.DB		BIT_SIZE 								;sizeOBJ
	;Shape of our Entity $WidthHeight (Measured in OBJs)
		.DB		BIT_SHAPE								;shape
	;-------------------
	;OAM Data
	;-------------------
	;Tile ID 1/1
		.DB 	lobyte(BIT_VRAM >> 4)					;tileID
	;Object attribute flags
		.DB 	OAMF_PAL0										;objectAtr

;-----------------------------------------------------------------------------
	@@One:
	;-------------------
	;OAM Handler Data
	;-------------------
	;How many objects we need to write for this Entity
		.DB		BIT_NUM_OBJS								;numObjects
	;OBJ Size (8x8 or 8x16)
		.DB		BIT_SIZE 								;sizeOBJ
	;Shape of our Entity $WidthHeight (Measured in OBJs)
		.DB		BIT_SHAPE								;shape
	;-------------------
	;OAM Data
	;-------------------
	;Tile ID 1/1
		.DB 	lobyte((BIT_VRAM + $20) >> 4)					;tileID
	;Object attribute flags
		.DB 	OAMF_PAL0										;objectAtr

;-----------------------------------------------------------------------------

@Tiles:
;Just the one set
	@@First:
		;.INCLUDE "..\\assets\\FixedBankEntities\\bit\\bitFirstTiles.inc"
	@@FirstEnd:
	@@Second:
		;.INCLUDE "..\\assets\\FixedBankEntities\\bit\\bitSecondTiles.inc"
	@@SecondEnd:

.ENDS