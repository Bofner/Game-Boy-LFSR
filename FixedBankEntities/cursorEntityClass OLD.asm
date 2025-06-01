.SECTION "Cursor Class "
CursorEntityClass:
;================================================================================
; All subroutines and data related to the Cursor Entity Class
;================================================================================

;==============================================================
; Constants
;==============================================================
	.DEF 	CURSOR_TITLE_START_Y				$0600 + $0100		;94 = $60.0 + yPos Offset
	.DEF	CURSOR_TITLE_START_X				$0240 + $0080		;40 = $28.0 + xPos Offset
	.DEF	CURSOR_TITLE_NUM_POSITIONS			$03					;numPositions = 3, where we start from 0
	.DEF	CURSOR_TITLE_POSITION_DISTANCE		$10					;positionDistance = $10
	.DEF	CURSOR_MOVE_UP				DPAD_UP
	.DEF	CURSOR_MOVE_DOWN			DPAD_DOWN
	.DEF	CURSOR_DELAY				$0A
	.DEF	CURSOR_ANIMATION_TIME		$0C
	.DEF	CURSOR_MAX_POSITIONS		7
	.DEF	CURSOR_FIRST_POSITION		$00

;Object Data
	.DEF	CURSOR_NUM_OBJS						$01					;Number of OBJs entity uses
	.DEF	CURSOR_SIZE							$08					;8x8 ($08) or 8x16 ($10)
	.DEF	CURSOR_SHAPE						$11					;Shape of our Entity $WidthHeight (Measured in OBJs)
	
;VRAM Absolute Data
	.DEF	CURSOR_GLIDE_VRAM					$8000
	.DEF	CURSOR_FLAP_VRAM					$8010



;==============================================================
; Updates the Entity
;==============================================================
;
;Parameters: DE = entity.state
;Returns: None
;Affects: DE
@UpdateCursor:
;Grab Event ID and State
	push de									;Save entity.eventID
	pop hl									;HL =  entity.eventID

;Check if our timer is counting down
	ld bc, cursorStructure.timer - cursorStructure.eventID
	add hl, bc								;HL =  cursor.timer
	ld a, (hl)
	ld bc, cursorStructure.eventID - cursorStructure.timer
	add hl, bc								;HL =  cursor.eventID
	cp $00
	jr z, @@CheckPlayerDirections
	jp @@UpdateAnimation						;Don't move up if our timer isn't at 0

	@@CheckPlayerDirections:
	;Check Directions
		ld a, (currentKeyPress1)
		and DPAD_DOWN | DPAD_UP 
		cp DPAD_UP
		jp z, @MoveUp
		cp DPAD_DOWN
		jp z, @MoveDown

	@@CheckPlayerButtons:
	;Check buttons
		ld a, (currentKeyPress1)
		and A_BUTTON
		jp nz, @ExecuteCursorSelection

	@@UpdateAnimation:
	;Update the animation frame
		ld bc, cursorStructure.animationTimer - cursorStructure.eventID
		add hl, bc								;HL =  cursor.animationTimer
	;Check if we need to change frames
		xor a
		cp (hl)
		jr nz, +
	;Reset timer
		ld (hl), CURSOR_ANIMATION_TIME
	+:
	;Check if we are halfway done yet
		ld a, CURSOR_ANIMATION_TIME
		srl a
		cp (hl)
		jr c, +
	;Decrement the animation timer
		dec (hl)
		ld bc, cursorStructure.objectDataPointer - cursorStructure.animationTimer
		add hl, bc								;HL =  entity.objectDataPointer
	;Change to frame 0
		ld bc, @ObjectData@Glide
		ld (hl), c
		inc hl
		ld (hl), b
		jr ++
	+:
	;Decrement the animation timer
		dec (hl)
		ld bc, cursorStructure.objectDataPointer - cursorStructure.animationTimer
		add hl, bc								;HL =  entity.objectDataPointer
	;Change to frame 1
		ld bc, @ObjectData@Flap
		ld (hl), c
		inc hl
		ld (hl), b
	++:
		ld bc, cursorStructure.timer - (cursorStructure.objectDataPointer + 1)
		add hl, bc								;HL =  cursor.timer
		xor a
		cp (hl)
		jr z, @@UpdateEntityAndReturn				;If it's 0, then no worries
	;Decrease timer if bigger than zero
		dec (hl)

	@@UpdateEntityAndReturn:
	;Update Entity Position
		ld bc, cursorStructure.eventID - (cursorStructure.timer)
		add hl, bc								;HL = cursor.eventID
		call GeneralEntityEvents@OAMHandler

	ret


