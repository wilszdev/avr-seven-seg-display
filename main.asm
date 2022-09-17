.include "m324Adef.inc"

.def NUMBER = r18
.def MODE = r19

.cseg
.org 0


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

main:
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

	; load address for zero digit into Z
	ldi ZL, LOW(numbers*2)
	ldi ZH, HIGH(numbers*2)

	; use NUMBER as index into array
	eor r16, r16
	add ZL, NUMBER
	adc ZH, r16 ; 0, this is just for the carry
	lpm NUMBER, Z ; retrieve byte to output
	out PORTD, NUMBER

; delay so that the SSD displays properly
	ldi r16, 255
delay:
	tst r16
	breq main
	dec r16
	ldi r17, 50
delay_inner:
	tst r17
	breq delay
	dec r17
	rjmp delay_inner


; bits: A B C D E F G 0
; MSB -> LSB
numbers: .db 0xfc, 0x60, 0xda, 0xf2, 0x66, 0xb6, 0xbe, 0xe0, 0xfe, 0xe6, 0xee, 0x3e, 0x9c, 0x7a, 0x9e, 0x8e
