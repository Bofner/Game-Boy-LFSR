.RAMSECTION "LFSR Variables" BANK 0 SLOT 3 RETURNORG
; Variables:
	currentLFSRValue			db				; Current value of our LFSR
	tapsBitmap					db				; Which bits are set as our taps
	sizeFour					db				; Random numbers 0-3
	sizeEight					db				; Random numbers 0-7
	sizeSixteen					db				; Random numbers 0-15
.ENDS

.SECTION "Linear Feedback Shift Register"

	.DEF	DEFAULT_LFSR_TAPS	%01110001
	.DEF	DEFAULT_SEED		%00000001

LFSRClass:

@RunOnce:
; Set up our tap checking loop
	ld a, (tapsBitmap)						
	ld b, a									; B = Bitmap of our taps
	ld a, (currentLFSRValue)				
	ld c, a									; C = current LFSR state
	ld d, 8									; D is our counter or timer for the loop
	xor a									; A = 0
; The loop
	@@LoopStart:
; Check if this bit is a tap
	srl b									; Check the bit
	jr nc, @@NoTap
	; This bit is a tap
	srl c									; CY = Tap Value
	adc $00									; Add carry bit to A
	; and %00000001							; Only keep the LSB (Not necessary)
	jr @@LoopCheck		

	@@NoTap:
	; We are not at a tap
		srl c

	@@LoopCheck:
	; If we have gone through all 8 bits, then stop looping
		dec d
		jr nz, @@LoopStart

	@@UpdateLFSR:
	; LFSR cycle complete, so update the LFSR
		srl a
		ld a, (currentLFSRValue)
		rra									;Put XOR'd value into our current LFSR value and shift
		ld (currentLFSRValue), a
	; EXTRA
		;swap a
		ld b, $0F
		and b
		ld (sizeSixteen), a

	ret

; Parameters:  A = Initial value, B = Taps Bitmap
; Returns: None
; Affects: None
@Initialize:
	ld (currentLFSRValue), a
	ld a, b
	ld (tapsBitmap), a

	ret
	
.ENDS