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

	; set value in timer 0 to r16
	eor r16, r16
	out TCNT0, r16
	
	; set the prescaler, so we get CLK/1024
	ldi r16, 0b00000101
	out TCCR0B, r16
	
	; value to compare to. should give us a delay of ~1ms
	; 20MHz/1024/1000=19.5
	ldi r16, 19
	out OCR0A, r16
	
	; clear the OCF0A flag
	ldi r16, 0b010
	out TIFR0, r16
	
delay:
	in r16, TIFR0 ; read timer 0 interrupt flag register
	andi r16, 0b010 ; check OCF0A flag
	breq delay ; keep spinning if it's not set
	rjmp main


; bits: A B C D E F G 0
; MSB -> LSB
numbers: .db 0xfc, 0x60, 0xda, 0xf2, 0x66, 0xb6, 0xbe, 0xe0, 0xfe, 0xe6, 0xee, 0x3e, 0x9c, 0x7a, 0x9e, 0x8e
