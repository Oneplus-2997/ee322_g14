;
; combined_code.asm
;
; Created: 3/10/2024 10:48:48 PM
; Author : Mario
;


.include "m328pdef.inc"
rotate_pos:.DB 40,70,92,110,180,110,90,70

.cseg

setup:
    LDI R16, 0b10000010
    OUT DDRB, R16
    LDI R29, 0
    LDI R30, 0
    LDI R31, 0b00011110

again:     
    LDI R26, 8          ;counter for # of rotation pos
    LDI ZL, LOW(rotate_pos)
    LDI ZH, HIGH(rotate_pos)

rotate: 
    LPM R24, Z+         ;load rotation pos for positive rotation
    RCALL rotate_servo    ;& rotate servo
    RJMP loop

loop:
    SBI PORTB, 1
    RCALL delay_timer1
    CBI   PORTB, 1        ;send 10us high pulse to sensor
    ;-----------------------------------------------------------
    RCALL echo_PW			;compute Echo pulse width count

echo_PW:
;-------
    LDI R22, 0b00000000
    STS TCCR1A, R22     ;Timer 1 normal mode
    CPI R29, 0
    BRNE neg_det

pos_det:
    LDI   R22, 0b11000101 ;set for rising edge detection &
    STS   TCCR1B, R22     ;prescaler=1024, noise cancellation ON
    IN    R21, TIFR1
    SBRS  R21, ICF1
    RJMP end_rot

    ;If rising edge detected
    LDS R16, ICR1L      ;store count value at rising edge
    LDI R29, 1
    RJMP end_rot

neg_det:
    LDI   R22, 0b10000101
    STS   TCCR1B, R22     ;set for falling edge detection
    IN    R21, TIFR1
    SBRS  R21, ICF1
    RJMP end_rot

    ;If falling edge detected
    LDS R28, ICR1L      ;store count value at falling edge
    LDI R29, 0

    SUB R28, R16        ;count diff R28 = R28 - R16
    CP R28, R31
    BRGE rev_dir
    RJMP end_rot

rev_dir:
    CPI R30, 0
    BRNE rev_to_pos
    LDI R30, 1
    RJMP end_rot

rev_to_pos:
    LDI R30, 0
    RJMP end_rot

end_rot:
    CPI R30, 0
    BRNE rot_neg

rot_pos:
    DEC R26
    BRNE rotate              ;go back & get another rotate pos
    ;-----------------------------------------------------------
    RJMP again           ;go back & repeat
;--------------------------------------------

rot_neg:
    INC R26
    CPI R26, 8
    BRNE rotate              ;go back & get another rotate pos
    ;-----------------------------------------------------------
    RJMP again           ;go back & repeat
;--------------------------------------------




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

delay_timer1:             ;10 usec delay via Timer 1
;------------
    CLR   R22
    OUT   TCNT0, R22      ;initialize timer0 with count=0
    LDI   R22, 20
    OUT   OCR0A, R22      ;OCR0 = 20
    LDI   R22, 0b00001010
    OUT   TCCR0B, R22     ;timer0: CTC mode, prescaler 8
    ;-----------------------------------------------------------
lc: IN    R22, TIFR0      ;get TIFR0 byte & check
    SBRS  R22, OCF0A      ;if OCF0=1, skip next instruction
    RJMP  lc              ;else, loop back & check OCF0 flag
    ;-----------------------------------------------------------
    CLR   R22
    OUT   TCCR0B, R22     ;stop timer1
    ;-----------------------------------------------------------
    LDI   R22, (1<<OCF0A)
    OUT   TIFR0, R22      ;clear OCF0 flag
    RET