
		AREA    tan,CODE,READONLY
		import printMsg
		import printMsg1
		import printMsg2
		import printMsg3	
        EXPORT __main
        ENTRY
__main    FUNCTION
		VLDR.F32 S0, =5	;VALUE 0F X.
		VLDR.F32 S1, =100		;VALUE OF RADIUS(r).
		MOV R1, #10			;NUMBER OF TERMS IN SERIES TO BE CALCULATED,n
		VMOV.F32 S2, #1		;INITIALIZING THE REGISTER TO SAVE THE VALUE OF FACTORIALS.
		VMOV.F32 S5, #1		;INITIALIZING THE REGISTER TO SAVE THE POWER.
		VLDR.F32 S6, =0		;INITIALIZING THE REGISTER TO SAVE THE SUM.
		VMOV.F32 S15, #10
		MOV R8, #0
		VLDR.F32 S11, =0	;X-COORDINATES OF CENTRE(A)
		VLDR.F32 S12, =0	;Y-COORDINATES OF CENTRE(B)
		MOV R2, #1
		MOV R10, #-1	
		MOV R9, #0		;FOR CHECKING EVEN/ODD
		VLDR.F32 S10, =0.0174533	;SAVING THE VALUE OF 1 DEGREE INTO RADIAN 
		VMUL.F32 S0, S0, S10		;CONVERTING DEGREE TO RADIAN		
		VMUL.F32 S15, S15, S10
		VLDR.F32 S9, =265
		VMUL.F32 S9, S9, S10
		VLDR.F32 S8, =0			
		B CREATE_CIRCLE


;THIS LOOP WILL CHANGE THETA FROM 0 TO 360
CREATE_CIRCLE	VADD.F32 S0, S0, S15
				vmov.f32 R0, S0
				BL printMsg3
				MOV R7, #1
				MOV R1, #10
				MOV R2, #1
				MOV R9, #0
				VMOV.F32 S5, S0
				VLDR.F32 S6, =0
				VCMP.F32 S0, S9	
				ADD R8, R8, #1
				VMRS APSR_NZCV, FPSCR	
				BGT STOP				
				BLE SIN					
				

;THIS FUNCTION WILL BE USED TO CALCULATE THE FACTORIAL OF A NUMBER.
;THE NUMBER WHOSE FACTORIAL IS TO BE CALCULATED WILL BE STORED IN R3.
;THE FACTORIAL WILL BE STORED IN S2.
FACT 	VMOV S3, R3			;MOVING THE VALUE OF CORE REGISTER TO FP REGISTER
		VCVT.F32.U32 S3, S3	;CONVERTING THE FLOATING POINT REGISTER TO DECIMAL NUMBER
		VMUL.F32 S2, S2, S3	;CALCULATING FACTORIAL
		SUB R3, R3, #1		;DECREMENTING n
		CMP R3, #1			
		BGT FACT
		BLE SUM_CAL


;THIS FUNCTION IS TO DETERMINE THE TERM WILL BE ADDED OR SUBTRACTED BASED ON IF IT IS EVEN OR ODD.
NEGATE	CMP R9, #1			;1 MEANS ODD, 0 MEANS EVEN
		BEQ ODD
		BNE EVEN

;THIS FUNCTION IS TO NEGATE THE VALUE THAT IS TO BE ADDED.
ODD		SUB R9, R9, #1		;CHANGING REGISTER SO THAT NEXT VALUE WILL BE POSITIVE
		VNEG.F32 S2, S2		;NEGATE STATEMENT
		B FACT				;BRANCH TO FACT

EVEN	ADD R9, R9, #1		;CHANGING REGISTER SO THAT NEXT VALUE WILL BE NEGATIVE
		B FACT				;BRANCH TO FACT


;THIS FUNCTION IS USED TO CALCULATE THE POWERS OF X.
POWER	VMUL.F32 S5, S5, S0		;THIS CREATES *X
		VMUL.F32 S5, S5, S0		;THIS MAKES IT *X^2
		BLX LR
	
SUM_CAL  	CMP R7, #1
			BEQ SUM_SIN
			BNE SUM_COS

;THIS FUNCTION IS USED TO CALCULATE THE VALUE OF SIN OR COS
;IT FIRST DETERMINE EACH TERM OF THE EXPANSION SERIES AND THEN ADDS IT TO THE SUM.
SUM_SIN		VDIV.F32 S7, S5, S2		;TERM OF THE EXPANSION
			VADD.F32 S6, S6, S7		;ADDING THE TERM TO THE SUM
			BL POWER				;CALCULATING THE POWER OF X FOR THE NEXT TERM.
			B SIN
		
SUM_COS		VDIV.F32 S7, S5, S2		;TERM OF THE EXPANSION
			VADD.F32 S6, S6, S7		;ADDING THE TERM TO THE SUM
			BL POWER				;CALCULATING THE POWER OF X FOR THE NEXT TERM.
			B COS
		

;THIS FUNCTION WILL BE CALCULATING THE SIN(X).
;IT WILL DO THIS BY USING A LOOP.
SIN		MOV R7, #1
		ADD R10, R10, #2			;INCREMENT IS BY 2 BECAUSE ALTERNATE POWERS OF X ARE PRESENT IN THE SERIES EXPANSION.
		MOV R3, R10
		VMOV.F32 S2, #1
		CMP R10, R1					;COMPARING FOR THE NUMBER OF TERMS IN THE SERIES.
		BLT NEGATE					;R10-1 NO. OF TERMS
		B COS_INI


;THIS FUNCTION IS TO INITIALIZE THE REGISTER VALUES FOR DETERMINING THE COS(X).
COS_INI	MOV R9, #1	
		MOV R10, #0
		VMUL.F32 S5, S0, S0		;CALCULATING X^2
		VMOV.F32 S8, S6			;SAVING SIN VALUE
		VCMP.F32 S8, #0
		VMRS APSR_NZCV, FPSCR	
		BEQ PASS
		VMOV.F32 S6, #1			;SUM=1
		B COS					;BRANCHING TO COS

SIN_INI		MOV R10, #-1
			BLX LR

PASS	VLDR.F32 S6, =0
		
		
;THIS FUNCTION IS USED TO CALCULATE COS(X)
COS		MOV R7, #0
		ADD R10, R10, #2	;INCREMENT IS BY 2 BECAUSE ALTERNATE POWERS OF X ARE PRESENT IN THE SERIES EXPANSION.
		MOV R3, R10
		VMOV.F32 S2, #1
		CMP R10, R1			;COMPARING FOR THE NUMBER OF TERMS IN THE SERIES.
		BLT NEGATE			;R10 NO. OF TERMS
		;BL SIN_INI
		B CALC_X_Y


CALC_X_Y	VMOV.F32 S13, #1
			VMOV.F32 S14, #1
			VMUL.F32 S13, S1, S6		;X=rCOS(Q)
			VADD.F32 S13, S13, S11		;X=A+RCOS(Q)
			vmov.f32 r0, s13
			bl printMsg
			VMUL.F32 S14, S1, S8		;Y=rSIN(Q)
			VADD.F32 S14, S14, S12		;Y=B+RSIN(Q)
			vmov.f32 r0, s14
			bl printMsg1
			MOV R10, #-1
			B CREATE_CIRCLE


;THIS IS USED TO STOP THE EXECUTION
STOP    B STOP
        ENDFUNC
        END
			