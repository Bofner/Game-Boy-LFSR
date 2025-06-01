.SECTION "HRAM Routines"
;================================================================================
; Anything to do with HRAM
;================================================================================
;DMA Constants
	.DEF	HRAM						$FF80
	.DEF	CHANGE_GAME_STATE_FLAG		$FF
	.DEF	KEEP_GAME_STATE_FLAG		$00

;Parameters: HL = Start address, B = length of write, C = HRAM Address to write to (c, lobyte(ADDRESS))
WriteToHRAM:
	@Copy:
		ld a, (hli)
		ld ($FF00+c), a
		inc c
		dec b
		jr nz, @Copy
		;end
	ret

.ENDS

.SECTION "DMA Transfer"
DMAToHRAM:
	ld hl, DMATransferRoutine
	ld b, DMATransferRoutineEnd-DMATransferRoutine
	ld c, lobyte(HRAM_RunDMATransfer)
	call WriteToHRAM

	ret

;Parameters: A = HIGH BYTE of source address
DMATransferRoutine:
    ld (rDMA), a  ; start DMA transfer (starts right after instruction)
    ld a, 40        ; delay for a total of 4×40 = 160 M-cycles
-:
	dec a           ; 1 M-cycle
	jr nz, -    ; 3 M-cycles
    ret
DMATransferRoutineEnd:

.ENDS


;.RAMSECTION "HRAM" BANK 0 SLOT 4 ORGA HRAM RETURNORG FORCE
.ENUM	HRAM	EXPORT
;The DMA Transfer Routine
	HRAM_RunDMATransfer				dsb 	DMATransferRoutineEnd-DMATransferRoutine
;Game State Routine
	HRAM_JumpToCorrectGameState		dsb		JumpToCorrectGameStateRoutineEnd-JumpToCorrectGameStateRoutine
	HRAM_HoldCurrentGameState		dsb		HoldCurrentGameStateEnd-HoldCurrentGameState
	HRAM_UpdateGameState			dsb		UpdateGameStateEnd-UpdateGameState
	
;Game States Data
	holdGameState					dw		;Game State Held for Fades or some other future reason
	changeGameStateFlag				db		;Check if we want to change the game state
	nextGameState					dw		;The Game State we want to switch to
	nextGameStateBank				db		;The bank data for the next game state

;Hardware version
	modelType						db		;Are we running on DMG ($00), SGB ($01), or CGB ($02)

;Player Data
	playerOneEntityPointer			dw		;Pointer to the Player One entity
	playerTwoEntityPointer			dw		;Pointer to the Player Two entity
	playerThreeEntityPointer		dw		;Pointer to the Player Three entity
	playerFourEntityPointer			dw		;Pointer to the Player Four entity
	
;8-Bit Variables
	aux8BitVar        				db		;Used for any kind of 8-bit variable we need
	temp8BitA						db		;Temporary 8-bit Data Storage
	temp8BitB						db		;Temporary 8-bit Data Storage
	temp8BitC						db		;Temporary 8-bit Data Storage
	temp8BitD						db		;Temporary 8-bit Data Storage
	temp8BitE						db		;Temporary 8-bit Data Storage
	temp8BitF						db		;Temporary 8-bit Data Storage

;16-Bit Variables
	aux16BitVar        				dw		;Used for any kind of 16-bit variable we need
	ptrA16Bit 						dw		;Used to point to a 16 bit address
	ptrB16Bit 						dw		;Used to point to a 16 bit address
	ptrC16Bit 						dw		;Used to point to a 16 bit address
	ptrD16Bit 						dw		;Used to point to a 16 bit address
	ptrE16Bit 						dw		;Used to point to a 16 bit address
	ptrF16Bit 						dw		;Used to point to a 16 bit address
	
.ENDE
;.ENDS

;Player Constants
	.DEF	playerOneEntityPointerLO	lobyte(playerOneEntityPointer)
	.DEF	playerOneEntityPointerHI	lobyte(playerOneEntityPointer + 1)	
	.DEF	PLAYER_ONE_ENTITY			$01
	.DEF	PLAYER_TWO_ENTITY			$02
	.DEF	PLAYER_THREE_ENTITY			$03
	.DEF	PLAYER_FOUR_ENTITY			$04

;Variable constants
	.DEF	aux16BitVarLO				lobyte(aux16BitVar)
	.DEF	aux16BitVarHI				lobyte(aux16BitVar + 1)
	.DEF	ptrA16BitLO					lobyte(ptrA16Bit)
	.DEF	ptrA16BitHI					lobyte(ptrA16Bit + 1)
	.DEF	ptrB16BitLO					lobyte(ptrB16Bit)
	.DEF	ptrB16BitHI					lobyte(ptrB16Bit + 1)
	.DEF	ptrC16BitLO					lobyte(ptrC16Bit)
	.DEF	ptrC16BitHI					lobyte(ptrC16Bit + 1)
	.DEF	ptrD16BitLO					lobyte(ptrD16Bit)
	.DEF	ptrD16BitHI					lobyte(ptrD16Bit + 1)
	.DEF	ptrE16BitLO					lobyte(ptrE16Bit)
	.DEF	ptrE16BitHI					lobyte(ptrE16Bit + 1)
	.DEF	ptrF16BitLO					lobyte(ptrF16Bit)
	.DEF	ptrF16BitHI					lobyte(ptrF16Bit + 1)
