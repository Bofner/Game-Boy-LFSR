.SECTION "Structure Definitions"
; ==============================================================
; Standard no parallax screen scroll
; ==============================================================
.STRUCT stdScreenScrollStructure
; Y-coordinate info  
    yVel                        db      ; Velocity %SYYYFFFF 
    yFracPos                    dw      ; Fractional position $WHOLELO, FRAC $UNUSED, WHOLEHI
    yPos                        db      ; Y offset for the BG scrolling
; X-coordinate info  
    xVel                        db      ; Velocity %SXXXFFFF 
    xFracPos                    dw      ; Fractional position $WHOLELO, FRAC $UNUSED, WHOLEHI
    xPos                        db      ; X offset for the BG scrolling 
.ENDST


; ==============================================================
;  Hitbox Structure
; ==============================================================
.STRUCT hitboxStructure
    columnsBitmap               db      ; Bits 0-4 are the columns the entity is currently in. 1 = inside a column
    width                       db      ; How far across Hitbox stretches in pixels, if 0, then invincible
    height                      db      ; How far down the Hitbox stretches in pixels
    y1                          db      ; Top left corner of Hitbox yPos
    x1                          db      ; Top left corner of Hitbox xPos
.ENDST

; ==============================================================
;  Pointers
; ==============================================================
.STRUCT pointerStructure
    loByte                                  db
    hiByte                                  db
.ENDST

; ==============================================================
;  Column Structure
; ==============================================================
.STRUCT columnStructure
    xPos                                    db      ; Column position
    width                                   db      ; Width of the Column
    activePointersBitmap                    db      ; Bitmap of active pointers
    entity.atkHitboxPointer.0               dw      ; 0th pointer to entity atkHitbox
    entity.atkHitboxPointer INSTANCEOF pointerStructure 7

.ENDST
; ==============================================================
;  Overflow Column Structure
; ==============================================================
.STRUCT overflowColumnStructure
    numEntities                             db      ; Number of entities in the Column
    activePointersBitmap.0                  db      ; Bitmap of active pointers
    activePointersBitmap.1                  db      ; Bitmap of active pointers
    activePointersBitmap.2                  db      ; Bitmap of active pointers
    activePointersBitmap.3                  db      ; Bitmap of active pointers
    entity.atkHitboxPointer.0               dw      ; 0th pointer to entity atkHitbox
    entity.atkHitboxPointer INSTANCEOF pointerStructure 31

.ENDST

.STRUCT specificStructure
    specific                                db      ; Specific structure 
.ENDST

; ==============================================================
;  Entity Structure
; ==============================================================
.STRUCT entitySkeleton
    ; General Entity info
    eventID                     db      ; What event is currently happening. NOTHING, MOVE, DIE etc.
    state                       db      ; Current condition of Entity. DEAD, AI_1, DYING, SPAWING etc.
    timer                       db      ; Basic all-purpose timer. Animation, AI routine
    entityUpdatePointer         dw      ; A Pointer to the Entity's Update Subroutine
    objectDataPointer           dw      ; Points to Object Data based off of current animation frame
; Y-coordinate info  
    yVel                        db      ; Velocity %SYYYFFFF 
    yFracPos                    dw      ; Fractional position $UNUSED,WHOLEMSB $WHOLELSB,FRAC
    yPos                        db      ; The Y coord of the Entity's top left corner.
; X-coordinate info  
    xVel                        db      ; Velocity %SXXXFFFF 
    xFracPos                    dw      ; Fractional position $UNUSED,WHOLEMSB $WHOLELSB,FRAC
    xPos                        db      ; The X coord of the Entity's top left corner. 
; Default Hurtbox and Hitbox. If more needed, they will be added in as a specific Entity Class
    dmgHitbox instanceof hitboxStructure
/*
    columnsBitmap               db      ; Bits 0-4 are the columns the entity is currently in. 1 = inside a column
    width                       db      ; How far across Hurtbox stretches in pixels, if 0, then invincible
    height                      db      ; How far down the Hurtbox stretches in pixels
    y1                          db      ; Top left corner of Hurtbox yPos
    x1                          db      ; Top left corner of Hurtbox xPos
    y2                          db      ; Bottom right corner of Hurtbox yPos
    x2                          db      ; Bottom right corner of Hurtbox xPos
*/
    atkHitbox instanceof hitboxStructure
/*
    columnsBitmap               db      ; Bits 0-4 are the columns the entity is currently in. 1 = inside a column
    width                       db      ; How far across Hitbox stretches in pixels, if 0, then invincible
    height                      db      ; How far down the Hitbox stretches in pixels
    y1                          db      ; Top left corner of Hitbox yPos
    x1                          db      ; Top left corner of Hitbox xPos
    y2                          db      ; Bottom right corner of Hitbox yPos
    x2                          db      ; Bottom right corner of Hitbox xPos
*/
    ; ここまで29Bytes
; ---------------------------------------------------------------------------------------------------
; Any special traits can go down here, up to 32 bytes 
    
