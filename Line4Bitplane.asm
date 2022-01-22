;******************************************************************
;
; Draw line X 0 to 255 & Y 0 to 199 onto one of four bitplanes
; Code runs on Base Page (Zero Page)
;
;	Auther: R Welbourn
;	File Name:Line4Bitplane.asm
;	Discord: Stigodump
;	Date: 22/01/2022
;	Assembler: 64TAS Must be at least build 2625
;
; There are a few ways to improve the line drawing routine. At the
; moment it will only draw on the X axis to pixel 255. This could 
; be changed to draw a line with X 256 pixels long from anywhere on
; the screen with little change, as the line drawing loop can draw
; 256 pixels from any point on the screen. I'm sure a couple of
; cycles per iteration of the line drawing loop can be saved with a
; mask overflow detection reimplementation. And possibly other
; changes.
;******************************************************************

;VICIII Constants
BPX 	= $d03c
BPY 	= $d03d
B0PIX 	= $d040

;4510 Instruction Constants
INC_ABS	= $ee
DEC_ABS = $ce
TSB_ABS = $0c
TRB_ABS = $1c

	.align $100
DRAW_BPLN_PAGE	

;External adresses
Line 	= DRAW_BPLN_PAGE + drwline		;Draw line routine address
BP 		= DRAW_BPLN_PAGE + bit_plane+1	;Bit Plane to draw to
SC 		= DRAW_BPLN_PAGE + set_clr		;Set or Clear lint
X1		= DRAW_BPLN_PAGE + x1_ + 1		;X1 line value
X2		= DRAW_BPLN_PAGE + x2_ + 1		;X2 line value
Y1		= DRAW_BPLN_PAGE + y1_ + 1		;Y1 line value
Y2		= DRAW_BPLN_PAGE + y2_ + 1		;Y2 line value

;Operates in Base Page (Zero Page)  
		.logical $00

			;Down the screen
-			tay
			lda #INC_ABS
			bra +

invert		ldx x1_ + 1
			ldy x2_ + 1
			stx	x2_ + 1
			sty x1_ + 1
			ldx y1_ + 1
			ldy y2_ + 1
			stx y2_ + 1
			sty y1_ + 1
			bra x2_

drwline		tba
			pha
			lda #>DRAW_BPLN_PAGE
			tab
				
			;dx = x1-x2 or x2-x1 smallest from bigest
x2_			lda #*	;x2 value
			sec 
x1_			sbc #*	;x1 value
			blt invert
			sta dx1mem+1
			sta dx2mem+1
			taz

			lda x1_ + 1
			lsr
			lsr
			lsr
			;***add 32 pixels to left to centre on screen 4 * 8 pixels ***
			clc
			adc #4
			;***
			sta BPX
			lda x1_+ 1
			and #%00000111
			tax 
			lda y1_ + 1
			sta BPY

			;dy = y1-y2
y2_			lda #*	;y2 value
			sec
y1_			sbc #*	;y1 value
			
			;Will Y go up the screen or down the screen
			bge -
			;Up the screen
			neg
			tay
			lda #DEC_ABS

			;Set the instruction in the line drawing code
+			sta incdecy
			sta decincy
			sty dy1mem+1
			sty dy2mem+1

			;Set which bitplane will be written to
bit_plane	lda #0
			and #$03
			clc
			adc	#$40
			sta bplanex+1
			sta bplaney+1

			lda #TRB_ABS
			bbr 0,set_clr,+
			lda #TSB_ABS
+			sta bplanex
			sta bplaney

			tya
			asr a

			cpy dx1mem+1
			blt Gradx
			sec
			cpy #0
			bne Grady
			bra exit

			;draw line dx+ dy+/- dy<dx
-			inx
dy1mem		adc #*	;dy
			bcc	+
decincy		inc BPY
Gradx
dx1mem		sbc #*	;dx
+			tay
			lda mask,x
			bne +
			inc BPX
			tax
			lda #%10000000
+			
bplanex		tsb B0PIX
			tya
			dez
			bne	-

exit		pla
			tab
			rts

			;draw line dx+ dy+/- dy>dx
-			
dx2mem		adc #*	;dx
			bcc	+
			inx
Grady		
dy2mem		sbc #*	;dy
+			taz
incdecy		inc BPY
			lda mask,x
			bne	+
			inc BPX
			tax
			lda #%10000000
+			
bplaney 	tsb B0PIX
			tza
			dey
			bne	-

			pla
			tab
			rts

set_clr		.byte 0
mask		.byte %10000000
			.byte %01000000
			.byte %00100000
			.byte %00010000
			.byte %00001000
			.byte %00000100
			.byte %00000010
			.byte %00000001
			.byte %00000000	;overflow inc BPX
		.here	
