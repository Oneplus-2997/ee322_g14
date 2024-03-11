;------------------------
; Assembly Code
;------------------------
;#define __SFR_OFFSET 0x00
;#include "avr/io.h"
;------------------------
;.global servo_motor
;===============================================================
.include "M328PDEF.INC" 

;rotate_pos:.DB 10,20,30,40,50,60,70,80	;90->0
;===============================================================

servo_motor:
;-----------
    SBI   DDRB, 4         ;pin PB4 o/p for servo control

;---------------------------------------------------------------

l1: LDI   R16, 70         ;load rotation pos
    RCALL rotate_servo    ;& rotate servo
    ;-----------------------------------------------------------
    RJMP  l1           ;go back & repeat
;---------------------------------------------------------------

rotate_servo:
;------------
    LDI   R17, 10         ;count to give enough cycles of PWM
l2: SBI   PORTB, 4
    RCALL delay_timer0
    CBI   PORTB, 4        ;send msec pulse to rotate servo
    RCALL delay_20ms      ;wait 20ms before re-sending pulse
    DEC   R17
    BRNE  l2              ;go back & repeat PWM signal
    ;-----------------------------------------------------------

bak:RCALL delay_ms        ;0.5s delay
    RET                   ;& return to main subroutine
;-------------------

;===============================================================
;delay subroutines
;===============================================================
delay_timer0:             ;delay via Timer0
    ;-----------------------------------------------------------
    CLR   R18
    OUT   TCNT0, R18      ;initialize timer0 with count=0
    MOV   R18, R16
    OUT   OCR0A, R18
    LDI   R18, 0b00001100
    OUT   TCCR0B, R18     ;timer0: CTC mode, prescaler 256
    ;-----------------------------------------------------------
l3: IN    R18, TIFR0      ;get TIFR0 byte & check
    SBRS  R18, OCF0A      ;if OCF0=1, skip next instruction
    RJMP  l3              ;else, loop back & check OCF0 flag
    ;-----------------------------------------------------------
    CLR   R18
    OUT   TCCR0B, R18     ;stop timer0
    ;-----------------------------------------------------------
    LDI   R18, (1<<OCF0A)
    OUT   TIFR0, R18      ;clear OCF0 flag
    RET
;===============================================================
delay_20ms:               ;delay 20ms
    LDI   R18, 255
l4: LDI   R19, 210
l5: LDI   R20, 2
l6: DEC   R20
    BRNE  l6
    DEC   R19
    BRNE  l5
    DEC   R18
    BRNE  l4
    RET
;===============================================================
delay_ms:                 ;delay 0.5s
    LDI   R18, 255
l7: LDI   R19, 255
l8: LDI   R20, 41
l9: DEC   R20
    BRNE  l9
    DEC   R19
    BRNE  l8
    DEC   R18
    BRNE  l7
    RET