.SECTION "LFSR Cursor Subclass" APPENDTO "Test Room"
LFSRCursorSubClass:
; ==============================================================
; Constants
; ==============================================================
; Object Data
	.DEF	LFSR_CURSOR_NUM_OBJS				$01					;Number of OBJs entity uses
	.DEF	LFSR_CURSOR_SIZE					$08					;8x8 ($08) or 8x16 ($10)
	.DEF	LFSR_CURSOR_SHAPE					$11					;Shape of our Entity $WidthHeight (Measured in OBJs)

; VRAM Absolute Data
	.DEF	LFSR_CURSOR_VRAM					$8000

; LFSR Constants
	.DEF	NUM_LFSR_CURSOR_POSITIONS			$08
	.DEF	LFSR_CURSOR_DISTANCE				$0F
	.DEF	LFSR_INIT_CURSOR_POS				$00
	.DEF	LFSR_INIT_Y							48 + OBJ_YPOS_OFFSET 
	.DEF	LFSR_INIT_X							38 + OBJ_XPOS_OFFSET

	.DEF	RUN_CURSOR_DISTANCE				$00
	.DEF	RUN_CURSOR_POS						$FF	

	.DEF	RUN_BUTTON_Y						$68		
	.DEF	RUN_BUTTON_X						$58
	



; ==============================================================
;  Handle any action coming to the cursor
; ==============================================================
; 
; Parameters: BC = entity.eventID, aux8BitVar = Controller Input
; Returns: None
; Affects: A???
@ActionHandler:
	push bc
	pop hl										; HL = cursor.eventID

; For START:
	ld a, (aux8BitVar)
	cp STR_BUTTON
	jp z, @Start

; For UP:
	cp DPAD_UP
	jp z, @Up

; For Down:
	cp DPAD_DOWN
	jp z, @Down

	; For B:
	cp B_BUTTON
	jp z, @BButton
	; CPL the bit at cursor's current position (Unless 7)

	; For A:
	cp A_BUTTON
	jp z, @AButton
	; Set or Reset the tap

	ret

@Up:
; Set cursor to RUN Position
	ld bc, cursorStructure.yPos - cursorStructure.eventID
	add hl, bc								;HL =  cursor.yPos
	ld (hl), LFSR_INIT_Y
	ld bc, cursorStructure.xPos - cursorStructure.yPos
	add hl, bc								;HL =  cursor.xPos
	ld (hl), LFSR_INIT_X
; Set so we don't leave it
	ld bc, cursorStructure.currentPosition - cursorStructure.xPos
	add hl, bc								;HL =  cursor.positionDistance
	ld (hl), LFSR_INIT_CURSOR_POS
	inc hl
	ld (hl), LFSR_CURSOR_DISTANCE
	ld bc, cursorStructure.eventID - cursorStructure.positionDistance
	add hl, bc								;HL =  cursor.positionDistance

	ret

@Down:
; HL = cursor.eventID
; Set cursor to RUN Position
	ld bc, cursorStructure.yPos - cursorStructure.eventID
	add hl, bc								;HL =  cursor.yPos
	ld (hl), RUN_BUTTON_Y
	ld bc, cursorStructure.xPos - cursorStructure.yPos
	add hl, bc								;HL =  cursor.xPos
	ld (hl), RUN_BUTTON_X
; Set so we don't leave it
	ld bc, cursorStructure.currentPosition - cursorStructure.xPos
	add hl, bc								;HL =  cursor.positionDistance
	ld (hl), RUN_CURSOR_POS
	inc hl
	ld (hl), RUN_CURSOR_DISTANCE
	ld bc, cursorStructure.eventID - cursorStructure.positionDistance
	add hl, bc								;HL =  cursor.positionDistance

	ret

@BButton:
; Check if we are on RUN or a Bit
	ld bc, cursorStructure.yPos - cursorStructure.eventID
	add hl, bc								; HL =  cursor.yPos
	ld a, (hl)
	ld bc, cursorStructure.eventID - cursorStructure.yPos
	add hl, bc								; HL =  cursor.eventID
	cp RUN_BUTTON_Y
	jr z, @Up
; We are on a BIT, so we shall toggle the TAP
	ld bc, cursorStructure.currentPosition - cursorStructure.eventID
	add hl, bc								; HL =  cursor.currentPosition
	ld a, (hl)								; A = Current Position
	ld bc, cursorStructure.eventID - cursorStructure.currentPosition
	add hl, bc								; HL =  cursor.eventID
	cp $00
	jp z, @Tap0@ToggleBit
	cp $01
	jp z, @Tap1@ToggleBit
	cp $02
	jp z, @Tap2@ToggleBit
	cp $03
	jp z, @Tap3@ToggleBit
	cp $04
	jp z, @Tap4@ToggleBit
	cp $05
	jp z, @Tap5@ToggleBit
	cp $06
	jp z, @Tap6@ToggleBit
	cp $07
	jp z, @Tap7@ToggleBit

	ret

