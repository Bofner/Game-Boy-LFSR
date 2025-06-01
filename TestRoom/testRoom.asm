.BANK 3 SLOT 1
.ORG $0000
.SECTION "Test Room"
TestRoomInit:
; ==============================================================
;  Constants
; ==============================================================
	.DEF	TESTROOM_KAIKURO_OPEN_VRAM_ABS		TONBOW_DIAG_DASH_VRAM_ABS + $40	
	.DEF	TESTROOM_KAIKURO_CLOSE_VRAM_ABS		TESTROOM_KAIKURO_OPEN_VRAM_ABS + $20

	.DEF	NUMBERS_VRAM						$8800

; ==============================================================
;  Initialize level's ROM Bank
; ==============================================================
	ld hl, currentLevelROMBank
	ld a, TEST_ROOM_BANK
	ld (hl), a
; ==============================================================
;  Initialize BG Scrolling
; ==============================================================
; We're gonna set everything to zero since there's no movement on Splash Screen
	xor a
	ld hl, stdScreenScroll.yVel		
	ld (hli), a											; ld hl, stdScreenScroll.yFracPos
	ld (hli), a											; ld hl, stdScreenScroll.yPos
	ld (hli), a											; ld hl, stdScreenScroll.xVel
	ld (hli), a											; ld hl, stdScreenScroll.xFracPos
	ld (hli), a											; ld hl, stdScreenScroll.xPos
	
; ==============================================================
;  Initialize Variables
; ==============================================================
TestRoomBackgroundAssets:
; Start by turning off the screen
	call ScreenOff
	@GameBoy:
	; -----------------------------------------
	;  GB Background tiles
	; -----------------------------------------
	; Title Tiles
		ld de, TestRoomAssets@BackgroundGB@Tiles
		ld hl, TILE_VRAM_9000
		call TileAndMapHandler
	; -----------------------------------------
	;  GB Background Map
	; -----------------------------------------
	; Title Map
		ld de, TestRoomAssets@BackgroundGB@Map
		ld hl, MAP_VRAM_9800
		call TileAndMapHandler

	; -----------------------------------------
	;  DMG/CGB Palette
	; -----------------------------------------
	; Check if we are running CGB or DMG hardware
		ld a, (modelType)
		cp CGB_MODE
		jp z, @@InitCGBPalette

	; Check if we are running in SGB
		ld a, (modelType)
		cp SGB_MODE
		jp z, @SuperGameBoy

		@@InitDMGPalette:
		;  Set DMG palette
			ld a, (TestRoomAssets@BackgroundGB@DMGPal)
			ld (rBGP), a

			jp TestRoomLoadEntities

		@@InitCGBPalette:
		; Set CGB palette
			; ld c, 0*8				; Palette #0 (BG)
			; ld b, BG_PALETTE
			; ld hl, TestRoomAssets@BackgroundGB@CGBPal
			; call SetCGBPalette

		; Bank Switch VRAM to write the Attribute Map
	
			jp TestRoomLoadEntities

	
	@SuperGameBoy:
	; -----------------------------------------
	;  DMG/SGB Palette
	; -----------------------------------------

		@@InitSGBPalette:
		; DMG Palette
			;  Set DMG palette
			ld a, (TestRoomAssets@BackgroundGB@SGBPal)
			ld (rBGP), a

		; Freeze GB Screen
			ld hl, MaskFreezeSGB
			call SendSGBPacket

		; Start by setting our SGB palette 0 and 1
			ld hl, TestRoomAssets@SGBAssets@SGBPal
			call SendSGBPacket
		; And SGB palette 2 and 3
			ld hl, TestRoomAssets@SGBAssets@SGBPal + $10
			call SendSGBPacket
		; And send out Attribute Files
			ld hl, TestRoomAssets@SGBAssets@SGBATR
			call SendSGBPacket
		
		; Unfreeze GB Screen
			ld hl, MaskUnfreezeSGB
			call SendSGBPacket

			jp TestRoomLoadEntities
	
	
