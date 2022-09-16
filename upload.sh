#!/bin/bash
avra main.asm
sudo avrdude -c stk500v2 -P $(pavr2cmd --prog-port) -p m324a -U flash:w:main.hex:i