@AButton:
; Check if we are on RUN or a Bit
	ld bc, cursorStructure.yPos - cursorStructure.eventID
	add hl, bc								; HL =  cursor.yPos
	ld a, (hl)
	ld bc, cursorStructure.eventID - cursorStructure.yPos
	add hl, bc								; HL =  cursor.eventID
	cp RUN_BUTTON_Y
	jp z, @Start
; We are on a BIT, so we shall toggle the TAP
	ld bc, cursorStructure.currentPosition - cursorStructure.eventID
	add hl, bc								; HL =  cursor.currentPosition
	ld a, (hl)								; A = Current Position
	ld bc, cursorStructure.eventID - cursorStructure.currentPosition
	add hl, bc								; HL =  cursor.eventID
	cp $00
	jp z, @Tap0@ToggleTap
	cp $01
	jp z, @Tap1@ToggleTap
	cp $02
	jp z, @Tap2@ToggleTap
	cp $03
	jp z, @Tap3@ToggleTap
	cp $04
	jp z, @Tap4@ToggleTap
	cp $05
	jp z, @Tap5@ToggleTap
	cp $06
	jp z, @Tap6@ToggleTap
	cp $07
	jp z, @Tap7@ToggleTap

	ret

@Tap0:

	@@ToggleTap:
		ld a, (tapsBitmap)
		bit 7, a
		jr z, +
		res 7, a
		jr ++
	+:
		set 7, a
	++:
		ld (tapsBitmap), a

		ret

	@@ToggleBit:
		ld a, (currentLFSRValue)
		bit 7, a
		jr z, +
		res 7, a
		jr ++
	+:
		set 7, a
	++:
		ld (currentLFSRValue), a	

	ret

@Tap1:

	@@ToggleTap:
		ld a, (tapsBitmap)
		bit 6, a
		jr z, +
		res 6, a
		jr ++
	+:
		set 6, a
	++:
		ld (tapsBitmap), a

		ret


	@@ToggleBit:
		ld a, (currentLFSRValue)
		bit 6, a
		jr z, +
		res 6, a
		jr ++
	+:
		set 6, a
	++:
		ld (currentLFSRValue), a

	ret

@Tap2:

	@@ToggleTap:
		ld a, (tapsBitmap)
		bit 5, a
		jr z, +
		res 5, a
		jr ++
	+:
		set 5, a
	++:
		ld (tapsBitmap), a

		ret

	@@ToggleBit:
		ld a, (currentLFSRValue)
		bit 5, a
		jr z, +
		res 5, a
		jr ++
	+:
		set 5, a
	++:
		ld (currentLFSRValue), a

	ret

@Tap3:

	@@ToggleTap:
		ld a, (tapsBitmap)
		bit 4, a
		jr z, +
		res 4, a
		jr ++
	+:
		set 4, a
	++:
		ld (tapsBitmap), a
	

	ret

	@@ToggleBit:
		ld a, (currentLFSRValue)
		bit 4, a
		jr z, +
		res 4, a
		jr ++
	+:
		set 4, a
	++:
		ld (currentLFSRValue), a

	ret

@Tap4:

	@@ToggleTap:
		ld a, (tapsBitmap)
		bit 3, a
		jr z, +
		res 3, a
		jr ++
	+:
		set 3, a
	++:
		ld (tapsBitmap), a

	ret

	@@ToggleBit:
		ld a, (currentLFSRValue)
		bit 3, a
		jr z, +
		res 3, a
		jr ++
	+:
		set 3, a
	++:
		ld (currentLFSRValue), a

	ret

@Tap5:

	@@ToggleTap:
		ld a, (tapsBitmap)
		bit 2, a
		jr z, +
		res 2, a
		jr ++
	+:
		set 2, a
	++:
		ld (tapsBitmap), a

	ret

	@@ToggleBit:
		ld a, (currentLFSRValue)
		bit 2, a
		jr z, +
		res 2, a
		jr ++
	+:
		set 2, a
	++:
		ld (currentLFSRValue), a

	ret

@Tap6:

	@@ToggleTap:
		ld a, (tapsBitmap)
		bit 1, a
		jr z, +
		res 1, a
		jr ++
	+:
		set 1, a
	++:
		ld (tapsBitmap), a

	ret

	@@ToggleBit:
		ld a, (currentLFSRValue)
		bit 1, a
		jr z, +
		res 1, a
		jr ++
	+:
		set 1, a
	++:
		ld (currentLFSRValue), a

	ret

