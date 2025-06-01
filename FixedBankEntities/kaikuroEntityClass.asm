.SECTION "Kaikuro Class"
KaikuroEntityClass:
;================================================================================
; All subroutines and data related to the SFS Shimmer Kaikuro Class
;================================================================================
;Change the following throughout the entire class
; Kaikuro: 		Captial letter of the entity (Entity)
; kaikuro: 		Lower case letter of the entity (entity)
; KAIKURO:		Constant values (ENTITY)
;==============================================================
; Constants
;==============================================================
;Init Values
	.DEF 	KAIKURO_START_Y				$0600 + $0100	;96 = $60.0 + yPos Offset
	.DEF	KAIKURO_START_X	 			$0280 + $0080	;40 = $28.0 + xPos Offset
	.DEF	KAIKURO_SPEED				$08				;$LSB,FRAC
	.DEF	KAIKURO_TIMER_INIT_VALUE	$00

;Kaikuro OBJ data
	.DEF	KAIKURO_NUM_OBJS			$01				;Number of OBJs entity uses
	.DEF	KAIKURO_SIZE				$10				;8x8 ($08) or 8x16 ($10)
	.DEF	KAIKURO_SHAPE				$11				;Shape of our Entity $WidthHeight (Measured in OBJs)

;VRAM Absolute Data
	.DEF 	KAIKURO_VRAM				$8240

;Attack Hitbox
	.DEF	KAIKURO_ATK_HITBOX_VERT_OFFSET	$05
	.DEF	KAIKURO_ATK_HITBOX_WIDTH		$08		
	.DEF	KAIKURO_ATK_HITBOX_HEIGHT		$06	
	.DEF	KAIKURO_DMG_HITBOX_WIDTH		$08		
	.DEF	KAIKURO_DMG_HITBOX_HEIGHT		$06	

;AI YOKO constants
	.DEF	YOKO_DESTRUCT_Y_POS				160 + OBJ_YPOS_OFFSET
	.DEF	YOKO_SPAWN_Y_POS				$0000 + OBJ_YPOS_OFFSET




;==============================================================
; Updates the Kaikuro
;==============================================================
;
;Parameters: DE = kaikuro.eventID (Should be coming from EntityList@UpdateEntities)
;Returns: None
;Affects: DE
@UpdateKaikuro:
;Grab Event ID 
	push de									;Save entity.eventID
	pop hl									;HL = entity.eventID

;Check if dead
	ld a, (hl)
	cp DMG_HITBOX_COLLISION
	jp z, KaikuroEntityClass@DyingKaikuro

;Use Collisio with Tonbow event as a way to set the arcadeFlag for dead player

;Adjust animation
	;call @AdjustFrame

;Update Animation based off of state		
	push hl					
		call @UpdateEntityAnimation
	pop hl

;Update Positions of entity and Hitboxes
	push hl								; Save entity.eventID
		call @UpdatePositions
	pop hl								; HL = entity.eventID

;Add Entity to the OAM Buffer
	call GeneralEntityEvents@OAMHandler

	
	ret


;==============================================================
; Adjust what frame of animation Kaikuro is on
;==============================================================
@AdjustFrame:

		ret

;==============================================================
; Update Kaikuro animation based off current state
;==============================================================
@UpdateEntityAnimation:
; HL = kaikuro.eventID
; Swap HL and DE so that we can get the player's Y-coord
	push hl
	pop de								; DE = kaikuro.eventID
	ld a, ($FF00 +  playerOneEntityPointerLO)
	ld l,a
	ld a, ($FF00 +  playerOneEntityPointerHI)
	ld h,a								; HL = player.eventID
; Get to plyer's Y-coord
	ld bc, entityStructure.yPos - entityStructure.eventID
	add hl, bc							; HL = player.yPos
	ld a, (hl)							; A = (player.yPos)
	;ld ($FF00 + lobyte(temp8BitA)), a	; temp8BitA = (player.yPos) 
	push de
	pop hl								;HL = kaikuro.eventID
