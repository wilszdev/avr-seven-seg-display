# MCU=m324a
# MCU=atmega328p
PORT=$(shell pavr2cmd --prog-port)
CFLAGS=-g -Wall -mcall-prologues -mmcu=atmega324a -Os
LDFLAGS=-Wl,-gc-sections -Wl,-relax
CC=avr-gcc

out/%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

out/%.elf: out/%.o
	$(CC) $(CFLAGS) $(LDFLAGS) $< -o $@

out/%.hex: out/%.elf
	avr-objcopy -R .eeprom -O ihex $< $@

clean:
	rm -rf out

build:
	mkdir out
	make out/main.hex

upload: out/main.hex
	sudo avrdude -c stk500v2 -P "$(PORT)" -p m324a -U flash:w:$<:i

default:
	make clean
	make build
	make upload

.PHONY: build upload clean default
.DEFAULT_GOAL := default
