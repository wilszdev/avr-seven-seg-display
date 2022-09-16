.include "m324Adef.inc"

.cseg
.org 0

.def NUMBER = r16
.def SSD_RET = r17
.def SSD_0 = r18
.def SSD_1 = r19
.def SSD_PARAM = r20
.def NUM_DIG_0 = r21
.def NUM_DIG_1 = r22
.def MODE = r23

.def DIVISOR = r25
.def DIVIDEND = r26
.def RESULT = r26
.def REMAINDER = r27
.def COUNT = r28

setup:
	; MODE controls which digit we're outputting
	; MODE=0 means low digit
	; MODE=1 means high digit
	eor MODE, MODE	

	; we'll be outputting MODE on B0	
	ldi r16, 1
	out DDRB, r16
	; will read an 8-bit number from PINC
	eor r16, r16
	out DDRC, r16
	; output to the SSD on PORTD
	ldi r16, 0xFF
	out DDRD, r16

	; setup the stack
	ldi r16, HIGH(RAMEND)
	out sph, r16
	ldi r16, LOW(RAMEND)
	out spl, r16

mainloop:
; delay so that the SSD displays properly
	ldi r16, 255
delay:	and r16, r16
	breq delay_done
	dec r16
	ldi r17, 50
delay_inner:
	and r17, r17
	breq delay
	dec r17
	rjmp delay_inner

delay_done:
	in NUMBER, PINC
	
	; make sure number <100
	subi NUMBER, 100
	brsh clamp_number
	subi NUMBER, -100 ; restore value	
	rjmp do_division_and_output

clamp_number:
	ldi NUMBER, 99

do_division_and_output:
	mov DIVIDEND, NUMBER
	ldi DIVISOR, 10
	call div8u
	
	out PORTB, MODE	
	and MODE, MODE
	brne do_high
do_low:
	mov SSD_PARAM, REMAINDER
	inc MODE
	rjmp display
do_high:
	mov SSD_PARAM, RESULT
	dec MODE
display:
	call digit_to_ssd
	out PORTD, SSD_RET
	rjmp mainloop

; divide 8 bit number
div8u:	sub REMAINDER, REMAINDER ; clears remainder AND carry flag
	ldi COUNT, 9
d8u_1:	rol DIVIDEND
	dec COUNT
	brne d8u_2
	ret
d8u_2:	rol REMAINDER
	sub REMAINDER, DIVISOR
	brcc d8u_3
	add REMAINDER, DIVISOR
	clc
	rjmp d8u_1
d8u_3:	sec
	rjmp d8u_1

; parameter: value 0-9
; returns: 8-bit value for outputting to 7 seg display
digit_to_ssd:
	eor SSD_RET, SSD_RET
	
	; load address for zero digit into Z
	ldi ZL, LOW(numbers*2)
	ldi ZH, HIGH(numbers*2)

	; make sure the digit we got is less than 10	
	subi SSD_PARAM, 10
	brge end
	
	subi SSD_PARAM, -10 ; restore value
	add ZL, SSD_PARAM
	adc ZH, SSD_RET ; SSD_RET is 0, this is just for the carry
	lpm SSD_RET, Z

	end:	ret

numbers: .db 0b00111111, 0b00000110, 0b01011101, 0b01001111, 0b01100110, 0b01101011, 0b01111011, 0b00001110, 0b01111111, 0b01101111
