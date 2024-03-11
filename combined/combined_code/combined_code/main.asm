;
; combined_code.asm
;
; Created: 3/10/2024 10:48:48 PM
; Author : Mario
;


.include "m328pdef.inc"
rotate_pos:.DB 40,70,92,110,180,110,90,70

.cseg
.org	0x00

setup:
    LDI R16, 0b10000010
    OUT DDRB, R16

again:     
    LDI   R26, 8          ;counter for # of rotation pos
    LDI   ZL, LOW(rotate_pos)
    LDI   ZH, HIGH(rotate_pos)

rotate: 
    LPM   R24, Z+         ;load rotation pos
    RCALL rotate_servo    ;& rotate servo

loop:




    DEC   R26
    BRNE  rotate              ;go back & get another rotate pos
    ;-----------------------------------------------------------
    RJMP  again           ;go back & repeat
;--------------------------------------------