;Check if player is above or below the Kaikuro
	; ld bc, entityStructure.yPos - entityStructure.eventID
	add hl, bc							; HL = kaikuro.yPos
	ld b, (hl)							; A = (kaikuro.yPos)
	cp b
	jr c, @@PlayerAbove
; If player is below, then have the eyeball face down
	ld bc, KaikuroEntityClass@ObjectData@LookDown
	jr @@SetDirectionAnimation

	@@PlayerAbove:
	; If the player is above, face the eyeball up
		ld bc, KaikuroEntityClass@ObjectData@LookUp
	@@SetDirectionAnimation:
		ld de, entityStructure.objectDataPointer - entityStructure.yPos
		add hl, de							; HL = player.objectDataPointerLO
		ld a, c					
		ld (hli), a							; HL = player.objectDataPointerHI
		ld a, b

		ret


;==============================================================
; Update Kaikuro Position and Hitbox positions
;==============================================================
@UpdatePositions:
;Here is where we will update the Kaikuro's position based off of its current location.
;If it's at the bottom of the screen, then it should self destruct. Otherwise, it should
;Continue moving at its designated speed.
;Check current location
	ld de, entityStructure.yPos - entityStructure.eventID
	add hl, de							;HL = entity.yPos
	ldd a, (hl)							;HL = entity.yFracPos + 1
	dec hl								;HL = entity.yFracPos
	cp YOKO_DESTRUCT_Y_POS
	jr nc, @@SetDestructionEvent
;Not at the bottom of the screen yet, so continue to move down
	dec hl								;HL = entity.yVel
	ld (hl), KAIKURO_SPEED
	@@UpdateObjectPosition:
;Save previous xPos to see if we need to update our column
		ld de, entityStructure.xPos - entityStructure.yVel
		add hl, de						;HL = entity.xPos
		ld a, (hl)						;A = (entity.xPos)
		ld de, entityStructure.eventID - entityStructure.xPos
		add hl, de						;HL = entity.eventID
		push af
			call GeneralEntityEvents@UpdatePosition
			;HL = dmgHitbox

		;Update atkHitbox location
			call @@UpdateHitboxes
			;HL = entity.atkHitbox
			;B = New (entity.xPos)
		pop af							;A = Old (entity.xPos)

	@@UpdateCurrentColumns:
	;Update location of atkHitbox in regards to the columns if need be
		ld d, ATK_HITBOX
		cp b							;If no change in xPos, don't bother
		call nz, ColumnClass@UpdateEntityCurrentColumns
	;Copy columnBitmap for dmgHitbox, since same
		ld a, (hl)						;A = atkHitbox.columnsBitmap
		ld de, -_sizeof_hitboxStructure
		add hl, de									;HL = dmghitBox
		ld (hl), a						;Bitmap Column Copied 

	;Check if we are being killed by the player
	call GeneralEntityEvents@CheckCollisionWithPlayer

	;Check if we are being hit by something
		;call ColumnClass@CheckColumnCollision

	ret


	@@UpdateHitboxes:
	;Attack Hitbox
		dec hl									;HL = entity.xPos
		ld b, (hl)
		ld de, entityStructure.yPos - entityStructure.xPos
		add hl, de								;HL = entity.yPos
		ld a, (hl)
	;Set X and Y. Width and Height stay constant
		ld de, entityStructure.atkHitbox.y1 - entityStructure.yPos
		add hl, de								;HL = entity.atkHitbox.y1
		sub a, OBJ_YPOS_OFFSET					;Adjust for offset
		add a, KAIKURO_ATK_HITBOX_VERT_OFFSET	;Adjust for how the sprite appears on screen
		ld ($FF00 + lobyte(temp8BitA)), a		;Save atkHitbox.x
		ld (hli), a								;HL = entity.atkHitbox.x1
		ld a, b
		sub a, OBJ_XPOS_OFFSET
		ld ($FF00 + lobyte(temp8BitB)), a		;Save atkHitbox.y
		ld (hl), a
		ld de, entityStructure.dmgHitbox.y1 - entityStructure.atkHitbox.x1 
		add hl, de								;HL = entity.dmgHitbox
	;Damage Hitbox
		ld a, ($FF00 + lobyte(temp8BitA))		;A = atkHitbox.y
		ld (hli), a								;HL = dmg.x
		ld a, ($FF00 + lobyte(temp8BitB))		;A = atkHitbox.x
		ld (hl), a								
		ld de, entityStructure.atkHitbox - entityStructure.dmgHitbox.x1 
		add hl, de								;HL = entity.dmgHitbox
	
		
		ret

	@@SetDestructionEvent:
		ld de, entityStructure.eventID - entityStructure.yFracPos
		add hl, de						;HL = entity.eventID
	;This will need to be changed to a special Self Destruct later
		ld (hl), DMG_HITBOX_COLLISION				;entity.eventID = Damage Collision
		ret

