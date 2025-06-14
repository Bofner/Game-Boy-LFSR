.SECTION "Controller Input"

; ==============================================================
;  Constants
; ==============================================================
	.DEF	IDLE				      %00000000
	.DEF	A_BUTTON			    %00000001
	.DEF	B_BUTTON			    %00000010
	.DEF	SEL_BUTTON			  %00000100
	.DEF	STR_BUTTON			  %00001000
	.DEF	DPAD_RIGHT			  %00010000
	.DEF	DPAD_LEFT			    %00100000
	.DEF	DPAD_UP				    %01000000
	.DEF	DPAD_DOWN			    %10000000
	.DEF	A_AND_B_BUTTON		%00000011

  .DEF  ALL_BUTTONS       %00001111
  .DEF  ALL_DPAD          %11110000

; Checks the state of the keys on the Game Boy
; 
; Parameters: None
; Returns: None
; Affects: A, B
UpdateKeys:
  ;  Poll half the controller
  ld a, P1F_GET_BTN
  call @OneNibble
  ld b, a ;  B7-4 = 1;  B3-0 = unpressed buttons

  ;  Poll the other half
  ld a, P1F_GET_DPAD
  call @OneNibble
  swap a ;  A3-0 = unpressed directions;  A7-4 = 1
  xor a, b ;  A = pressed buttons + directions
  ld b, a ;  B = pressed buttons + directions

  ;  And release the controller
  ld a, P1F_GET_NONE
  ld (rP1), a

  ;  Combine with previous wCurKeys to make wNewKeys
  ld a, (currentKeyPress1)
  xor a, b ;  A = keys that changed state
  and a, b ;  A = keys that changed to pressed
  ld (newKeyPress1), a
  ld a, b
  ld (currentKeyPress1), a
  ret

@OneNibble
  ld (rP1), a ;  switch the key matrix
  call @KnownRet ;  burn 10 cycles calling a known ret
  ld a, (rP1) ;  ignore value while waiting for the key matrix to settle
  ld a, (rP1)
  ld a, (rP1) ;  this read counts
  or a, $F0 ;  A7-4 = 1;  A3-0 = unpressed keys
@KnownRet
  ret

UpdateKeysEnd:

.ENDS