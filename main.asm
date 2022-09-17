.include "m324Adef.inc"

.cseg
.org 0

.def NUMBER = r18
.def SSD_RET = r19
.def MODE = r20


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

mainloop:
; delay so that the SSD displays properly
	ldi r16, 255
delay:
	tst r16
	breq delay_done
	dec r16
	ldi r17, 50
delay_inner:
	tst r17
	breq delay
	dec r17
	rjmp delay_inner

delay_done:
	in NUMBER, PINC
	out PORTB, MODE

	tst MODE
	brne do_high
do_low:
	inc MODE
	rjmp display
do_high:
	dec MODE
	swap NUMBER
display:
	andi NUMBER, 0x0F
	call digit_to_ssd
	out PORTD, SSD_RET
	rjmp mainloop


; parameter: value 0-15
; returns: 8-bit value for outputting to 7 seg display
digit_to_ssd:
	eor SSD_RET, SSD_RET

	; load address for zero digit into Z
	ldi ZL, LOW(numbers*2)
	ldi ZH, HIGH(numbers*2)

	; make sure the digit we got is less than 16
	subi NUMBER, 0x10
	brsh end

	subi NUMBER, -0x10 ; restore value
	add ZL, NUMBER
	adc ZH, SSD_RET ; SSD_RET is 0, this is just for the carry
	lpm SSD_RET, Z

end:
	ret

; bits: A B C D E F G 0
; MSB -> LSB

numbers: .db 0xfc, 0x60, 0xda, 0xf2, 0x66, 0xb6, 0xbe, 0xe0, 0xfe, 0xe6, 0xee, 0x3e, 0x9c, 0x7a, 0x9e, 0x8e
