;******************************************************************
;
; Use timer to change pointer into page of changing numbers
;
;	Auther: R Welbourn
;	File Name:Random.asm
;	Discord: Stigodump
;	Date: 22/01/2022
;	Assembler: 64TAS Must be at least build 2625
;
; I dont think the timer is working on the Linux version of Xemu
; it does seem to work on the Mac version
;******************************************************************
CIAA_TALO	= $dc04
CIAA_TAHI	= $dc05
CIAA_ICR	= $dc0d
CIAA_CRA	= $dc0e
CIAA_CRB	= $dc0f
TMR_LOAD	= 277-1

SetRND		lda #<TMR_LOAD
			sta CIAA_TALO
			lda #>TMR_LOAD
			sta CIAA_TAHI
			lda #%10010001
			sta CIAA_CRA
			rts

GetRND		lda CIAA_TALO
			inc a
			adc rndpntr+1
			sta rndpntr+1
rndpntr		lda $2d00,x
			rts