TestRoomLoadEntities:
; -----------------------------------------
;  LFSR Tiles
; -----------------------------------------
	; Cursor Tiles
		ld de, LFSRCursorSubClass@Tiles
		ld hl, LFSR_CURSOR_VRAM
		call TileAndMapHandler
	; Number and Words Tiles
		ld de, LFSRCursorSubClass@Tiles@SpriteSheet
		ld hl, NUMBERS_VRAM
		call TileAndMapHandler
	; Taps Tiles
		ld de, TapEntityClass@Tiles
		ld hl, TAP_VRAM
		call TileAndMapHandler
		

	; -----------------------------------------
	;  DMG/CGB Palette
	; -----------------------------------------
	; Check if we are running CGB or DMG hardware
		ld a, (modelType)
		//cp CGB_MODE
		//jp z, @InitCGBPalette
		cp SGB_MODE
		jp z, @InitSGBPalette


	@InitDMGPalette:
	;  And after we set the DMG palette 
		ld a, (TestRoomAssets@ObjectsGB@Object0DMGPal)
		ld (rOBP0), a
		ld a, (TestRoomAssets@ObjectsGB@WhiteRunObjectPal)
		ld (rOBP1), a

		jp @InitPlayer

	@InitSGBPalette:
	;  And after we set the DMG palette 
		ld a, (TestRoomAssets@ObjectsGB@Object0SGBPal)
		ld (rOBP0), a
		ld a, (TestRoomAssets@ObjectsGB@WhiteRunObjectSGBPal)
		ld (rOBP1), a

		jp @InitPlayer

	/*
	@InitCGBPalette:
	; Set CGB palette
		ld c, 0*8				; Palette #0 (OBJ)
		ld b, OBJ_PALETTE
		ld hl, TitleAssets@Entities@Object1CGBPal
		call SetCGBPalette
		
		jp @InitSFSShimmer
*/
; -----------------------------------------
;  Cursor
; -----------------------------------------
	@InitPlayer:
	; Activate entity for our cursor
		call EntityListClass@ActivateEntity
	; Initialize the cursor
		ld de, LFSRCursorSubClass@Initialize
		call CursorEntityClass@Initialize

; -----------------------------------------
;  BITs
; -----------------------------------------
	@InitBitGraphics:
	; BIT 0
	; Activate entity for our cursor
		call EntityListClass@ActivateEntity
	; Initialize Bit 0
		ld a, $7
		call BitEntityClass@Initialize
	;Lazily set X and Y
		ld de, bitGraphicStructure.yPos - bitGraphicStructure.eventID
		add hl, de								;HL = bitGraphic.yPos
		ld (hl), BIT_0_Y
		ld de, bitGraphicStructure.xPos - bitGraphicStructure.yPos
		add hl, de								;HL = bitGraphic.yPos
		ld (hl), BIT_0_X

	; BIT 1
	; Activate entity for our cursor
		call EntityListClass@ActivateEntity
	; Initialize Bit 1
		ld a, $06
		call BitEntityClass@Initialize
	;Lazily set X and Y
		ld de, bitGraphicStructure.yPos - bitGraphicStructure.eventID
		add hl, de								;HL = bitGraphic.yPos
		ld (hl), BIT_0_Y
		ld de, bitGraphicStructure.xPos - bitGraphicStructure.yPos
		add hl, de								;HL = bitGraphic.yPos
		ld (hl), BIT_0_X + 15

	; BIT 2
	; Activate entity for our cursor
		call EntityListClass@ActivateEntity
	; Initialize Bit 2
		ld a, $05
		call BitEntityClass@Initialize
	;Lazily set X and Y
		ld de, bitGraphicStructure.yPos - bitGraphicStructure.eventID
		add hl, de								;HL = bitGraphic.yPos
		ld (hl), BIT_0_Y
		ld de, bitGraphicStructure.xPos - bitGraphicStructure.yPos
		add hl, de								;HL = bitGraphic.yPos
		ld (hl), BIT_0_X + 30

	; BIT 3
	; Activate entity for our cursor
		call EntityListClass@ActivateEntity
	; Initialize Bit 3
		ld a, $04
		call BitEntityClass@Initialize
	;Lazily set X and Y
		ld de, bitGraphicStructure.yPos - bitGraphicStructure.eventID
		add hl, de								;HL = bitGraphic.yPos
		ld (hl), BIT_0_Y
		ld de, bitGraphicStructure.xPos - bitGraphicStructure.yPos
		add hl, de								;HL = bitGraphic.yPos
		ld (hl), BIT_0_X + 45

	; BIT 4
	; Activate entity for our cursor
		call EntityListClass@ActivateEntity
	; Initialize Bit 4
		ld a, $03
		call BitEntityClass@Initialize
	;Lazily set X and Y
		ld de, bitGraphicStructure.yPos - bitGraphicStructure.eventID
		add hl, de								;HL = bitGraphic.yPos
		ld (hl), BIT_0_Y
		ld de, bitGraphicStructure.xPos - bitGraphicStructure.yPos
		add hl, de								;HL = bitGraphic.yPos
		ld (hl), BIT_0_X + 60

	; BIT 5
	; Activate entity for our cursor
		call EntityListClass@ActivateEntity
	; Initialize Bit 5
		ld a, $02
		call BitEntityClass@Initialize
	;Lazily set X and Y
		ld de, bitGraphicStructure.yPos - bitGraphicStructure.eventID
		add hl, de								;HL = bitGraphic.yPos
		ld (hl), BIT_0_Y
		ld de, bitGraphicStructure.xPos - bitGraphicStructure.yPos
		add hl, de								;HL = bitGraphic.yPos
		ld (hl), BIT_0_X + 75

	; BIT 6
	; Activate entity for our cursor
		call EntityListClass@ActivateEntity
	; Initialize Bit 6
		ld a, $01
		call BitEntityClass@Initialize
	;Lazily set X and Y
		ld de, bitGraphicStructure.yPos - bitGraphicStructure.eventID
		add hl, de								;HL = bitGraphic.yPos
		ld (hl), BIT_0_Y
		ld de, bitGraphicStructure.xPos - bitGraphicStructure.yPos
		add hl, de								;HL = bitGraphic.yPos
		ld (hl), BIT_0_X + 90

	; BIT 7
	; Activate entity for our cursor
		call EntityListClass@ActivateEntity
	; Initialize Bit 7
		ld a, $00
		call BitEntityClass@Initialize
	;Lazily set X and Y
		ld de, bitGraphicStructure.yPos - bitGraphicStructure.eventID
		add hl, de								;HL = bitGraphic.yPos
		ld (hl), BIT_0_Y
		ld de, bitGraphicStructure.xPos - bitGraphicStructure.yPos
		add hl, de								;HL = bitGraphic.yPos
		ld (hl), BIT_0_X + 105