;==============================================================
; Moves Cursor Up
;==============================================================
;
;Parameters: HL = entity.eventID
;Returns: None
;Affects: A, BC
@MoveUp:
;Check if we can actually move up
	;HL =  entity.eventID
	ld bc, cursorStructure.currentPosition - cursorStructure.eventID
	add hl, bc								;HL =  cursor.currentPosition
	ldi a, (hl)								;HL =  cursor.positionDistance, A = (currentPosition)
	cp CURSOR_FIRST_POSITION
	jr nz, @@UpdatePosition
;Don't move up if we are at the top
	ld bc, cursorStructure.eventID - cursorStructure.positionDistance
	add hl, bc								;HL =  cursor.timer
	jp CursorEntityClass@UpdateCursor@UpdateAnimation		
;We can move up, so let's do it
	@@UpdatePosition:
	;Grab the distance we need to move our cursor
		ld a, (hld)								;HL =  cursor.currentPosition
		dec (hl)								;Update cursor position by one
	;Update yPos
		ld bc, cursorStructure.yPos - cursorStructure.currentPosition
		add hl, bc								;HL =  cursor.yPos
	;Do a 2's compliment to get a subtraction
		cpl
		inc a
	;Do the subtraction
		add a, (hl)
		ld (hl), a								;yPos updated
	;Set the timer for when we can move again
		ld bc, cursorStructure.timer - cursorStructure.yPos
		add hl, bc								;HL =  cursor.eventID
		ld (hl), CURSOR_DELAY
		ld bc, cursorStructure.eventID - cursorStructure.timer
		add hl, bc								;HL =  cursor.eventID
		jp CursorEntityClass@UpdateCursor@UpdateAnimation

;==============================================================
; Moves Cursor Down
;==============================================================
;
;Parameters: HL = entity.eventID
;Returns: None
;Affects: A, BC
@MoveDown:
;Check if we can actually move down
	;HL =  entity.eventID
	ld bc, cursorStructure.numPositions - cursorStructure.eventID
	add hl, bc								;HL =  cursor.numPositions
	ldi a, (hl)								;HL =  cursor.currentPosition, A = numPosition
	dec a									;Can only do a >= check
	dec a									;First positio is position 0
	cp (hl)
	jr nc, @@UpdatePosition
;Don't move down if we are at the bottom
	ld bc, cursorStructure.eventID - cursorStructure.currentPosition
	add hl, bc								;HL =  cursor.eventID
	jp CursorEntityClass@UpdateCursor@UpdateAnimation		

;We can move down, so let's do it
	@@UpdatePosition:
	;Grab the distance we need to move our cursor
		inc hl									;HL =  cursor.positionDistance
		ld a, (hld)								;HL =  cursor.currentPosition
		inc (hl)								;Update cursor position by one
	;Update yPos
		ld bc, cursorStructure.yPos - cursorStructure.currentPosition
		add hl, bc								;HL =  cursor.yPos
	;Do the addition
		add a, (hl)
		ld (hl), a								;yPos updated
	;Set the timer for when we can move again
		ld bc, cursorStructure.timer - cursorStructure.yPos
		add hl, bc								;HL =  cursor.eventID
		ld (hl), CURSOR_DELAY
		ld bc, cursorStructure.eventID - cursorStructure.timer
		add hl, bc								;HL =  cursor.eventID
		jp CursorEntityClass@UpdateCursor@UpdateAnimation

@ExecuteCursorSelection:
;Grab the currently selected position
	push hl								;Save cursor.eventID
		ld bc, cursorStructure.currentPosition - cursorStructure.eventID
		add hl, bc								;HL =  cursor.currentPosition
		ld a, (hl)								;A = current position
		sla a
;Get to the proper addressPointer
		ld bc, cursorStructure.addressPointer.0 - cursorStructure.currentPosition
		add hl, bc								;HL = cursor.addressPointer.currentPosition
		ld b, $00
		ld c, a
		add hl, bc								;Get to the proper address pointer
		push hl
		pop bc
;Set up our address jump
		ld a, (bc)			
		ld l, a
		inc bc									
		ld a, (bc)	
		ld h, a	
	pop bc								;Recall cursor.eventID
	jp hl


