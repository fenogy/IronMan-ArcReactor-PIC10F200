movlw	b'11000011'		
	option					;set timer to prescale of 16
 
chk_1
	movf		dutyc_msb, w	;collect time
	subwf		timer,w		;subtract, result in w
	btfsc		status, carry	;see if time is less than w (dutyc_msb)
	goto		chk_1		; If it is, output a 1
 
;we now want to wait until the next increment of the timer,
;trap the time exactly, 
;In this direction, timer=0 here, so we are trying to find when it 
;hits 1
 
   	nop		;timer now at 0, wait a bit
	movlw	0x02
	movwf	count1
wait
	decfsz	count1,f
	goto		wait                          ;short pause needed
 
	clrw		; This is the minimum number of steps
	addwf	timer,w	;1st place timer hits 1
	addwf	timer,w	;2nd	
	addwf	timer,w	;3rd
	addwf	timer,w	;4th
 
;w is now between 0 and 4
 
	andlw 	0x07		;shouldn't be needed
	addwf	pc, f		;increment PC restore timing
	nop
	nop
	nop
	nop
 
	movlw	0x05
	movwf	count1
wait2
	decfsz	count1,f
	goto 	        wait2
 
	nop		;These get the mark space ratio equal to dutyc
 
	bsf		out_dc_port, out_dc	;output 1
 
;the calulation done if duty cycle is below half
 
	btfsc		dutyc_msb, 7
	goto		run
 
;	Output is high when chk_0 is running. 
;	dutyc_msb>time, so w>timer at the subtract
;	so carry is not set
;	When time equals result_time, w<=timer at the subract
;	so carry is set and 0 is output
 
chk_0	
        movf		dutyc_msb, w	;collect time
	subwf		timer,w		;subtract, result in w
	btfss		status, carry	;see if time is >= than w (dutyc_msb)
	goto		chk_0		
 
;we now want to wait until the next increment of the timer,
;trap the time exactly, 
;In this direction, timer=0 here, so we are trying to find when it 
;hits 1
 
	swapf		dutyc_lsb,w	; collect the lsb word, biggest half
	movwf	count1		; put in count 1
	clrf		count2		; 
	subwf		count2,f	; get the negative 
	movlw	0x03		;
	andwf	count2,f	; bits 0 and 1 only.
				;This part must be 6 cycles long exactly
				;to be ready for the following bit
 
	clrw
	btfsc		dutyc_msb,0	;
	iorlw		0x04		
;This is so that we get the same last 3 bits after the additions
 
	addwf	timer,w	;1st place timer hits 1
	addwf	timer,w	;2nd	
	addwf	timer,w	;3rd
	addwf	timer,w	;4th
	andlw		0x07		;take last 3 bit only
 
;w is now between 0 and 4
	addwf	pc, f		;increment PC restore timing
	nop
	nop
	nop
	nop	;this has to be here for restoring timing
 
	rrf		count1,f	;
	rrf		count1,f	;
	movlw	0x03		;
	andwf	count1,f	;
	incf		count1, f
 
time1
	nop
	decfsz	count1,f	;
	goto		time1		;This is to add cycles for bits 8 and 9
						;of duty cycle. Each count of bit 9 represents 4 cycles
 
	swapf		dutyc_lsb,w	;This adds the next two bits of dutyc_lsb
	movwf	count1		;bits 4 and 5 
	comf		count1,f	
	movlw	0x03
	andwf	count1,w
	addwf	pc,f
 
	nop
	nop
	nop
 
	bcf		out_dc_port,  out_dc	;output 0
;this happens dutyc_lsb (bits 4 - 7 only)
;clock cycles after the timer gets to 2 more than dutyc_msb
 
;The calculation done if duty cycle is below half
 
	btfsc		dutyc_msb, 7
	goto		chk_1		;wait for timer
 
run
 
;This is where your calculation code goes
 
calc_fin
 
	clrwdt			;reset watchdog
 
; Check output state. we mustn't come back
; here before checking the output state.
 
	btfsc		out_dc_port,  out_dc	
	goto		chk_0		
	goto		chk_1