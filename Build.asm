;******************************************************************
;
; Draw lines
;
;	Auther: R Welbourn
;	Discord: Stigodump
;	Date: 03/01/2022
;	Assembler: 64TAS Must be at least build 2625
;	64tass-1.56.2625\64tass -a Build.asm -o Build.prg --tab-size=4
;	Xemu: Tested using Xemu - ROM 911001 & 920246
;
;******************************************************************

;Target CPU
	.cpu "4510"

ZERO_PAGE			= $00
BASE_PAGE			= $5f
BASIC_CODE			= $2001
MAIN_CODE 			= $2020
CIAA_ICR			= $dc0d


* = ZERO_PAGE
	.dsection zero_page
	.cerror * > $ff, "Too many ZP variables"

* = BASIC_CODE
	.dsection basic_code
	.cerror * > BASIC_CODE + MAIN_CODE - BASIC_CODE, "Not enough space"

* = MAIN_CODE
	.dsection main_code
	.cerror * > $5eff, "Not enough space"

	.section zero_page
temp		.byte ?
	.send

	.section basic_code
		;.byte $00										;Start
		.byte $0a,$20,$0a,$00,$fe,$02,$20,$30,$00 		;10 BANK 0
		.byte $16,$20,$14,$00,$9e,$38,$32,$32,$34,$00	;20 SYS8224 ($2020)
		.byte $00,$00									;End				
	.send

	.section main_code
				;Set MONITOR memory MAP
				lda $0114
				ldx $0115
				ldy $0116
				ldz $0117
				map
				eom

				;C65 knock
				;lda #$a5
				;sta $d02f
				;lda #$96
				;sta $d02f

				;Set DMAgic to F018B
				lda #%00000001
				tsb $d703

				;Set 3.5Mhz
				lda #%01000000
				trb $d054

				;Set Bitplanes to first 128K
				lda #%00000111
				trb $d07c

				lda #255
				sta $d071

				;Save and update IRQ interrupt vector
				sei
				lda $314
				;sta int_exit+1
				lda $315
				;sta int_exit+2
 				lda #<Int
				sta $314
				lda #>Int
				sta $315

				;Set raster compare to 250
				lda #%10000000
				trb $d011
				lda #<250
				sta $d012
				
				;Set two bitplanes to $8000 Bank0 & Bank1
				;Set two bitplanes to $c000 Bank0 & Bank1
				lda #%10001000
				sta $d033
				sta $d034
				lda #%10001010
				sta $d035
				sta $d036
				lda #%00001111
				sta $d032
				lda #%01010000
				sta $d031

				;Clear whole BP1 & BP2 & BP3 & BP4
				lda #0
				sta $d702
				lda #>dma_clrscrn
				sta $d701
				lda #<dma_clrscrn
				sta $d700

				;Setup Lines demo test routine
				lda #$00
				sta $d021
				sta $d020
				sta next
				jsr show_pallet

				;set Base Page
				tba 
				pha
				lda #BASE_PAGE
				tab

				;Initialize 
				jsr colPallet.fixedPallet
				jsr movePoint.Initialize

				pla 
				tab
				cli
Wait			bra	Wait

;Interrupt entry point
Int				;inc $d020
				lda #BASE_PAGE
				tab

				dec timer
				bne int_exit
per_frame		lda #1
				sta timer

				jsr movePoint.MovePoints
		
				ldx next
				cpx #task_end-demo_tasks
				bne +
				ldx #0
				stx next
+				jsr (demo_tasks,x)
				bne int_exit
				inc next 
				inc next
				
int_exit		lda #1
				sta $d019
				lda $a1
				bit #$86
				sta $d030
				pla 
				tab 
				plz 
				ply  
				plx 
				pla 
				rti
				
next		.byte 0
timer		.byte 5

demo_tasks	.word patterns.Setup43
			.word patterns.Draw4
			.word patterns.Setup45
			.word patterns.Draw4
			.word patterns.Setup23
			.word patterns.Draw2
			.word patterns.Setup41
			.word patterns.Draw4
			.word patterns.Setup24
			.word patterns.Draw2
			.word patterns.Setup21
			.word patterns.Draw2
			.word patterns.Setup44
			.word patterns.Draw4
			.word patterns.Setup22
			.word patterns.Draw2
			.word patterns.Setup42
			.word patterns.Draw4
			.word patterns.Setup25
			.word patterns.Draw2
task_end
			
;DMA job to clear whole of four bitplanes
dma_clrscrn	.byte %00000111 ;command low byte: FILL+CHAIN
			.word 16383		;2 x 8192 screens
			.word 0000		;source address/fill value
			.byte 0			;source Bank
			.word $8000		;destination address
			.byte 1			;destination Bank
			.byte 0			;command hi byte
			.word 0			;modulo

			.byte %00000011	;command low byte: FILL
			.word 16383		;2 x 8192 screens
			.word 0000		;source address/fill value
			.byte 0			;source Bank
			.word $8000		;destination address
			.byte 0			;destination Bank
			.byte 0			;command hi byte
			.word 0			;modulo

show_pallet		lda #0
				sta temp
				sta $d03c
				sta $d03d
				ldy #255
next_col		ldx #8
-				sta $d040
				bbr 0,temp,+
				sty $d040
+				sta $d041
				bbr 1,temp,+
				sty $d041
+				sta $d042
				bbr 2,temp,+
				sty $d042
+				sta $d043
				bbr 3,temp,+
				sty $d043
+				inc $d03d
				dex
				bne -
				inc temp
				bbr 4,temp,next_col
				rts

lineCol		.binclude "LineColour16.asm"
lineBpln	.binclude "Line4Bitplane.asm"
colPallet	.binclude "PalletScroll.asm"
multiply	.binclude "Multiply6.asm"
random		.binclude "Random.asm"
patterns	.binclude "Patterns.asm"
movePoint	.binclude "MovePoint.asm"

			.send