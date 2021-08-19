ORG 0000H
MOV P1,#00H
MOV P0,#00H
MOV DPTR, #LUT  

MAIN: MOV R6,#230D         // loads register R6 with 230D
      SETB P3.5            // sets P3.5 as input port
      MOV  TMOD ,#61H // Sets Timer1 as Mode2 counter & Timer0 as Mode1 timer
      MOV TL1,#00000000B   // loads TL1 with initial value
      MOV TH1,#00000000B   // loads TH1 with initial value
      SETB TR1             // starts timer(counter) 1
BACK: MOV TH0,#00000000B   // loads initial value to TH0
      MOV TL0,#00000000B   // loads initial value to TL0
      SETB TR0             // starts timer 0
HERE: JNB TF0,HERE         // checks for Timer 0 roll over
      CLR TR0              // stops Timer0
      CLR TF0              // clears Timer Flag 0
      DJNZ R6,BACK
      CLR TR1              // stops Timer(counter)1
      CLR TF0              // clears Timer Flag 0
      CLR TF1              // clears Timer Flag 1
      ACALL BPM         // Calls subroutine DLOOP for displaying the count
      SJMP MAIN            // jumps back to the main loop
BPM: MOV R5,#100D
BACK1: MOV A,TL1          // loads the current count to the accumulator
       MOV B,#4D           // loads register B with 4D
       MUL AB  	   // Multiplies the TL1 count with 4
	   MOV R2,A
	   ACALL BUZZER
	   MOV A,R2
       MOV B,#100D         // loads register B with 100D
       DIV AB              // isolates first digit of the count
       SETB P1.0           // display driver transistor Q1 ON
       ACALL DISPLAY       // converts 1st digit to 7seg pattern
      
       
       MOV A,B
       MOV B,#10D
       DIV AB              // isolates the second digit of the count
       CLR P1.0            // display driver transistor Q1 OFF
       SETB P1.1           // display driver transistor Q2 ON
       ACALL DISPLAY       // converts the 2nd digit to 7seg pattern
       
       MOV A,B             // moves the last digit of the count to accumulator
       CLR P1.1            // display driver transistor Q2 OFF
       SETB P1.2           // display driver transistor Q3 ON
       ACALL DISPLAY       // converts 3rd digit to 7seg pattern
       
       CLR P1.2
	   ACALL BUZZER
	   DJNZ R5,BACK1       // repeats the subroutine DLOOP 100 times
       RET

DISPLAY: MOVC  A,@A+DPTR 	
          CPL A// gets 7seg digit drive pattern for current value in A
         MOV  P2,A            // puts the pattern to port 0
	     ACALL DELAY
	     RET
		 
		 
DELAY: MOV R0,#14
LOOP1: MOV R1,#0FFH
LOOP2:DJNZ R1,LOOP2
	  DJNZ R0,LOOP1
RET

BUZZER:
       MOV B,#60
       SUBB A,B
	   MOV C,ACC.7
	   JNC MORE
	   ACALL RING
  MORE:MOV A,#40
	   MOV B,#120
	   SUBB A,B
	   MOV C,ACC.7
	   JC CONT 
	   ACALL RING 
CONT:RET
  RING:SETB P1.3
	 CLR P1.3
	 RET

	 

LUT: DB 0FCH                // LUT starts here
     DB 60H
     DB 0DAH
     DB 0F2H
     DB 66H
     DB 0B6H
     DB 0BEH
     DB 0E0H
     DB 0FEH
     DB 0E6H
END