;==============================================================
; Dying Kaikuro
;==============================================================
;
;Parameters: HL = kaikuro.eventID 
;Affects: A, HL, DE
@DyingKaikuro:
;Check what stage of death the Kaikuro is at

;Update animation

;Remove from columns
	push hl
		ld de, entityStructure.atkHitbox - entityStructure.eventID
		add hl, de							;HL = kaikuro.atkHitbox.columnsBitmap
		ld a, (hl)							;B = kaikuro.columnsBitmap
		push hl
		pop de								;DE = kaikuro.atkHitbox.columnsBitmap
		ld hl, column.0.activePointersBitmap

		@@CheckRemovedColumns:
		ld bc, _sizeof_columnStructure
	-:
		cp $00
		jr z, +
		srl a
		call c, ColumnClass@RemoveFromColumn
		add hl, bc									;HL = column.next
		jr -

	+:

	
	pop hl
; HOPEFULLY TEMPORARY, I DON'T LIKE THIS SOLUTION
	ld a, (numActiveEnemies)
	dec a
	ld (numActiveEnemies), a

;If totally dead, remove from list
	jp EntityListClass@DeactivateEntity

;==============================================================
; Initializes the Kaikuro
;==============================================================
;
;Parameters: HL = kaikuro.eventID, initYPosVar = yFracPos, initXPosVar = xFracPos
;Affects: A, HL, DE
@Initialize:
;Check if activated properly
	ld a, (hl)
	cp ACTIVATE_SUCCESS
	ret nz								;If the entity didn't get added, then we shouldn't initialize it