@Tap7:

	@@ToggleTap:
		ld a, (tapsBitmap)
		bit 0, a
		jr z, +
		res 0, a
		jr ++
	+:
		set 0, a
	++:
		ld (tapsBitmap), a

	ret

	@@ToggleBit:
		ld a, (currentLFSRValue)
		bit 0, a
		jr z, +
		res 0, a
		jr ++
	+:
		set 0, a
	++:
		ld (currentLFSRValue), a

	ret

@Start:
; HL = cursor.eventID
; Set cursor to RUN Position
	ld bc, cursorStructure.yPos - cursorStructure.eventID
	add hl, bc								;HL =  cursor.yPos
	ld (hl), RUN_BUTTON_Y
	ld bc, cursorStructure.xPos - cursorStructure.yPos
	add hl, bc								;HL =  cursor.xPos
	ld (hl), RUN_BUTTON_X
; Set so we don't leave it
	ld bc, cursorStructure.currentPosition - cursorStructure.xPos
	add hl, bc								;HL =  cursor.positionDistance
	ld (hl), RUN_CURSOR_POS
	inc hl
	ld (hl), RUN_CURSOR_DISTANCE
	ld bc, cursorStructure.eventID - cursorStructure.positionDistance
	add hl, bc								;HL =  cursor.positionDistance
; Set Clicked Color
	ld a, (TestRoomAssets@ObjectsGB@BlackRunObjectPal)
	ld (rOBP1), a
; Run LFSR once
	call LFSRClass@RunOnce

	ret

; Parameters: DE = cursor.eventID, BC = Return Address
@Initialize:
	push de
	pop hl						; HL = cursor.eventID
; Initialize General properties	
	push hl								; Save cursor.eventID
	push bc								; Save Return Address
	; Set timer
		xor a
		ld ($FF00 + lobyte(aux8BitVar)), a
	; Set UpdateEntityPointer
		ld bc, LFSRCursorSubClass@ObjectData
	; Set ObjectDataPointer
		ld de, CursorEntityClass@UpdateCursor
		call GeneralEntityEvents@InitializeEntity
	pop bc								; Recover Return Address
	pop hl								; Recover cursor.eventID
; Set Y Position
	ld de, cursorStructure.yPos - cursorStructure.eventID
	add hl, de							; HL = cursor.yPos
	ld a, LFSR_INIT_Y
	ld (hl), a
; Set X Position
	ld de, cursorStructure.xPos - cursorStructure.yPos
	add hl, de							; HL = cursor.yPos
	ld a, LFSR_INIT_X
	ld (hl), a
; Set Cursor properties
	ld de, cursorStructure.horiVert - cursorStructure.xPos
	add hl, de							; HL = cursor.horiVert
	ld (hl), CURSOR_HORI
	inc hl								; HL = numPositions
	ld (hl), NUM_LFSR_CURSOR_POSITIONS
	inc hl								; HL = currentPosition
	xor a
	ldi (hl), a							; HL = positionDistance
	ld (hl), LFSR_CURSOR_DISTANCE
	inc hl								; HL = animationTimer
	inc hl								; HL = actionHandlerAddressPointer
	ld a, lobyte(LFSRCursorSubClass@ActionHandler)
	ldi (hl), a
	ld a, hibyte(LFSRCursorSubClass@ActionHandler)
	ldi (hl), a
	ld (hl), LFSRCursorSubClass@LookupTable
; Return to default value
	ld de, cursorStructure.eventID - cursorStructure.lookUpTableAddress
	add hl, de	

	push bc
	ret
	pop bc								; Never gets reached, but keeps our push and pop color in check


@LookupTable:
	@@Tap0:
		.DW 	LFSRCursorSubClass@Tap0 
		
@LookupTableEnd:

;==============================================================
; Cursor's Object Data
;==============================================================
;Cursor has 1 states, and it's only one object in size
@ObjectData:
;-------------------
;OAM Handler Data
;-------------------
;How many objects we need to write for this Entity
	.DB		LFSR_CURSOR_NUM_OBJS								;numObjects
;OBJ Size (8x8 or 8x16)
	.DB		LFSR_CURSOR_SIZE 									;sizeOBJ
;Shape of our Entity $WidthHeight (Measured in OBJs)
	.DB		LFSR_CURSOR_SHAPE									;shape
;-------------------
;OAM Data
;-------------------
;Tile ID 1/2
	.DB 	lobyte(LFSR_CURSOR_VRAM >> 4)						;tileID
;Object attribute flags
	.DB 	OAMF_PAL0										;objectAtr

@Tiles:
		@@LFSRCurcor:
			.INCLUDE "..\\assets\\testRoom\\OBJ\\cursorTiles.inc"
		@@LFSRCurcorEnd:

		@@SpriteSheet:
			.INCLUDE "..\\assets\\testRoom\\OBJ\\spriteSheetTiles.inc"

.ENDS