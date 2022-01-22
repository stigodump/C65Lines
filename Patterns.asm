;******************************************************************
;
; Generates patterns from the movePoint data
;
;	Auther: R Welbourn
;	File Name:Patterns.asm
;	Discord: Stigodump
;	Date: 22/01/2022
;	Assembler: 64TAS Must be at least build 2625
;
;******************************************************************
;Constants
BPCOMP		= $d03b
X_OFFSET	= 128
Y_OFFSET	= 100

X1 		= movePoint.X1
Y1 		= movePoint.Y1
X2 		= movePoint.X2
Y2 		= movePoint.Y2
X1n		= movePoint.X1n
Y1n		= movePoint.Y1n
X2n 	= movePoint.X2n
Y2n 	= movePoint.Y2n
X1_120	= movePoint.X1_120
Y1_120	= movePoint.Y1_120
X1_240	= movePoint.X1_240
Y1_240	= movePoint.Y1_240
X2_120	= movePoint.X2_120
Y2_120	= movePoint.Y2_120
X2_240	= movePoint.X2_240
Y2_240	= movePoint.Y2_240

	.section zero_page
pat_num 	.byte ?
bp_num		.byte ?
num_lines	.byte ?
bp_offset	.byte ?
repeat		.byte ?

line_col	.byte ?
col_repeat	.byte ?
scrol_pat	.byte ?

del_tmr 	.byte ?
tail_m 		.byte ?
finished	.byte ?
	.send

;******************************************************
				;configure pattern 1 for draw 2
Setup21  		lda #0
				jsr colPallet.SetPalletNum
				jsr colPallet.fixedPallet
				lda #15
				sta movePoint.step_size
				lda #15
				sta col_repeat
				sta col_rep+1
				lda #7
				sta line_col
				lda #8
				sta col_len+1
				lda #19
				sta del_tmr
				lda #7
				sta col_offset+1
				lda #90
				sta tail_len+1
				lda #3
				sta scrol_pat
				lda #pattern2-p
				sta pat_num
				jsr set_large
				bra setup_end

				;configure pattern 2 for draw 2 ;blue
Setup22		 	lda #1
				jsr colPallet.SetPalletNum
				jsr colPallet.fixedPallet
				lda #7
				sta movePoint.step_size
				lda #3
				sta col_repeat
				sta col_rep+1
				lda #15
				sta line_col
				lda #0
				sta col_offset+1
				lda #16
				sta col_len+1
				lda #42
				sta tail_len+1
				lda #1
				sta scrol_pat
				lda #pattern8-p
				sta pat_num
				jsr set_large
				bra setup_end

				;configure pattern 3 for draw 2
Setup23 	 	lda #4
				jsr colPallet.SetPalletNum
				jsr colPallet.fixedPallet
				lda #63
				sta max_len+1
				lda #3
				sta col_repeat
				sta col_rep+1
				lda #15
				sta line_col
				lda #0
				sta col_offset+1
				lda #16
				sta col_len+1
				lda #2
				sta scrol_pat
				lda #pattern4-p
				sta pat_num
				jsr set_small
				bra su_rnd_tlen

				;configure pattern 4 for draw 2
Setup24 	 	lda #5
				jsr colPallet.SetPalletNum
				jsr colPallet.fixedPallet
				lda #63
				sta max_len+1
				lda #4
				sta col_repeat
				sta col_rep+1
				lda #1
				sta line_col
				lda #0
				sta col_offset+1
				lda #16
				sta col_len+1
				lda #4
				sta scrol_pat
				lda #pattern7-p
				sta pat_num
				jsr set_small
				bra su_rnd_tlen

				;configure pattern 4 for draw 2
Setup25 	 	lda #6
				jsr colPallet.SetPalletNum
				jsr colPallet.fixedPallet
				lda #5
				sta col_repeat
				sta col_rep+1
				lda #7
				sta line_col
				lda #8
				sta col_len+1
				lda #7
				sta col_offset+1
				lda #30
				sta tail_len+1
				lda #3
				sta scrol_pat
				lda #pattern8-p
				sta pat_num
				jsr set_large
				bra su_rnd_step

				;**************************************
				;Calculate next line
Draw2 			dec col_repeat
				bne draw2_l
col_rep			lda #3
				sta col_repeat

				lda scrol_pat
				jsr colPallet.scrollPallet
				lda line_col
				inc a 
col_len			cmp #8
				bne +
				lda #1
