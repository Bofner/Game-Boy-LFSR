.RAMSECTION "Bank Switching RAM" BANK 0 SLOT 3 RETURNORG
;Bank Switching
	currentROMBank       		db		;Indicates the ROM bank currently being used
	currentLevelROMBank			db		;Indicates which ROM bank is being used for the level code
	currentSRAMBank       		db		;Indicates the SRAM bank currently being used
	backUpROMBank				db		;Used for checking if we need to switch banks
.ENDS

.SECTION "Bank Switching"
;================================================================================
; All subroutines and data related to bank switching
;================================================================================
;Bank Data
	.DEF	START_SRAM_BANK_SWITCH		$4000
	.DEF	START_ROM_BANK_SWITCH		$2000
	.DEF	TOGGLE_SRAM					$1000
	.DEF	SRAM_ON						$0A
	.DEF	SRAM_OFF					$00
;Banks											Safe memory addresses that correspond to these banks
	.DEF	FIXED_ROM_BANK				$00		;SpaceTonbowInit
	.DEF	SFS_TITLE_ROM_BANK			$01		;SFSInit and TitleInit
	.DEF	TEST_ROOM_BANK				$03		;TestRoomInit

;==============================================================
; Handles ROM Bank Switching
;==============================================================
;
;Parameters: A = Desired bank to switch to
;Returns: None
;Affects: HL
SwitchROMBank:
	ld hl, START_ROM_BANK_SWITCH
	ld (hl), a
	ld hl, currentROMBank
	ld (hl), a

	ret

;==============================================================
; Handles SRAM Bank Switching
;==============================================================
;
;Parameters: A = Desired bank to switch to $00-$03
;Returns: None
;Affects: HL
SwitchSRAMBank:
	ld hl, START_SRAM_BANK_SWITCH
	ld (hl), a
	ld hl, currentSRAMBank
	ld (hl), a

	ret


;==============================================================
; Turns SRAM on or off
;==============================================================
;
;Parameters: A = SRAM_ON or SRAM_OFF
;Returns: None
;Affects: HL
ToggleSRAM:
	ld hl, TOGGLE_SRAM
	ld (hl), a

	ret

.ENDS

;==============================================================
; Debug
;==============================================================
	.DEF	INITIAL_GAME_STATE			SFSInit
	.DEF	INITIAL_STATE_BANK			SFS_TITLE_ROM_BANK

.SECTION "Game State Routines"
;================================================================================
; Routines involving the Game State
;================================================================================
;The location of our Current Game State Address must be placed right after our CALL
;The CALL opcode is $CD NN NN, where NN NN is the address we want, which is 1 byte after $CD
;NOTE, we probably need to take BANK SWITCHING into account for this. 
.DEF	GAME_STATE_HRAM_ADDRESS		HRAM_JumpToCorrectGameState + 1


;Parameters: HL = New Game State Address, nextGameStateBank = Address's bank
;MUST RETURN TO FIXED BANK ($00)
;Returns: None
;Affects: A, C, HL, HRAM
UpdateGameState:
;Check if the new Game State is in the same Bank
	ld a, (currentROMBank)
	ld b, a										;B = Current ROM Bank
	ld a, ($FF00 + lobyte(nextGameStateBank))	;A = New Game State Bank
	cp b
	jr z, @BanksOkay
	push hl
		call SwitchROMBank
	pop hl
@BanksOkay:
;Point to the address in the CALL opcode in HRAM
	ld c, lobyte(GAME_STATE_HRAM_ADDRESS)
	ld a, ($FF00 + lobyte(nextGameState))
	ld ($FF00+c), a
	inc c
	ld a, ($FF00 + hibyte(nextGameState))
	ld ($FF00+c), a
	ld a, KEEP_GAME_STATE_FLAG
	ld ($FF00 + lobyte(changeGameStateFlag)), a

	ret
UpdateGameStateEnd:

;Parameters: None
;Returns: None
;Affects: A, C, HL, HRAM
HoldCurrentGameState:
	ld c, lobyte(GAME_STATE_HRAM_ADDRESS)
	ld a, ($FF00+c)
	ld l, a
	inc c
	ld a, ($FF00+c)
	ld h, a
	ld c, lobyte(holdGameState)
	ld a, l
	ld ($FF00+c), a
	inc c
	ld a, h
	ld ($FF00+c), a

	ret
HoldCurrentGameStateEnd:

;--------------------------------
; Initialization of Game State
;--------------------------------
;Only called once at the beginning of the program
GameStateRoutineToHRAM:
;JP to game state
	ld hl, JumpToCorrectGameStateRoutine
	ld b, JumpToCorrectGameStateRoutineEnd-JumpToCorrectGameStateRoutine
	ld c, lobyte(HRAM_JumpToCorrectGameState)
	call WriteToHRAM
;Hold State
	ld hl, HoldCurrentGameState
	ld b, HoldCurrentGameStateEnd-HoldCurrentGameState
	ld c, lobyte(HRAM_HoldCurrentGameState)
	call WriteToHRAM
;Update Game State
	ld hl, UpdateGameState
	ld b, UpdateGameStateEnd-UpdateGameState
	ld c, lobyte(HRAM_UpdateGameState)
	call WriteToHRAM

	ret

;This is the initial state that our Game State should be in. NOTE: the Game State will change 
JumpToCorrectGameStateRoutine:
	call INITIAL_GAME_STATE
	ret
JumpToCorrectGameStateRoutineEnd:

.ENDS