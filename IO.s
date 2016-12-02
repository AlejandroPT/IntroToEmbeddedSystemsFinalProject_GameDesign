 ; IO.s
; Student names: Alejandro Paez Touche & Rogelio Salomon
; Last modification date: 10/24/16
; Runs on LM4F120/TM4C123

; EE319K lab 7 device driver for the switch and LED.
; You are allowed to use any switch and any LED,
; although the Lab suggests the SW1 switch PF4 and Red LED PF1

; As part of Lab 7, students need to implement these three functions

; negative logic SW2 connected to PF0 on the Launchpad
; red LED connected to PF1 on the Launchpad
; blue LED connected to PF2 on the Launchpad
; green LED connected to PF3 on the Launchpad
; negative logic SW1 connected to PF4 on the Launchpad

        EXPORT   IO_Init
        EXPORT   IO_Touch
        EXPORT   IO_HeartBeat
		EXPORT 	 IO_Button1
		EXPORT 	 IO_Button2	

GPIO_PORTF_DATA_R  EQU 0x400253FC
GPIO_PORTF_DIR_R   EQU 0x40025400
GPIO_PORTF_AFSEL_R EQU 0x40025420
GPIO_PORTF_PUR_R   EQU 0x40025510
GPIO_PORTF_DEN_R   EQU 0x4002551C
GPIO_PORTF_LOCK_R  EQU 0x40025520
GPIO_PORTF_CR_R    EQU 0x40025524
GPIO_PORTF_AMSEL_R EQU 0x40025528
GPIO_PORTF_PCTL_R  EQU 0x4002552C
GPIO_LOCK_KEY      EQU 0x4C4F434B  ; Unlocks the GPIO_CR register
PF0       EQU 0x40025004
PF1       EQU 0x40025008
PF2       EQU 0x40025010
PF3       EQU 0x40025020
PF4       EQU 0x40025040
LEDS      EQU 0x40025038
RED       EQU 0x02
BLUE      EQU 0x04
GREEN     EQU 0x08
SWITCHES  EQU 0x40025044
SW1       EQU 0x10                 ; on the left side of the Launchpad board
SW2       EQU 0x01                 ; on the right side of the Launchpad board
SYSCTL_RCGCGPIO_R  EQU 0x400FE608
    
        AREA    |.text|, CODE, READONLY, ALIGN=2
        THUMB



;------------IO_Init------------
; Initialize GPIO Port for a switch and an LED
; Input: none
; Output: none
; This is a public function
; Invariables: This function must not permanently modify registers R4 to R11
IO_Init
    LDR R1, =SYSCTL_RCGCGPIO_R
	LDR R0, [R1]
	ORR R0,R0, #0x20
	STR R0, [R1]
	NOP
	NOP
	
	LDR R1, =GPIO_PORTF_DIR_R
	LDR R0, [R1]
	ORR R0,R0, #0x02		;output PF1
	BIC R0,R0, #0x14		;input PF4
	STR R0, [R1]
	
	LDR R1, =GPIO_PORTF_AFSEL_R
	LDR R0, [R1]
	MOV R0, #0x00			
	STR R0, [R1]
	
	LDR R1, =GPIO_PORTF_DEN_R
	LDR R0, [R1]
	ORR R0, #0x16
	STR R0, [R1]
    
    BX  LR
;* * * * * * * * End of IO_Init * * * * * * * *

;------------IO_HeartBeat------------
; Toggle the output state of the LED.
; Input: none
; Output: none
; This is a public function
; Invariables: This function must not permanently modify registers R4 to R11
IO_HeartBeat
    LDR R1, =GPIO_PORTF_DATA_R 
	LDR R0, [R1]
	EOR R0,R0,0x02
	STR R0, [R1]
    
    BX  LR                          ; return
;* * * * * * * * End of IO_HeartBeat * * * * * * * *

;------------IO_Touch------------
; First: wait for the of the release of the switch
; and then: wait for the touch of the switch
; Input: none
; Input: none
; Output: none
; This is a public function
; Invariables: This function must not permanently modify registers R4 to R11
IO_Button1
	LDR R1, =GPIO_PORTF_DATA_R 
	LDR R0, [R1]
	AND R0,R0, 0x10
	
	BX LR
	
IO_Button2
	LDR R1, =GPIO_PORTF_DATA_R 
	LDR R0, [R1]
	AND R0,R0, 0x01
	
	BX LR

IO_Touch
	LDR R1, =GPIO_PORTF_DATA_R 
	LDR R0, [R1]
	AND R0,R0, 0x10
	CMP R0, 0x10
	BNE IO_Touch
;loop 
	;MOV R2, #2600					; outer loop counter
;inner	
	;MOV R12, #1000					; wait loop counter
	;B 	wait						; branch to inner wait loop
;return
	;SUBS R2, R2, #1					; decrease outer loop counter
	;BNE	inner						; branch if z bit is not set
IO_Touch2
	LDR R0, [R1]
	AND R0,R0, 0x10
	CMP R0,0x10
	BEQ IO_Touch2

    BX  LR                          ; return
;* * * * * * * * End of IO_Touch * * * * * * * *

;***********************Wait************************************	   
; Input R5: number to decreased to decrease from
; time_min = R5* 1+1 /16 us
; time_max = R5* 1+4 /16 us
;wait
	;SUBS R12, R12, #1 ; use actual number #1
	;BNE		wait
	;B		return
	
;****************************************************************	

    ALIGN                           ; make sure the end of this section is aligned
    END                             ; end of file