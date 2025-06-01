.SECTION "Cursor Class "
CursorEntityClass:
; ================================================================================
;  All subroutines and data related to the Cursor Entity Class
; ================================================================================

; ==============================================================
;  Constants
; ==============================================================
	.DEF	CURSOR_MOVE_UP				DPAD_UP
	.DEF	CURSOR_MOVE_DOWN			DPAD_DOWN
	.DEF	CURSOR_DELAY				$0C
	.DEF	CURSOR_FIRST_POSITION		$00
	.DEF	CURSOR_HORI					$00
	.DEF	CURSOR_VERT					$01

; Object Data
	; .DEF	CURSOR_NUM_OBJS						$01					; Number of OBJs entity uses
	; .DEF	CURSOR_SIZE							$08					; 8x8 ($08) or 8x16 ($10)
	; .DEF	CURSOR_SHAPE						$11					; Shape of our Entity $WidthHeight (Measured in OBJs)
	
; VRAM Absolute Data
	; .DEF	CURSOR_GLIDE_VRAM					$8000
	; .DEF	CURSOR_FLAP_VRAM					$8010



; ==============================================================
;  Updates the Entity
; ==============================================================
; 
; Parameters: DE = entity.eventID
; Returns: None
; Affects: DE
@UpdateCursor:
; Grab Event ID and State
	push de									; Save entity.eventID
	pop hl									; HL =  entity.eventID

; Check if our timer is counting down
	ld bc, cursorStructure.timer - cursorStructure.eventID
	add hl, bc								; HL =  cursor.timer
	ld a, (hl)
	ld bc, cursorStructure.eventID - cursorStructure.timer
	add hl, bc								; HL =  cursor.eventID
	cp $00
	jr nz, @@UpdateEntityAndReturn			; Don't move if our timer isn't at 0

	@@CheckPlayerDirections:
	; Check if a direction is being pressed
		ld a, (currentKeyPress1)
		and ALL_DPAD 
		jr nz, @CheckCursorMovement

	; If no directions, then check for button presses
	@@CheckPlayerButtons:
	; Check buttons
		ld a, (currentKeyPress1)
		and ALL_BUTTONS
		jp nz, @ExecuteCursorSelection	

	@@UpdateEntityAndReturn:
	; Update Timer
		inc hl								; HL = cursor.state
		inc hl								; HL =  cursor.timer
		xor a
		cp (hl)
		jr z, ++							;If it's 0, then no worries
	;Decrease timer if bigger than zero
		dec (hl)
	-:
		dec hl 								; HL =  cursor.state
		dec hl								; HL =  cursor.eventID
		call GeneralEntityEvents@OAMHandler

	ret

	++:
		; Check if we are running CGB or DMG hardware
		ld a, (modelType)
		cp SGB_MODE
		jr z, +++
		ld a, (TestRoomAssets@ObjectsGB@WhiteRunObjectPal)
		ld (rOBP1), a
		jr -

	+++:
		ld a, (TestRoomAssets@ObjectsGB@WhiteRunObjectSGBPal)
		ld (rOBP1), a
		jr -

; ==============================================================
;  Determine Movement
; ==============================================================
; 
; Parameters: HL = entity.eventID
@CheckCursorMovement:
;Save our DPAD input
	ld ($FF00 + lobyte(aux8BitVar)), a		; aux8BitVar = DPAD Input
; Check to see if we are moving Horizontally or Vertically
	ld bc, cursorStructure.horiVert - cursorStructure.eventID
	add hl, bc								; HL =  cursor.horiVert
	ld a, (hl)
; Get back to beginning of cursorEntity
	ld bc, cursorStructure.eventID - cursorStructure.horiVert
	add hl, bc								; HL =  cursor.horiVert
; Run the check for movement
	cp CURSOR_HORI
	jr z, @@CheckHorizontalMovement

;Cursor movement is vertical
	@@CheckVerticalMovement:
	; Check if our DPAD input was a movement input, so U or D
		ld a, ($FF00 + lobyte(aux8BitVar))	; A = DPAD Input
		and DPAD_UP | DPAD_DOWN
	; If not movement, then JP to subclass Action Handler
		jr nz, +
		; UP and DOWN are %1100, LEFT and RIGHT are %0011
		jp CursorEntityClass@ExecuteCursorSelection
	; Set up for executing our movement
	+:
		ld bc, cursorStructure.yPos - cursorStructure.eventID
		add hl, bc								; HL =  cursor.yPos
		push hl
		ld bc, cursorStructure.eventID - cursorStructure.yPos
		add hl, bc								; HL =  cursor.eventID
		pop bc									; BC = cursor.yPos
		jp CursorEntityClass@ExecuteCursorMovement

