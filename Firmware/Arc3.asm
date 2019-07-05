;M0 & M1 are the port numbers for the motors
;PWM1 is motor 1 speed (0-15)
;PWM2 is motor 2 speed (0-15)
DoPWM        bsf    Shadow,M0    ;turn motor 0 on
        bsf    Shadow,M1    ;and motor 1
        movlw    1        ;preload W
PwmLoop        subwf    PWM1,F        ;sub 1 from PWM1
        btfss    STATUS,DC    ;was there a borrow from bit 4
        bcf    Shadow,M0    ;yes so turn motor 0 off
        subwf    PWM2,F        ;now do second channel
        btfss    STATUS,DC
        bcf    Shadow,M1
        movfw    Shadow        ;copy shadow register
        movwf    GPIO        ;to I/O register
        movlw    1        ;reload W
        addwf    Count,F        ;inc count but set flags
        btfss    STATUS,DC    ;have we been around 16 times
        goto    PwmLoop        ;no, so go around inner loop
        btfss    STATUS,Z    ;have we done 256 times
        goto    DoPWM        ;no so repeat outer loop
        retlw    0        ;done