.ENDST

; General purpose, full size entity
.STRUCT entityStructure SIZE $40
    instanceof entitySkeleton
    specific.0 instanceof specificStructure
    specific   instanceof specificStructure $40 - _sizeof_entitySkeleton - 1
.ENDST

; ---------------------------------------------

.STRUCT tonbowStructure SIZE $40
    instanceof entitySkeleton
/*
; General Entity info
    eventID                     db      ; What event is currently happening. NOTHING, MOVE, DIE etc.
    state                       db      ; Current condition of Entity. DEAD, AI_1, DYING, SPAWING etc.
    timer                       db      ; Basic all-purpose timer. Animation, AI routine
    entityUpdatePointer         dw      ; A Pointer to the Entity's Update Subroutine
    objectDataPointer           dw      ; Points to Object Data based off of current animation frame
; Y-coordinate info  
    yVel                        db      ; Velocity %SYYYFFFF 
    yFracPos                    dw      ; Fractional position $UNUSED,WHOLEMSB $WHOLELSB,FRAC
    yPos                        db      ; The Y coord of the Entity's top left corner.
; X-coordinate info  
    xVel                        db      ; Velocity %SXXXFFFF 
    xFracPos                    dw      ; Fractional position $UNUSED,WHOLEMSB $WHOLELSB,FRAC
    xPos                        db      ; The X coord of the Entity's top left corner. 
; Default Hurtbox and Hitbox. If more needed, they will be added in as a specific Entity Class
    dmgHitbox instanceof hitboxStructure
        columnsBitmap               db      ; Bits 0-4 are the columns the entity is currently in. 1 = inside a column
        width                       db      ; How far across Hurtbox stretches in pixels, if 0, then invincible
        height                      db      ; How far down the Hurtbox stretches in pixels
        y1                          db      ; Top left corner of Hurtbox yPos
        x1                          db      ; Top left corner of Hurtbox xPos
        y2                          db      ; Bottom right corner of Hurtbox yPos
        x2                          db      ; Bottom right corner of Hurtbox xPos
    atkHitbox instanceof hitboxStructure
        columnsBitmap               db      ; Bits 0-4 are the columns the entity is currently in. 1 = inside a column
        width                       db      ; How far across Hitbox stretches in pixels, if 0, then invincible
        height                      db      ; How far down the Hitbox stretches in pixels
        y1                          db      ; Top left corner of Hitbox yPos
        x1                          db      ; Top left corner of Hitbox xPos
        y2                          db      ; Bottom right corner of Hitbox yPos
        x2                          db      ; Bottom right corner of Hitbox xPos
*/
    ; ここまで29Bytes

; ---------------------------------------------------------------------------------------------------
; Any special traits can go down here, up to 64 bytes 
    dashResetTimer              db      ; Timer to allow player to dash again
.ENDST

; ----------------------------------------------

.STRUCT addressPointer
    pointer                     dw      ; Used to point to an address in memory
.ENDST

.STRUCT cursorStructure SIZE $40
    instanceof entitySkeleton
/*
; General Entity info
    eventID                     db      ; What event is currently happening. NOTHING, MOVE, DIE etc.
    state                       db      ; Current condition of Entity. DEAD, AI_1, DYING, SPAWING etc.
    timer                       db      ; Basic all-purpose timer. Animation, AI routine
    entityUpdatePointer         dw      ; A Pointer to the Entity's Update Subroutine
    objectDataPointer           dw      ; Points to Object Data based off of current animation frame
; Y-coordinate info  
    yVel                        db      ; Velocity %SYYYFFFF 
    yFracPos                    dw      ; Fractional position $UNUSED,WHOLEMSB $WHOLELSB,FRAC
    yPos                        db      ; The Y coord of the Entity's top left corner.
; X-coordinate info  
    xVel                        db      ; Velocity %SXXXFFFF 
    xFracPos                    dw      ; Fractional position $UNUSED,WHOLEMSB $WHOLELSB,FRAC
    xPos                        db      ; The X coord of the Entity's top left corner. 
; Default Hurtbox and Hitbox. If more needed, they will be added in as a specific Entity Class
    dmgHitbox instanceof hitboxStructure
        columnsBitmap               db      ; Bits 0-4 are the columns the entity is currently in. 1 = inside a column
        width                       db      ; How far across Hurtbox stretches in pixels, if 0, then invincible
        height                      db      ; How far down the Hurtbox stretches in pixels
        y1                          db      ; Top left corner of Hurtbox yPos
        x1                          db      ; Top left corner of Hurtbox xPos
        y2                          db      ; Bottom right corner of Hurtbox yPos
        x2                          db      ; Bottom right corner of Hurtbox xPos
    atkHitbox instanceof hitboxStructure
        columnsBitmap               db      ; Bits 0-4 are the columns the entity is currently in. 1 = inside a column
        width                       db      ; How far across Hitbox stretches in pixels, if 0, then invincible
        height                      db      ; How far down the Hitbox stretches in pixels
        y1                          db      ; Top left corner of Hitbox yPos
        x1                          db      ; Top left corner of Hitbox xPos
        y2                          db      ; Bottom right corner of Hitbox yPos
        x2                          db      ; Bottom right corner of Hitbox xPos
*/
    ; ここまで29Bytes

