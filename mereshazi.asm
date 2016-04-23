;*************************************************************** 
;* Feladat: 
;* Rövid leírás:
; 
;* Szerzõk: 
;* Mérõcsoport: <merocsoport jele>
;
;***************************************************************
;* "AVR ExperimentBoard" port assignment information:
;***************************************************************
;*
;* LED0(P):PortC.0          LED4(P):PortC.4
;* LED1(P):PortC.1          LED5(P):PortC.5
;* LED2(S):PortC.2          LED6(S):PortC.6
;* LED3(Z):PortC.3          LED7(Z):PortC.7        INT:PortE.4
;*
;* SW0:PortG.0     SW1:PortG.1     SW2:PortG.4     SW3:PortG.3
;* 
;* BT0:PortE.5     BT1:PortE.6     BT2:PortE.7     BT3:PortB.7
;*
;***************************************************************
;*
;* AIN:PortF.0     NTK:PortF.1    OPTO:PortF.2     POT:PortF.3
;*
;***************************************************************
;*
;* LCD1(VSS) = GND         LCD9(DB2): -
;* LCD2(VDD) = VCC         LCD10(DB3): -
;* LCD3(VO ) = GND         LCD11(DB4): PortA.4
;* LCD4(RS ) = PortA.0     LCD12(DB5): PortA.5
;* LCD5(R/W) = GND         LCD13(DB6): PortA.6
;* LCD6(E  ) = PortA.1     LCD14(DB7): PortA.7
;* LCD7(DB0) = -           LCD15(BLA): VCC
;* LCD8(DB1) = -           LCD16(BLK): PortB.5 (1=Backlight ON)
;*
;***************************************************************

.include "m128def.inc" ; Definition file for ATmega128 
;* Program Constants 
.equ const =$00 ; Generic Constant Structure example  
.equ increment = $1;
.equ decrement = $2;í
;* Program Variables Definitions 
.def temp =r16 ; Temporary Register example 
.def led =r17; LED Register
.def dir =r18; Szamlalas irany Register
.def btn =r19; 
.def btnreg0 =r20; Shiftregiszter btn0-nak
.def btnreg1 =r21; Shiftregiszter btn1-nek

;*************************************************************** 
;* Reset & Interrupt Vectors  
.cseg 
.org $0000 ; Define start of Code segment 
	jmp RESET ; Reset Handler, jmp is 2 word instruction 
	jmp DUMMY_IT	; Ext. INT0 Handler
	jmp DUMMY_IT	; Ext. INT1 Handler
	jmp DUMMY_IT	; Ext. INT2 Handler
	jmp DUMMY_IT	; Ext. INT3 Handler
	jmp DUMMY_IT	; Ext. INT4 Handler (INT gomb)
	jmp DUMMY_IT	; Ext. INT5 Handler
	jmp DUMMY_IT	; Ext. INT6 Handler
	jmp DUMMY_IT	; Ext. INT7 Handler
	jmp DUMMY_IT	; Timer2 Compare Match Handler 
	jmp DUMMY_IT	; Timer2 Overflow Handler 
	jmp DUMMY_IT	; Timer1 Capture Event Handler 
	jmp DUMMY_IT	; Timer1 Compare Match A Handler 
	jmp DUMMY_IT	; Timer1 Compare Match B Handler 
	jmp DUMMY_IT	; Timer1 Overflow Handler 
	jmp DUMMY_IT	; Timer0 Compare Match Handler 
	jmp DUMMY_IT	; Timer0 Overflow Handler 
	jmp DUMMY_IT	; SPI Transfer Complete Handler 
	jmp DUMMY_IT	; USART0 RX Complete Handler 
	jmp DUMMY_IT	; USART0 Data Register Empty Hanlder 
	jmp DUMMY_IT	; USART0 TX Complete Handler 
	jmp DUMMY_IT	; ADC Conversion Complete Handler 
	jmp DUMMY_IT	; EEPROM Ready Hanlder 
	jmp DUMMY_IT	; Analog Comparator Handler 
	jmp DUMMY_IT	; Timer1 Compare Match C Handler 
	jmp DUMMY_IT	; Timer3 Capture Event Handler 
	jmp DUMMY_IT	; Timer3 Compare Match A Handler 
	jmp DUMMY_IT	; Timer3 Compare Match B Handler 
	jmp DUMMY_IT	; Timer3 Compare Match C Handler 
	jmp DUMMY_IT	; Timer3 Overflow Handler 
	jmp DUMMY_IT	; USART1 RX Complete Handler 
	jmp DUMMY_IT	; USART1 Data Register Empty Hanlder 
	jmp DUMMY_IT	; USART1 TX Complete Handler 
	jmp DUMMY_IT	; Two-wire Serial Interface Handler 
	jmp DUMMY_IT	; Store Program Memory Ready Handler 

.org $0046

;****************************************************************
;* DUMMY_IT interrupt handler -- CPU hangup with LED pattern
;* (This way unhandled interrupts will be noticed)

;< többi IT kezelõ a fájl végére! >

DUMMY_IT:	
	ldi r16,   0xFF ; LED pattern:  *-
	out DDRC,  r16  ;               -*
	ldi r16,   0xA5	;               *-
	out PORTC, r16  ;               -*
DUMMY_LOOP:
	rjmp DUMMY_LOOP ; endless loop

