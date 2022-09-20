#define F_CPU 20000000

#include <stdint.h>
#include <avr/io.h>

const uint8_t digits[] = {0xfc, 0x60, 0xda, 0xf2, 0x66, 0xb6, 0xbe, 0xe0, 0xfe, 0xe6, 0xee, 0x3e, 0x9c, 0x7a, 0x9e, 0x8e};

int main() {
	DDRB = 1;
	DDRC = 0;
	DDRD = 0xFF;
	
	TCNT0 = 0;
	TCCR0B = 1 | (1 << 2); // set prescaler to 1024
	OCR0A = 19;
	
	uint8_t mode = 0;

	while (1) {
		uint8_t number = PINC;
		if (mode) number >>= 4;
		number &= 0x0F;

		PORTB = mode;
		PORTD = digits[number];

		if (mode)
			mode = 0;
		else
			mode = 1;

		// delay for ~1ms
		TCNT0 = 0;
		TIFR0 = 1 << 1;
		while ((TIFR0 & (1 << 1)) == 0);
	}
}