;==============================================================
; Initializes the Entity
;==============================================================
;
;Parameters:  HL = cursor.eventID, init8BitVar0 = numPositions, 
;			  init8BitVar1 = positionDistance, initYPos = yFracPos, initXPos = xFracPos
;			  aux16itVar, ptrA-D are our menu placement addresses
;Parameters:  HL = cursor.eventID, init8BitVar0 = numPositions, 
;Returns: None
;Affects: A, HL
@Initialize:
;Check if activated properly
	ld a, (hl)
	cp ACTIVATE_SUCCESS
	ret nz								;If the entity didn't get added, then we shouldn't initialize it
;Check if we have an acceptable number of positions
	ld a, (init8BitVar0)
	cp CURSOR_MAX_POSITIONS
	ret nc
	push hl								;Save cursor.eventID
	;Initialize General properties				
		;Set timer
		xor a
		ld ($FF00 + lobyte(aux8BitVar)), a
	;Set UpdateEntityPointer
		ld bc, CursorEntityClass@ObjectData
	;Set ObjectDataPointer
		ld de, CursorEntityClass@UpdateCursor
		call GeneralEntityEvents@InitializeEntity
	pop hl								;Recover cursor.eventID
;Set up xPos, yPos, and atkHitbox
	call GeneralEntityEvents@UpdatePosition	
	ld de, cursorStructure.numPositions - cursorStructure.dmgHitbox
	add hl, de							;HL = cursorStructure.numPositions
	ld a, (init8BitVar0)
	ldi (hl), a							;HL = cursorStructure.currentPosition
	ld a, CURSOR_FIRST_POSITION
	ldi (hl), a							;HL = cursorStructure.positionDistance
	ld a, (init8BitVar1)
	ldi (hl), a							;HL = cursorStructure.animationTimer
	ld a, CURSOR_ANIMATION_TIME
	ldi (hl), a							;HL = cursorStructure.addressPointer.0
;Set up pointers
	ld a, (init8BitVar0)				;A = number of positions
	ld b, a								;B = number of positions
	ld de, aux16BitVar					;First address
-:
	ld a, (de)
	ldi (hl), a							;addressPointerHI
	inc de								;ptr16BitHI
	ld a, (de)
	ldi (hl), a							;addressPointerLO.next
	inc de								;ptr16BitLO.next
	dec b
	jr nz, -
	
	ret


;==============================================================
; Cursor's Object Data
;==============================================================
;Cursor has 2 states, but it's only one object in size
@ObjectData:
;First Animation Frame
	@@Glide:
	;-------------------
	;OAM Handler Data
	;-------------------
	;How many objects we need to write for this Entity
		.DB		CURSOR_NUM_OBJS								;numObjects
	;OBJ Size (8x8 or 8x16)
		.DB		CURSOR_SIZE 									;sizeOBJ
	;Shape of our Entity $WidthHeight (Measured in OBJs)
		.DB		CURSOR_SHAPE									;shape
	;-------------------
	;OAM Data
	;-------------------
	;Tile ID 1/2
		.DB 	lobyte(CURSOR_GLIDE_VRAM >> 4)						;tileID
	;Object attribute flags
		.DB 	OAMF_PAL0										;objectAtr
;Second Animation Frame
	@@Flap:
	;-------------------
	;OAM Handler Data
	;-------------------
	;How many objects we need to write for this Entity
		.DB		CURSOR_NUM_OBJS								;numObjects
	;OBJ Size (8x8 or 8x16)
		.DB		CURSOR_SIZE 									;sizeOBJ
	;Shape of our Entity $WidthHeight (Measured in OBJs)
		.DB		CURSOR_SHAPE									;shape
	;-------------------
	;OAM Data
	;-------------------
	;Tile ID 1/2
		.DB 	lobyte(CURSOR_FLAP_VRAM >> 4)						;tileID
	;Object attribute flags
		.DB 	OAMF_PAL0										;objectAtr
@ObjectDataEnd:

@Tiles:
		@@CursorGlide:
			.INCLUDE "..\\assets\\FixedBankEntities\\cursor\\cursorGlideTiles.inc"
		@@CursorGlideEnd:

		@@CursorFlap:
			.INCLUDE "..\\assets\\FixedBankEntities\\cursor\\cursorFlapTiles.inc"
		@@CursorFlapEnd:

.ENDS