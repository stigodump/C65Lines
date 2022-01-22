;******************************************************************
;
; Generates 256 lines of point data then wraps around
;
;	Auther: R Welbourn
;	File Name:MovePoint.asm
;	Discord: Stigodump
;	Date: 22/01/2022
;	Assembler: 64TAS Must be at least build 2625
;
;******************************************************************
;Constants
X_MAX	= 127
Y_MAX	= 99
X_MIN	= 10
Y_MIN	= 10

COS120	= -0.5 * 256
COS240	= -0.5 * 256
SIN120	= 0.866 * 256
SIN240	= 0.866 * 256

X1 		= 0
Y1 		= 1
X2 		= 2
Y2 		= 3
X1n		= 4
Y1n		= 5
X2n 	= 6
Y2n 	= 7
X1_120	= 8
Y1_120	= 9
X1_240	= 10
Y1_240	= 11
X2_120	= 12
Y2_120	= 13
X2_240	= 14
Y2_240	= 15

;Zero Page variables
	.section zero_page
head_pntr	.word ?
last_pntr	.word ?
tail_pntr	.word ?
head_pos	.byte ?
tail_len	.byte ?
y_maxsize	.byte ?
x_maxsize	.byte ?
y_minsize	.byte ?
x_minsize	.byte ?
step_size	.byte ?
	.send

Initialize		lda #0
				sta head_pos
				sta tail_len
				lda #X_MAX
				sta x_maxsize
				lda #Y_MAX
				sta y_maxsize
				lda #X_MIN
				sta x_minsize
				lda #Y_MIN
				sta y_minsize
				lda #7
				sta step_size

set_pntrs		lda head_pos
				sta head_pntr
				lda #0
				asl head_pntr
				rol a
				asl head_pntr
				rol a
				asl head_pntr
				rol a
				asl head_pntr
				rol a
				adc #>point_table
				sta head_pntr+1

				lda head_pos
				sec 
				sbc tail_len
				sta tail_pntr
				lda #0
				asl tail_pntr
				rol a 
				asl tail_pntr
				rol a 
				asl tail_pntr
				rol a 
				asl tail_pntr
				rol a 
				adc #>point_table
				sta tail_pntr+1

				rts

PlusXSize		lda x_maxsize
				inc a
				bra SetXSize
MinusXSize		lda x_maxsize
				dec a
SetXSize		cmp #X_MAX
				beq +
				bge ++
+				cmp #X_MIN 
				blt +
				sta x_maxsize
				neg a
				sta x_minsize
+				lda x_minsize
				rts

PlusYXSize		lda y_maxsize
				inc a
				bra SetYSize
MinusYSize		lda y_maxsize
				dec a
SetYSize		cmp #Y_MAX
				beq +
				bge ++
+				cmp #Y_MIN 
				blt +
				sta y_maxsize
				neg a
				sta y_minsize
+				lda y_minsize
				rts

TailPlus1		lda tail_len
				cmp	#255
				beq +
				inc a
				sta tail_len
+				rts

TailMinus1		lda tail_len
				beq +
				dec head_pos
				dec a
				sta tail_len
				bsr set_pntrs
				lda tail_len
+				rts

MovePoints		lda head_pntr
				sta last_pntr
				lda head_pntr+1
				sta last_pntr+1
				inc head_pos
				bsr set_pntrs

				ldy #3
				;***Change Y values
next_point		lda (last_pntr),y
				clc
				adc inc_table,y 
				sta (head_pntr),y
				bvc +
				bpl y_lt
				lda y_maxsize
				bra y_gt
+				bpl posy_res
				cmp y_minsize
				bcs +

				;Y result less than
y_lt			lda y_minsize
				sta (head_pntr),y
				jsr random.GetRND
				and step_size
				inc a 
				sta inc_table,y 
				bra +

posy_res		lda y_maxsize
				cmp (head_pntr),y
				bcs +

				;Y result greater than
y_gt			sta (head_pntr),y
				jsr random.GetRND
				and step_size
				inc a
				neg a
				sta inc_table,y 

+				dey 
				;***Change X values
				lda (last_pntr),y
				clc
				adc inc_table,y 
				sta (head_pntr),y
				bvc +
				bpl x_lt
				lda x_maxsize
				bra x_gt
+				bpl posx_res
				cmp x_minsize
				bcs +

				;X result less than