;Cursor movement is horizontal
	@@CheckHorizontalMovement:
	; Check if our DPAD input was a movement input, so L or R
		ld a, ($FF00 + lobyte(aux8BitVar))	; A = DPAD Input
		cp DPAD_LEFT | DPAD_RIGHT
	; If not movement, then JP to subclass Action Handler
		jr c, +
		; UP and DOWN are %1100, LEFT and RIGHT are %0011
		jp CursorEntityClass@ExecuteCursorSelection
	; Set up for executing our movement
	+:
		ld bc, cursorStructure.xPos - cursorStructure.eventID
		add hl, bc								; HL =  cursor.xPos
		push hl
		ld bc, cursorStructure.eventID - cursorStructure.xPos
		add hl, bc								; HL =  cursor.eventID
		pop bc									; BC = cursor.xPos
		jp CursorEntityClass@ExecuteCursorMovement


; ==============================================================
;  Execute Cursor Movement
; ==============================================================
; 
; Parameters: HL = entity.eventID, BC = cursor.xPos/yPos, A = DPAD_INPUT
; Returns: None
; Affects: A, HL, BC, DE	

@ExecuteCursorMovement:
; Get our position to move
	ld de, cursorStructure.positionDistance - cursorStructure.eventID
	add hl, de									; HL = cursor.positionDistance
	ld d, (hl)									; D = distace
	dec hl										; HL = currentPosition
	dec hl 										; HL =  cursor.numPositions
; Check if we move positive through the list
	and DPAD_DOWN | DPAD_RIGHT
	jr nz, @@MovePositive

	@@MoveNegative:
	;Check if we can actually move negative
		; HL =  entity.numPositions
		inc hl									; HL =  cursor.currentPosition, A = numPosition
		xor a
		cp (hl)									;Check if we are at the 0th position
		jr nz, @@@Subtract
	;Don't move negative if we are at the beginning
		ld bc, cursorStructure.eventID - cursorStructure.currentPosition
		add hl, bc								;HL =  cursor.eventID
		jp CursorEntityClass@UpdateCursor@UpdateEntityAndReturn	
	;We CAN move!
		@@@Subtract:
			dec (hl)
		;Do the subtraction
			ld a, d
			cpl										; \ Do a 2's compliment to get a subtraction			
			inc a									; /
			ld d, a
			ld a, (bc)
			jr @@UpdatePosition

	@@MovePositive:
	;Check if we can actually move positive
		; HL =  entity.numPositions
		ldi a, (hl)								; HL =  cursor.currentPosition, A = numPosition
		dec a									; Can only do a >= check
		dec a									; First position is position 0
		cp (hl)
		jr nc, @@@Add
	;Don't move positive if we are at the end
		ld bc, cursorStructure.eventID - cursorStructure.currentPosition
		add hl, bc								;HL =  cursor.eventID
		jp CursorEntityClass@UpdateCursor@UpdateEntityAndReturn	
	;We CAN move!
		@@@Add:
			inc (hl)
			ld a, (bc)

	@@UpdatePosition:
			add a, d
			ld (bc), a
		;Set the timer for when we can move again
			ld bc, cursorStructure.timer - cursorStructure.currentPosition
			add hl, bc								;HL =  cursor.eventID
			ld (hl), CURSOR_DELAY
			ld bc, cursorStructure.eventID - cursorStructure.timer
			add hl, bc								;HL =  cursor.eventID

		jp CursorEntityClass@UpdateCursor@UpdateEntityAndReturn


; ==============================================================
;  Execute Cursor Selection
; ==============================================================
; 
; Parameters: HL = entity.eventID
; Returns: None
; Affects: A, HL, BC, DE	
@ExecuteCursorSelection:
;Save our Button input
	ld ($FF00 + lobyte(aux8BitVar)), a		; aux8BitVar = Button Input
;Set the timer for when we can do an action again
			ld bc, cursorStructure.timer - cursorStructure.eventID
			add hl, bc								;HL =  cursor.eventID
			ld (hl), CURSOR_DELAY
			ld bc, cursorStructure.eventID - cursorStructure.timer
			add hl, bc								;HL =  cursor.eventID
; Get to the actionHandlerAddressPointer
	push hl								; Save cursor.eventID
		ld bc, cursorStructure.actionHandlerAddressPointer - cursorStructure.eventID
		add hl, bc						; HL = cursor.actionHandlerAddressPointer
		push hl
		pop bc
; Set up our address jump
		ld a, (bc)			
		ld l, a
		inc bc									
		ld a, (bc)	
		ld h, a	
	pop bc								; Recall cursor.eventID
	ld de, CursorEntityClass@UpdateCursor@UpdateEntityAndReturn
	push de								; Set up our RET
	jp hl
	pop de								; Never reached, but keeps our push/pop color in check


; ==============================================================
;  Initializes the Entity
; ==============================================================
; 
; Parameters:  HL = cursor.eventID, DE = SubclassInitAddress
; Returns: None
; Affects: A, HL, BC
@Initialize:
; Check if activated properly
	ld a, (hl)
	cp ACTIVATE_SUCCESS
	ret nz								; If the entity didn't get added, then we shouldn't initialize it
	
	push hl
	push de
	pop hl								; HL = SubclassInitAddress
	pop de								; DE = cursor.eventID
	ld bc, +							; BC = Return address
; Initialize our Cursor to be an Entity (All General and Specific )
	jp hl

; Parameters: DE = cursor.eventID
+:

	ret

.ENDS