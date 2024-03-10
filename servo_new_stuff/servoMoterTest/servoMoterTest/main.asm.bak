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
    ;SBI   DDRB, 0         ;PB0 o/p, red LED: pos 0 deg
    ;SBI   DDRB, 1         ;PB1 o/p, green LED: pos 90 deg
    ;SBI   DDRB, 2         ;PB2 o/p, blue LED: pos 180 deg
;---------------------------------------------------------------
again:     
    ;LDI   R25, 1          ;counter for LED control
    ;LDI   R26, 8          ;counter for # of rotation pos
    ;LDI   ZL, LOW(rotate_pos)
    ;LDI   ZH, HIGH(rotate_pos)
    ;-----------------------------------------------------------
l1: LDI   R24, 70         ;load rotation pos
    RCALL rotate_servo    ;& rotate servo
    ;DEC   R26
    ;BRNE  l1              ;go back & get another rotate pos
    ;-----------------------------------------------------------
    RJMP  l1           ;go back & repeat
;---------------------------------------------------------------

rotate_servo:
;------------
    LDI   R20, 10         ;count to give enough cycles of PWM
l2: SBI   PORTB, 4
    RCALL delay_timer0
    CBI   PORTB, 4        ;send msec pulse to rotate servo
    RCALL delay_20ms      ;wait 20ms before re-sending pulse
    DEC   R20
    BRNE  l2              ;go back & repeat PWM signal
    ;-----------------------------------------------------------
    ;CPI   R25, 1
    ;BREQ  red_LED         ;if pos 0 deg, turn ON red LED
    ;CPI   R25, 3
    ;BREQ  green_LED       ;if pos 90 deg, turn ON green LED
    ;CPI   R25, 5
    ;BREQ  blue_LED        ;if pos 180 deg, turn ON blue LED
    ;CPI   R25, 7
    ;BREQ  green_LED       ;if pos 90 deg, turn ON green LED
bak:RCALL delay_ms        ;0.5s delay
    ;CBI   PORTB, 0
    ;CBI   PORTB, 1
    ;CBI   PORTB, 2        ;turn OFF all LEDs
    ;INC   R25
    RET                   ;& return to main subroutine
;-------------------
red_LED:                  ;subroutine to turn ON red LED
    ;SBI   PORTB, 0
    ;CBI   PORTB, 1
    ;CBI   PORTB, 2
    ;RJMP  bak
;------------------
green_LED:                ;subroutine to turn ON green LED
    ;CBI   PORTB, 0
    ;SBI   PORTB, 1
    ;CBI   PORTB, 2
    ;RJMP  bak
;------------------
blue_LED:                 ;subroutine to turn ON blue LED
    ;CBI   PORTB, 0
    ;CBI   PORTB, 1
    ;SBI   PORTB, 2
    ;RJMP  bak
;===============================================================
;delay subroutines
;===============================================================
delay_timer0:             ;delay via Timer0
    ;-----------------------------------------------------------
    CLR   R21
    OUT   TCNT0, R21      ;initialize timer0 with count=0
    MOV   R21, R24
    OUT   OCR0A, R21
    LDI   R21, 0b00001100
    OUT   TCCR0B, R21     ;timer0: CTC mode, prescaler 256
    ;-----------------------------------------------------------
l3: IN    R21, TIFR0      ;get TIFR0 byte & check
    SBRS  R21, OCF0A      ;if OCF0=1, skip next instruction
    RJMP  l3              ;else, loop back & check OCF0 flag
    ;-----------------------------------------------------------
    CLR   R21
    OUT   TCCR0B, R21     ;stop timer0
    ;-----------------------------------------------------------
    LDI   R21, (1<<OCF0A)
    OUT   TIFR0, R21      ;clear OCF0 flag
    RET
;===============================================================
delay_20ms:               ;delay 20ms
    LDI   R21, 255
l4: LDI   R22, 210
l5: LDI   R23, 2
l6: DEC   R23
    BRNE  l6
    DEC   R22
    BRNE  l5
    DEC   R21
    BRNE  l4
    RET
;===============================================================
delay_ms:                 ;delay 0.5s
    LDI   R21, 255
l7: LDI   R22, 255
l8: LDI   R23, 41
l9: DEC   R23
    BRNE  l9
    DEC   R22
    BRNE  l8
    DEC   R21
    BRNE  l7
    RET