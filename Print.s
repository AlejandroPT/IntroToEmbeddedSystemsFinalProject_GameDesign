; Print.s
; Student names: change this to your names or look very silly
; Last modification date: change this to the last modification date or look very silly
; Runs on LM4F120 or TM4C123
; EE319K lab 7 device driver for any LCD
;
; As part of Lab 7, students need to implement these LCD_OutDec and LCD_OutFix
; This driver assumes two low-level LCD functions
; ST7735_OutChar   outputs a single 8-bit ASCII character
; ST7735_OutString outputs a null-terminated string 

    IMPORT   ST7735_OutChar
    IMPORT   ST7735_OutString
    EXPORT   LCD_OutDec
    EXPORT   LCD_OutFix
n 		EQU			0

    AREA    |.text|, CODE, READONLY, ALIGN=2
    THUMB

  

;-----------------------LCD_OutDec-----------------------
; Output a 32-bit number in unsigned decimal format
; Input: R0 (call by value) 32-bit unsigned number
; Output: none
; Invariables: This function must not permanently modify registers R4 to R11
LCD_OutDec
;*******Allocation Phase******	
	PUSH {R0,LR}			
	SUB  SP, #8													 
;*******Access Phase******								
	CMP  R0, #10							; charcter <10?
	BLO  Oend								; if so finish
	MOV  R1, #10							; divisor
	UDIV R12, R0, R1						; divide by 10
	MUL  R1,  R12, R1						; n/10*10
	SUB  R0, R1								; n%100	
	STR  R0, [SP, #n]							;
	MOV  R0, R12							; divisor from before
	BL LCD_OutDec
	LDR R0, [SP, #n]
Oend										
	ADD R0, #0x30							; ascii
	BL ST7735_OutChar						; output
;*******Deallocation phase******	
	
	ADD SP, #8								; deallocate
	POP {R0,PC}

      BX  LR
;* * * * * * * * End of LCD_OutDec * * * * * * * *

; -----------------------LCD _OutFix----------------------
; Output characters to LCD display in fixed-point format
; unsigned decimal, resolution 0.001, range 0.000 to 9.999
; Inputs:  R0 is an unsigned 32-bit number
; Outputs: none
; E.g., R0=0,    then output "0.000 "
;       R0=3,    then output "0.003 "
;       R0=89,   then output "0.089 "
;       R0=123,  then output "0.123 "
;       R0=9999, then output "9.999 "
;       R0>9999, then output "*.*** "
; Invariables: This function must not permanently modify registers R4 to R11
LCD_OutFix	
	PUSH{R0,LR}
	SUB SP,#8 ;allocate 3 variables
	MOV R2, #10000
	CMP R0, R2
	BLO Fix10000
	MOV R0, #'*'				
	BL ST7735_OutChar			;*
	MOV R0, #'.'
	BL ST7735_OutChar			;*.
	MOV R0, #'*'
	BL ST7735_OutChar			;*.*
	MOV R0, #'*'
	BL ST7735_OutChar			;*.**
	MOV R0, #'*'
	BL ST7735_OutChar			;*.***
	B finish							
Fix10000					;For when n is smaller than 10000	
	
	MOV R1,R0
	MOV R2,#1000 
	UDIV R0, R1, R2
	MUL R3, R0, R2
	SUB R1,R1,R3
	ADD R0,R0,#'0'
	STR R1,[SP,#n]
	BL ST7735_OutChar
	
	
	MOV R0,#'.'
	BL ST7735_OutChar
	
	MOV R2,#100 
	LDR R1,[SP,#n]
	UDIV R0, R1, R2
	MUL R3, R0, R2
	SUB R1,R1,R3
	ADD R0,R0,#'0'
	STR R1,[SP,#n]
	BL ST7735_OutChar
	
	MOV R2,#10
	LDR R1,[SP,#n]
	UDIV R0, R1, R2
	MUL R3, R0, R2
	SUB R1,R1,R3
	ADD R0,R0,#'0'
	STR R1,[SP,#n]
	BL ST7735_OutChar
	
	LDR R1,[SP,#n]
	ADD R0,R1,#'0'
	BL ST7735_OutChar

	


finish							;falsta hacer el finish	
	ADD SP,#8
	POP {R0,LR}

     BX   LR
 
     ALIGN
;* * * * * * * * End of LCD_OutFix * * * * * * * *

     ALIGN                           ; make sure the end of this section is aligned
     END                             ; end of file