x_lt			lda x_minsize
				sta (head_pntr),y
				jsr random.GetRND
				and step_size
				inc a 
				sta inc_table,y 
				bra +

posx_res		lda x_maxsize
				cmp (head_pntr),y
				bcs +

				;X result greater than
x_gt			sta (head_pntr),y
				jsr random.GetRND
				and step_size
				inc a
				neg a
				sta inc_table,y 

+				dey
				bpl next_point

				;Set complement values
				ldy #3
				ldz #7
next_neg		lda (head_pntr),y
				neg a 
				sta (head_pntr),z 
				dez
				dey 
				bpl next_neg

				;X1 Y1 points
				;Y * SIN120
				ldy #Y1
				lda (head_pntr),y
				sta multiply.MA 
				lda #SIN120
				sta multiply.MB 
				jsr multiply.MultAB
				;X1 * COS120
				ldy #X1
				lda (head_pntr),y
				neg a
				asr a
				sec
				;COS120 - SIN120
				sbc multiply.HI
				ldy #X1_120
				sta (head_pntr),y
				
				;X1 * SIN120
				ldy #X1
				lda (head_pntr),y
				sta multiply.MA 
				lda #SIN120
				sta multiply.MB 
				jsr multiply.MultAB
				;Y1 * COS120
				ldy #Y1
				lda (head_pntr),y
				neg a
				asr a
				clc
				;COS120 + SIN120
				adc multiply.HI
				ldy #Y1_120
				sta (head_pntr),y

				;Y1 * SIN240
				ldy #Y1
				lda (head_pntr),y
				sta multiply.MA 
				lda #SIN240
				sta multiply.MB 
				jsr multiply.MultAB
				lda multiply.HI
				neg a
				sta multiply.HI
				;X1 * COS240
				ldy #X1
				lda (head_pntr),y
				neg a
				asr a
				sec
				;COS240 - SIN240
				sbc multiply.HI
				ldy #X1_240
				sta (head_pntr),y

				;X1 * SIN240
				ldy #X1
				lda (head_pntr),y
				sta multiply.MA 
				lda #SIN240
				sta multiply.MB 
				jsr multiply.MultAB
				lda multiply.HI
				neg a
				sta multiply.HI
				;Y1 * COS240
				ldy #Y1
				lda (head_pntr),y
				neg a
				asr a
				clc
				;COS240 + SIN240
				adc multiply.HI
				ldy #Y1_240
				sta (head_pntr),y
				
				;X2 Y2 Points
				;Y * SIN120
				ldy #Y2
				lda (head_pntr),y
				sta multiply.MA 
				lda #SIN120
				sta multiply.MB 
				jsr multiply.MultAB
				;X1 * COS120
				ldy #X2
				lda (head_pntr),y
				neg a
				asr a
				sec
				;COS120 - SIN120
				sbc multiply.HI
				ldy #X2_120
				sta (head_pntr),y
				
				;X1 * SIN120
				ldy #X2
				lda (head_pntr),y
				sta multiply.MA 
				lda #SIN120
				sta multiply.MB 
				jsr multiply.MultAB
				;Y1 * COS120
				ldy #Y2
				lda (head_pntr),y
				neg a
				asr a
				clc
				;COS120 + SIN120
				adc multiply.HI
				ldy #Y2_120
				sta (head_pntr),y

				;Y1 * SIN240
				ldy #Y2
				lda (head_pntr),y
				sta multiply.MA 
				lda #SIN240
				sta multiply.MB 
				jsr multiply.MultAB
				lda multiply.HI
				neg a
				sta multiply.HI
				;X1 * COS240
				ldy #X2
				lda (head_pntr),y
				neg a
				asr a
				sec
				;COS240 - SIN240
				sbc multiply.HI
				ldy #X2_240
				sta (head_pntr),y

				;X1 * SIN240
				ldy #X2
				lda (head_pntr),y
				sta multiply.MA 
				lda #SIN240
				sta multiply.MB 
				jsr multiply.MultAB
				lda multiply.HI
				neg a
				sta multiply.HI
				;Y1 * COS240
				ldy #Y2
				lda (head_pntr),y
				neg a
				asr a
				clc
				;COS240 + SIN240
				adc multiply.HI
				ldy #Y2_240
				sta (head_pntr),y
				
				rts

inc_table		.byte 	254,2,3,253

				.align	$100
point_table		.byte 	10,10,245,245,245,245,10,10,1,1,1,1,1,1,1,1
