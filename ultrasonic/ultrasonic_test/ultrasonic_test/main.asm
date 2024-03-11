; Project_UltraSound.asm
;
; Created: 1/1/2024 8:46:00 AM
; Author : E19344_T.D.SAMARASEKERA
;


; Replace with your application code
.include "m328pdef.inc"
.cseg
.org	0x00



    SBI   DDRB, 1         ;pin PB1 as o/p (Trigger)
    CBI   DDRB, 0         ;pin PB0 as i/p (Echo)
    ;-----------------------------------------------------------
agn:SBI   PORTB, 1
    RCALL delay_timer1
    CBI   PORTB, 1        ;send 10us high pulse to sensor
    ;-----------------------------------------------------------
    RCALL echo_PW			;compute Echo pulse width count

echo_PW:
;-------
    LDI   R22, 0b00000000
    STS   TCCR1A, R22     ;Timer 1 normal mode
    LDI   R22, 0b11000101 ;set for rising edge detection &
    STS   TCCR1B, R22     ;prescaler=1024, noise cancellation ON

la: IN    R21, TIFR1
    SBRS  R21, ICF1
    RJMP  la              ;loop until rising edge is detected
    ;-----------------------------------------------------------
    LDS   R16, ICR1L      ;store count value at rising edge
    ;-----------------------------------------------------------
    ;*****not sure why we should have this line OUT   TIFR1, R21      ;clear flag for falling edge detection
    LDI   R22, 0b10000101
    STS   TCCR1B, R22     ;set for falling edge detection
    ;-----------------------------------------------------------
lb: IN    R21, TIFR1
    SBRS  R21, ICF1
    RJMP  lb              ;loop until falling edge is detected
    ;-----------------------------------------------------------
    LDS   R28, ICR1L      ;store count value at falling edge
    ;-----------------------------------------------------------
    SUB   R28, R16        ;count diff R22 = R22 - R16
    ;*****not sure why we should have this line OUT   TIFR1, R21      ;clear flag for next sensor reading
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