; -----------------------------------------
;  Output
; -----------------------------------------
	; Output
	; Activate entity for our cursor
		call EntityListClass@ActivateEntity
		call OutputEntityClass@Initialize
	;Lazily set X and Y
		ld de, entityStructure.yPos - entityStructure.eventID
		add hl, de								;HL = bitGraphic.yPos
		ld (hl), OUTPUT_Y
		ld de, entityStructure.xPos - entityStructure.yPos
		add hl, de								;HL = bitGraphic.yPos
		ld (hl), OUTPUT_X

; -----------------------------------------
;  TAPs
; -----------------------------------------
	; TAP 0
	; Activate entity for our cursor
		call EntityListClass@ActivateEntity
	; Initialize TAP 0
		ld a, $07
		call TapEntityClass@Initialize
	;Lazily set X and Y
		ld de, entityStructure.yPos - entityStructure.eventID
		add hl, de								;HL = bitGraphic.yPos
		ld (hl), TAP_0_Y
		ld de, entityStructure.xPos - entityStructure.yPos
		add hl, de								;HL = bitGraphic.yPos
		ld (hl), TAP_0_X + 00

	; TAP 1
	; Activate entity for our cursor
		call EntityListClass@ActivateEntity
	; Initialize TAP 1
		ld a, $06
		call TapEntityClass@Initialize
	;Lazily set X and Y
		ld de, entityStructure.yPos - entityStructure.eventID
		add hl, de								;HL = bitGraphic.yPos
		ld (hl), TAP_0_Y
		ld de, entityStructure.xPos - entityStructure.yPos
		add hl, de								;HL = bitGraphic.yPos
		ld (hl), TAP_0_X + 15

	; TAP 2
	; Activate entity for our cursor
		call EntityListClass@ActivateEntity
	; Initialize TAP 2
		ld a, $05
		call TapEntityClass@Initialize
	;Lazily set X and Y
		ld de, entityStructure.yPos - entityStructure.eventID
		add hl, de								;HL = bitGraphic.yPos
		ld (hl), TAP_0_Y
		ld de, entityStructure.xPos - entityStructure.yPos
		add hl, de								;HL = bitGraphic.yPos
		ld (hl), TAP_0_X + 30
	
	; TAP 3
	; Activate entity for our cursor
		call EntityListClass@ActivateEntity
	; Initialize TAP 3
		ld a, $04
		call TapEntityClass@Initialize
	;Lazily set X and Y
		ld de, entityStructure.yPos - entityStructure.eventID
		add hl, de								;HL = bitGraphic.yPos
		ld (hl), TAP_0_Y
		ld de, entityStructure.xPos - entityStructure.yPos
		add hl, de								;HL = bitGraphic.yPos
		ld (hl), TAP_0_X + 45
	
	; TAP 4
	; Activate entity for our cursor
		call EntityListClass@ActivateEntity
	; Initialize TAP 4
		ld a, $03
		call TapEntityClass@Initialize
	;Lazily set X and Y
		ld de, entityStructure.yPos - entityStructure.eventID
		add hl, de								;HL = bitGraphic.yPos
		ld (hl), TAP_0_Y
		ld de, entityStructure.xPos - entityStructure.yPos
		add hl, de								;HL = bitGraphic.yPos
		ld (hl), TAP_0_X + 60

	; TAP 5
	; Activate entity for our cursor
		call EntityListClass@ActivateEntity
	; Initialize TAP 5
		ld a, $02
		call TapEntityClass@Initialize
	;Lazily set X and Y
		ld de, entityStructure.yPos - entityStructure.eventID
		add hl, de								;HL = bitGraphic.yPos
		ld (hl), TAP_0_Y
		ld de, entityStructure.xPos - entityStructure.yPos
		add hl, de								;HL = bitGraphic.yPos
		ld (hl), TAP_0_X + 75

	; TAP 6
	; Activate entity for our cursor
		call EntityListClass@ActivateEntity
	; Initialize TAP 6
		ld a, $01
		call TapEntityClass@Initialize
	;Lazily set X and Y
		ld de, entityStructure.yPos - entityStructure.eventID
		add hl, de								;HL = bitGraphic.yPos
		ld (hl), TAP_0_Y
		ld de, entityStructure.xPos - entityStructure.yPos
		add hl, de								;HL = bitGraphic.yPos
		ld (hl), TAP_0_X + 90

	; TAP 7
	; Activate entity for our cursor
		call EntityListClass@ActivateEntity
	; Initialize TAP 7
		ld a, $00
		call TapEntityClass@Initialize
	;Lazily set X and Y
		ld de, entityStructure.yPos - entityStructure.eventID
		add hl, de								;HL = bitGraphic.yPos
		ld (hl), TAP_0_Y
		ld de, entityStructure.xPos - entityStructure.yPos
		add hl, de								;HL = bitGraphic.yPos
		ld (hl), TAP_0_X + 105


	;  Turn the LCD on with 8x16 Objects and BG
    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON | LCDCF_OBJ16 | LCDCF_BG8800
    ld (rLCDC), a