+				sta line_col
				jsr do_tail

				;**************************************
				;draw colour pattern
draw2_l			lda line_col
				jsr draw_col_pat
				jsr remv_col_pat

				lda finished
				rts

;******************************************************
				;configure pattern 1 for draw 4
Setup41 		lda #2
				jsr colPallet.SetPalletNum
				lda #0
				sta scrol_pat
				jsr set_large
				lda #pattern1-p
				sta pat_num
				lda #120
				sta tail_len+1
				bra su_rnd_step

Setup42			lda #3
				jsr colPallet.SetPalletNum
				lda #0
				sta scrol_pat
				jsr set_small
				lda #pattern3-p
				sta pat_num
				lda #31
				sta max_len+1
				bra su_rnd_tlen

Setup43			lda #3
				jsr colPallet.SetPalletNum
				lda #0
				sta scrol_pat
				jsr set_large
				lda #pattern5-p
				sta pat_num
				lda #31
				sta max_len+1
				bra su_rnd_tlen

Setup44			lda #7
				jsr colPallet.SetPalletNum
				lda #6
				sta scrol_pat
				jsr set_large
				lda #pattern9-p
				sta pat_num
				lda #200
				sta tail_len+1
				bra su_rnd_step

Setup45			lda #3
				jsr colPallet.SetPalletNum
				lda #0
				sta scrol_pat
				jsr set_small
				lda #pattern6-p
				sta pat_num
				lda #31
				sta max_len+1
				
				;**************************************
su_rnd_offs		lda BPCOMP
				ora #%00001000
				sta BPCOMP
				sta bp_offset
su_rnd_tlen		jsr random.GetRND
max_len			and #127
				inc a
				sta tail_len+1
su_rnd_step		jsr random.GetRND
				and #15
				tay
				lda power,y
				sta movePoint.step_size
setup_end		lda #1
				sta finished
				sta repeat
				jsr random.GetRND
				and #1
				inc a
				sta per_frame+1
				lda #0
				sta tail_m
				rts

Draw4			dec repeat 
				bne +
				lda #4
				sta repeat
				jsr do_tail
				lda scrol_pat
				jsr colPallet.scrollPallet
				
+				lda bp_offset
				sta lineBpln.BP
				jsr draw_bp_pat

				lda bp_offset
				sta lineBpln.BP
				jsr remv_bp_pat

				lda finished
				rts

;**************************************
				;draw colour pattern
draw_col_pat	sta lineCol.Colour
				ldx pat_num
				lda p,x
				sta num_lines 
-				inx
				ldy p,x 
				lda (movePoint.head_pntr),y
				clc
				adc #X_OFFSET
				sta lineCol.X1
				inx 
				ldy p,x 
				lda (movePoint.head_pntr),y
				clc
				adc #Y_OFFSET
				sta lineCol.Y1
				inx
				ldy p,x 
				lda (movePoint.head_pntr),y
				clc
				adc #X_OFFSET
				sta lineCol.X2
				inx
				ldy p,x 
				lda (movePoint.head_pntr),y
				clc
				adc #Y_OFFSET
				sta lineCol.Y2
				stx temp
				jsr lineCol.Line
				ldx temp
				lda lineCol.Colour
				clc
col_offset		adc #0
				sta lineCol.Colour
				dec num_lines
				bne -
				rts

				;remove colour pattern
remv_col_pat	lda #0
				sta lineCol.Colour
				ldx pat_num
				lda p,x 
				sta num_lines
-				inx
				ldy p,x 
				lda (movePoint.tail_pntr),y
				clc
				adc #X_OFFSET
				sta lineCol.X1
				inx 
				ldy p,x 
				lda (movePoint.tail_pntr),y
				clc
				adc #Y_OFFSET
				sta lineCol.Y1
				inx
				ldy p,x 
				lda (movePoint.tail_pntr),y
				clc
				adc #X_OFFSET
				sta lineCol.X2
				inx
				ldy p,x 
				lda (movePoint.tail_pntr),y
				clc
				adc #Y_OFFSET
				sta lineCol.Y2
				stx temp
				jsr lineCol.Line
				ldx temp
				dec num_lines
				bne -
				rts

				;draw bitplan pattern
draw_bp_pat		ldx pat_num
				lda p,x
				sta num_lines 