;< többi IT kezelõ a fájl végére! >

;*************************************************************** 
;* MAIN program, Initialisation part
.org $004B;
RESET: 
;* Stack Pointer init, 
;  Set stack pointer to top of RAM 
	ldi temp, LOW(RAMEND) ; RAMEND = "max address in RAM"
	out SPL, temp 	      ; RAMEND value in "m128def.inc" 
	ldi temp, HIGH(RAMEND) 
	out SPH, temp 

M_INIT:
;< ki- és bemenetek inicializálása stb > 
ldi dir, increment; alapbol felfele

ldi temp, 0xFF ;
out DDRC, temp ; Kimenet inicializálása
ldi led, 0b1 ; kezdésnek az elsõ led világít
out PORTC, led ; kiadjuk a kimenetre

ldi temp, 0x00 ; 
out DDRE, temp ; gombok bemenetre állítása
sts DDRG, temp ; kapcsolók bemenetre állítása


;*************************************************************** 
;* MAIN program, Endless loop part
M_LOOP:

	call BUTTON_UPDATE;
	jmp BTN_1_CHK;

BTN_1_CHK:
	sbrc btnreg1, 0 ; 
	jmp BTN_0_CHK;
	sbrs btnreg1, 1 ;
	jmp BTN_0_CHK;
	ldi btnreg1, 0; 
	jmp BTN_1;
	

BTN_0_CHK:
	sbrc btnreg0, 0 ;
	jmp M_LOOP;
	sbrs btnreg0, 1 ;
	jmp M_LOOP;
	ldi btnreg1, 0; 
	jmp BTN_0;


BTN_1:
	call BUTTON_UPDATE;

	sbrc btnreg1, 0 ; 
	jmp BTN_1_LOOP;
	sbrs btnreg1, 1 ; 
	jmp BTN_1_LOOP;
	ldi btnreg1, 0; 
	jmp BTN_1_PAUSE

BTN_1_PAUSE:
	call BUTTON_UPDATE;
	
	sbrc btnreg1, 0 ; 
	jmp BTN_1_PAUSE;
	sbrs btnreg1, 1 ;
	jmp BTN_1_PAUSE;
	ldi btnreg1, 0; 
	jmp BTN_1_LOOP;

BTN_1_LOOP:
	ldi temp, 0b1000;
	sub temp, led;
	breq LOAD_SEVEN;

	ldi temp, 0b10000;
	sub temp, led;
	breq LOAD_ZERO;

	mov temp, dir;;
	sbrs temp, 0;
	call STEP_DEC;

	mov temp, dir;
	sbrs temp, 1;
	call STEP_INC;

	jmp BTN_1;

BTN_0:
	ldi temp, 0b1;
	sub temp, led;
	breq LOAD_FOUR;

	ldi temp, 0b10000000;
	sub temp, led;
	breq LOAD_THREE;

	mov temp, dir;;
	sbrs temp, 0;
	call STEP_DEC;

	mov temp, dir;
	sbrs temp, 1;
	call STEP_INC;

	jmp BTN_0;

LOAD_SEVEN:
	ldi dir, decrement;
	ldi led, 0b10000000;
	out PORTC, led ; kiadjuk a led értékét PORTC-n
	jmp BTN_1;

LOAD_ZERO:
	ldi dir, increment;
	ldi led, 0b1;
	out PORTC, led ; kiadjuk a led értékét PORTC-n
	jmp BTN_1;

LOAD_THREE:
	ldi dir, decrement;
	ldi led, 0b1000;
	out PORTC, led ; kiadjuk a led értékét PORTC-n
	jmp BTN_0;

LOAD_FOUR:
	ldi dir, increment;
	ldi led, 0b10000;
	out PORTC, led ; kiadjuk a led értékét PORTC-n
	jmp BTN_0;

;*************************************************************** 
;* Subroutines, Interrupt routines

STEP_INC:
	in led, PORTC ; betöltjük PORTC értékét a ledbe
	lsl led ; shifteljük balra a regisztert
	breq RESET_LED ; ha nulla lett (körbeért), akkor reset szubrutin
	out PORTC, led ; kiadjuk a led értékét PORTC-n
	ret

STEP_DEC:
	in led, PORTC ; betöltjük PORTC értékét a ledbe
	lsr led ; shifteljük balra a regisztert
	breq RESET_LED ; ha nulla lett (körbeért), akkor reset szubrutin
	out PORTC, led ; kiadjuk a led értékét PORTC-n
	ret

RESET_LED:
	ldi led, 0b1 ; visszaállítjuk 1re a led értékét
	out PORTC, led ; kiadjuk itt is, mert a ret a main loopba fog visszatérni
	ret

BUTTON_UPDATE:
	in btn, PINE
	bst btn, 5 ; T-be töltjük btn 5. bitjét
	lsl btnreg0 ; balra shifteljük az eddigi értékét a gomb regiszterünknek
	bld btnreg0, 0 ; betöltjük T értékét a gomb regiszterünk elsõ helyiértékére
	andi btnreg0, 0b11 ; maszkoljuk, csak az elsõ 2 bit érdekel minket

	bst btn, 6 ; T-be töltjük btn 6. bitjét
	lsl btnreg1 ;
	bld btnreg1, 0 ;
	andi btnreg1, 0b11 ;
	
	ret 