; Set Game State to the TestRoomLoop
	; Load next Game State
	ld a, lobyte(TestRoomLoop)
	ld ($FF00 + lobyte(nextGameState)), a
	ld a, hibyte(TestRoomLoop)
	ld ($FF00 + (hibyte(nextGameState))), a		; (nextGameState) = HL
; Set the correct bank
	ld a, TEST_ROOM_BANK
	ld ($FF00 + lobyte(nextGameStateBank)), a
; And set the flag to change the state
	ld a, CHANGE_GAME_STATE_FLAG
	ld ($FF00 + lobyte(changeGameStateFlag)), a

; Fade the screen in
	; call FadeIn

	ld a, $01
	ld b, DEFAULT_LFSR_TAPS
	call LFSRClass@Initialize

TestRoomLoop:
; Just throw the text up like this
	ld hl, OAMBuffer + $94
; R
	ld (hl), $57
	inc hl
	ld (hl), $50
	inc hl
	ld (hl), $9A
	inc hl
	ld (hl), $10
	inc hl
; U
	ld (hl), $57
	inc hl
	ld (hl), $58
	inc hl
	ld (hl), $9C
	inc hl
	ld (hl), $10
	inc hl
; N
	ld (hl), $57
	inc hl
	ld (hl), $60
	inc hl
	ld (hl), $9E
	inc hl
	ld (hl), $10
	inc hl
; Handled by the cursor
	; call LFSRClass@RunOnce

; Update Graphics based on LFSR State

	ret

; ==============================================================
;  Assets
; ==============================================================
TestRoomAssets:
	@BackgroundGB:
		@@Tiles:
			.INCLUDE "..\\assets\\TestRoom\\BG\\testRoomTiles.inc"
		@@TilesEnd:

		@@Map:
			.INCLUDE "..\\assets\\TestRoom\\BG\\testRoomMap.inc"
		@@MapEnd:

		@@DMGPal:
			.DB		%11100000		
			;   	   C3,C2,C1,BG
		@@DMGPalEnd:

		@@SGBPal:
			.DB		%11100100		
			;   	   C3,C2,C1,BG
		@@SGBPalEnd:

	@ObjectsGB:
		@@Object0DMGPal:
			.DB		%11100000		
			;       C3,C2,C1,BG
		@@Object0DMGPalEnd:

		@@WhiteRunObjectPal:
			.DB		%11000000		
			;       C3,C2,C1,BG
		@@WhiteRunObjectPalEnd:
		@@BlackRunObjectPal:
			.DB		%11111100		
			;       C3,C2,C1,BG
		@@BlackRunObjectPalEnd:

		@@Object0SGBPal:
			.DB		%11100100		
			;       C3,C2,C1,BG
		@@Object0SGBPalEnd:

		@@WhiteRunObjectSGBPal:
			.DB		%11010101		
			;       C3,C2,C1,BG
		@@WhiteRunObjectSGBPalEnd:

	@SGBAssets:
		@@SGBPal:
			.INCLUDE "..\\assets\\TestRoom\\BG\\testRoomPal.inc"
		@@SGBPalEnd:

		@@SGBATR:
			.INCLUDE "..\\assets\\TestRoom\\BG\\testRoomBLK.inc"
		@@SGBATREnd:

	

.ENDS

.INCLUDE "..\\testRoom\\lfsrCursorSubclass.asm"