-				inx
				ldy p,x 
				lda (movePoint.head_pntr),y
				clc
				adc #X_OFFSET
				sta lineBpln.X1
				inx 
				ldy p,x 
				lda (movePoint.head_pntr),y
				clc
				adc #Y_OFFSET
				sta lineBpln.Y1
				inx
				ldy p,x 
				lda (movePoint.head_pntr),y
				clc
				adc #X_OFFSET
				sta lineBpln.X2
				inx
				ldy p,x 
				lda (movePoint.head_pntr),y
				clc
				adc #Y_OFFSET
				sta lineBpln.Y2
				stx temp
				lda #1
				sta lineBpln.SC
				jsr lineBpln.Line
				inc lineBpln.BP
				ldx temp
				dec num_lines
				bne -
				rts

				;remove bitplan pattern
remv_bp_pat		ldx pat_num
				lda p,x 
				sta num_lines
-				inx
				ldy p,x 
				lda (movePoint.tail_pntr),y
				clc
				adc #X_OFFSET
				sta lineBpln.X1
				inx 
				ldy p,x 
				lda (movePoint.tail_pntr),y
				clc
				adc #Y_OFFSET
				sta lineBpln.Y1
				inx
				ldy p,x 
				lda (movePoint.tail_pntr),y
				clc
				adc #X_OFFSET
				sta lineBpln.X2
				inx
				ldy p,x 
				lda (movePoint.tail_pntr),y
				clc
				adc #Y_OFFSET
				sta lineBpln.Y2
				stx temp
				lda #0
				sta lineBpln.SC
				jsr lineBpln.Line
				inc lineBpln.BP
				ldx temp
				dec num_lines
				bne -
				rts

;******************************************************
set_small		lda #70
				jsr movePoint.SetXSize
				lda #70
				jmp movePoint.SetYSize

set_large		lda #movePoint.X_MAX
				jsr movePoint.SetXSize
				lda #movePoint.Y_MAX
				jmp movePoint.SetYSize

;******************************************************
				;select tail mode
do_tail			ldx tail_m
				jsr (tail_mode,x)
				bne +
				inc tail_m
				inc tail_m
+				rts

				;add one to tail length
inc_tail		jsr movePoint.TailPlus1
				sec
tail_len		sbc #19

				rts

				;subtract one from tail length
dec_tail		jsr movePoint.TailMinus1
				sta finished
				rts

				;delay
delay_tail		dec del_tmr
				rts

;******************************************************
power		.byte 1,3,15,3,7,3,1,3
			.byte 3,1,3,7,1,3,7,3
tail_mode	.word inc_tail, delay_tail, dec_tail
p			;pattern1 4 lines
pattern1	.byte 4
			.byte X1,Y1,X2,Y2
			.byte X1n,Y1,X2n,Y2
			.byte X1,Y1n,X2,Y2n
			.byte X1n,Y1n,X2n,Y2n
			;pattern2 2 lines
pattern2	.byte 2
			.byte X1,Y1,X1n,Y1n
			.byte X1n,Y1,X1,Y1n
			;pattern3 3 lines
pattern3	.byte 3
			.byte X1,Y1,X2,Y2
			.byte X1_120,Y1_120,X2_120,Y2_120
			.byte X1_240,Y1_240,X2_240,Y2_240
			;pattern4 3 lines
pattern4	.byte 3
			.byte X1,Y1,X1_120,Y1_120
			.byte X1_120,Y1_120,X1_240,Y1_240
			.byte X1_240,Y1_240,X1,Y1
			;pattern1 1 line
pattern5	.byte 1
			.byte X1,Y1,X2,Y2
			;pattern6 3 lines
pattern6	.byte 3
			.byte X1,Y1,X2_120,Y2_120
			.byte X1_120,Y1_120,X2_240,Y2_240
			.byte X1_240,Y1_240,X2,Y2
 			;pattern1 4 lines
pattern7	.byte 3
			.byte X1,Y1,X2_120,Y2_120
			.byte X2,Y2,X1_240,Y1_240
			.byte X1_120,Y1_120,X2_240,Y2_240
			.byte X1n,Y1n,X2n,Y2n
			;pattern8 2 lines
pattern8	.byte 2
			.byte X1,Y1,X2n,Y2n
			.byte X2,Y2,X1n,Y1n
			;pattern9 4 lines
pattern9	.byte 4
			.byte X1,Y1,X1n,Y1
			.byte X1n,Y1,X1n,Y1n
			.byte X1n,Y1n,X1,Y1n
			.byte X1,Y1n,X1,Y1
			
			