;Initialize General properties
	push hl
	/*
	;Set yPos
		ld de, initYPosVar
		ld a, hibyte(KAIKURO_START_Y)
		ld (de), a
		inc de
		ld a, lobyte(KAIKURO_START_Y)
		ld (de), a
	;Set xPos
		ld de, initXPosVar
		ld a, hibyte(KAIKURO_START_X)
		ld (de), a
		inc de
		ld a, lobyte(KAIKURO_START_X)
		ld (de), a
	*/
	;Set timer
		ld a, KAIKURO_TIMER_INIT_VALUE
		ld ($FF00 + lobyte(aux8BitVar)), a
	;Set UpdateEntityPointer
		ld bc, KaikuroEntityClass@ObjectData
	;Set ObjectDataPointer
		ld de, KaikuroEntityClass@UpdateKaikuro
		call GeneralEntityEvents@InitializeEntity
	pop hl
	push hl
	;Set up xPos, yPos, and atkHitbox
		call GeneralEntityEvents@UpdatePosition	
		ld (hl), $00							;entity.dmgHitbox.columnsBitmap = $00
		;HL = atkHitbox
		dec hl									;HL = entity.xPos
		ld b, (hl)
		ld de, entityStructure.yPos - entityStructure.xPos
		add hl, de								;HL = entity.yPos
		ld a, (hl)
		ld de, entityStructure.atkHitbox.columnsBitmap - entityStructure.yPos
		add hl, de								;HL = entity.atkHitbox.columnsBitmap
		ld (hl), $00
		inc hl									;HL = entity.atkHitbox.width
		ld (hl), KAIKURO_ATK_HITBOX_WIDTH
		inc hl									;HL = entity.atkHitbox.height
		ld (hl), KAIKURO_ATK_HITBOX_HEIGHT
		inc hl									;HL = entity.atkHitbox.y1
		sub a, OBJ_YPOS_OFFSET					;Adjust for offset
		add a, KAIKURO_ATK_HITBOX_VERT_OFFSET	;Adjust for how the sprite appears on screen
		ld ($FF00 + lobyte(temp8BitA)), a		;Save yPos
		ld (hli), a								;HL = entity.atkHitbox.x1
		ld a, b
		sub a, OBJ_XPOS_OFFSET
		ld ($FF00 + lobyte(temp8BitB)), a		;Save xPos
		ld (hl), a
		ld de, entityStructure.dmgHitbox.columnsBitmap - entityStructure.atkHitbox.x1
		add hl, de								;HL = dmgHitbox.columnsBitmap
		ld (hl), $00
		inc hl									;HL = dmg.width
		ld (hl), KAIKURO_DMG_HITBOX_WIDTH
		inc hl									;HL = dmg.height
		ld (hl), KAIKURO_DMG_HITBOX_HEIGHT
		inc hl									;HL = dmg.y1
		ld a, ($FF00 + lobyte(temp8BitA))		;A = atkHitbox.y
		ld (hli), a								;HL = dmg.x
		ld a, ($FF00 + lobyte(temp8BitB))		;A = atk.x
		ld (hl), a
	;Set up Columns
		ld de, entityStructure.atkHitbox.columnsBitmap - entityStructure.dmgHitbox.x1
		add hl, de								;HL = atkHitbox
		ld d, ATK_HITBOX
		call ColumnClass@UpdateEntityCurrentColumns
	pop hl

		ret

;==============================================================
; Kaikuro's Object Data
;==============================================================
@ObjectData
	@@LookDown:
	;-------------------
	;OAM Handler Data
	;-------------------
	;How many objects we need to write for this Entity
		.DB		KAIKURO_NUM_OBJS								;numObjects
	;OBJ Size (8x8 or 8x16)
		.DB		KAIKURO_SIZE 									;sizeOBJ
	;Shape of our Entity $WidthHeight (Measured in OBJs)
		.DB		KAIKURO_SHAPE									;shape
	;-------------------
	;OAM Data
	;-------------------
	;Tile ID 1/2
		.DB 	lobyte(KAIKURO_VRAM >> 4)						;tileID
	;Object attribute flags
		.DB 	OAMF_PAL0										;objectAtr
;-----------------------------------------------------------------------------
	@@LookUp:
	;-------------------
	;OAM Handler Data
	;-------------------
	;How many objects we need to write for this Entity
		.DB		KAIKURO_NUM_OBJS								;numObjects
	;OBJ Size (8x8 or 8x16)
		.DB		KAIKURO_SIZE 									;sizeOBJ
	;Shape of our Entity $WidthHeight (Measured in OBJs)
		.DB		KAIKURO_SHAPE									;shape
	;-------------------
	;OAM Data
	;-------------------
	;Tile ID 1/2
		.DB 	lobyte(KAIKURO_VRAM >> 4)						;tileID
	;Object attribute flags
		.DB 	OAMF_PAL0 | OAMF_YFLIP							;objectAtr
;-----------------------------------------------------------------------------

@Tiles:
;Just the one set
	@@Open:
		.INCLUDE "..\\assets\\FixedBankEntities\\kaikuro\\kaikuroOpenTiles.inc"
	@@OpenEnd:
	@@Close:
		.INCLUDE "..\\assets\\FixedBankEntities\\kaikuro\\kaikuroCloseTiles.inc"
	@@CloseEnd:

.ENDS