; ---------------------------------------------------------------------------------------------------
; Any special traits can go down here, up to 64 bytes 
    horiVert                    db      ; Move the cursor horizontally or vertically
    numPositions                db      ; Total number of positions a cursor can move
    currentPosition             db      ; Current cursor position, in regards to its moveable locations
    positionDistance            db      ; Distance a cursor travels per update    
    animationTimer              db      ; Timer for our animation  
    actionHandlerAddressPointer dw      ; Address of current position's actions
    lookUpTableAddress          dw      ; Address of subroutine lookup table (part of subclass)
    ; instanceof addressPointer  6

    
.ENDST

; ==============================================================
;  Active Entity LFSR Bit
; ==============================================================
.STRUCT bitGraphicStructure
       instanceof entitySkeleton
/*
; General Entity info
    eventID                     db      ; What event is currently happening. NOTHING, MOVE, DIE etc.
    state                       db      ; Current condition of Entity. DEAD, AI_1, DYING, SPAWING etc.
    timer                       db      ; Basic all-purpose timer. Animation, AI routine
    entityUpdatePointer         dw      ; A Pointer to the Entity's Update Subroutine
    objectDataPointer           dw      ; Points to Object Data based off of current animation frame
; Y-coordinate info  
    yVel                        db      ; Velocity %SYYYFFFF 
    yFracPos                    dw      ; Fractional position $UNUSED,WHOLEMSB $WHOLELSB,FRAC
    yPos                        db      ; The Y coord of the Entity's top left corner.
; X-coordinate info  
    xVel                        db      ; Velocity %SXXXFFFF 
    xFracPos                    dw      ; Fractional position $UNUSED,WHOLEMSB $WHOLELSB,FRAC
    xPos                        db      ; The X coord of the Entity's top left corner. 
; Default Hurtbox and Hitbox. If more needed, they will be added in as a specific Entity Class
    dmgHitbox instanceof hitboxStructure
        columnsBitmap               db      ; Bits 0-4 are the columns the entity is currently in. 1 = inside a column
        width                       db      ; How far across Hurtbox stretches in pixels, if 0, then invincible
        height                      db      ; How far down the Hurtbox stretches in pixels
        y1                          db      ; Top left corner of Hurtbox yPos
        x1                          db      ; Top left corner of Hurtbox xPos
        y2                          db      ; Bottom right corner of Hurtbox yPos
        x2                          db      ; Bottom right corner of Hurtbox xPos
    atkHitbox instanceof hitboxStructure
        columnsBitmap               db      ; Bits 0-4 are the columns the entity is currently in. 1 = inside a column
        width                       db      ; How far across Hitbox stretches in pixels, if 0, then invincible
        height                      db      ; How far down the Hitbox stretches in pixels
        y1                          db      ; Top left corner of Hitbox yPos
        x1                          db      ; Top left corner of Hitbox xPos
        y2                          db      ; Bottom right corner of Hitbox yPos
        x2                          db      ; Bottom right corner of Hitbox xPos
*/
    bitPosition                     db      ; Which bit int he LFSR this represents
.ENDST

; ==============================================================
;  Active Entity LFSR Bit
; ==============================================================
.STRUCT tapGraphicStructure
    instanceof entitySkeleton
    tapPosition                     db      ; Which bit int he LFSR this represents
    .ENDST

; ==============================================================
;  Active Entity Bitmap
; ==============================================================
.STRUCT bitmapStructure
    bitmap                      db
.ENDST


; ==============================================================
;  Entity List
; ==============================================================
.STRUCT entityListStructure
    numEntities                           db        ; Number of Entities in the list
    entity.0    INSTANCEOF entityStructure          ; WLA-DX doesn't start enumerating from 0
; Here are the rest of the Entities 
    entity      INSTANCEOF entityStructure  39

; The extra data we need to shuffle to enable sprite flicker and manage our list
    activationFailure                       db      ; Returned when we couldn't add an entity to the list
    numStartEntities                        db      ; Keep track of how many entities we started with
    shuffleOAMPos                           db      ; Where to start copying Entities to OAM from
    ; $BytePos,BitPos    $1-3,0-7
    shuffleBitmapIndex                      db      ; Stores the index of the bitmap that shuffleOAMPos is in
    ; $0,BytePos         $0, $1-3
    currentBitmapLocation                   db      ; Where we are in the Active Entity Bitmap
    ; $BytePos,BitPos    $0-3,0-7
    entitiesUpdated                         db      ; Number of entities we've updated
    bitmap.0                                db      ; WLA-DX doesn't start enumerating from 0
    bitmap      INSTANCEOF bitmapStructure  4       ; Active Entity Bitmap
.ENDST


.ENDS

