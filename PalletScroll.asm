;******************************************************************
;
; Colour pallet management and effect routines
;
;	Auther: R Welbourn
;	File Name:Line4Bitplane.asm
;	Discord: Stigodump
;	Date: 22/01/2022
;	Assembler: 64TAS Must be at least build 2625
;
;******************************************************************

;Constants
RED_PALLET		=	$d100
GRN_PALLET		=	$d200
BLU_PALLET		=	$d300
BPCOMP			=	$d03b

	.section zero_page
pallet_num	.byte ?
table_pntr	.word ?
	.send

;Set 16 colour pallet to use
setPalletNum	sta pallet_num
				asl a 
				asl a 
				asl a 
				asl a 
				sta BPCOMP
				rts

;Set first sixteen colours in colour pallet
fixedPallet		lda #<colour_table
				sta table_pntr
				lda #>colour_table
				sta table_pntr+1
				ldx #0
				ldy #0
				;Red
-				lda (table_pntr),y
				sta RED_PALLET,x
				inw table_pntr
				;Green
				lda (table_pntr),y
				sta GRN_PALLET,x
				inw table_pntr				
				;Blue
				lda (table_pntr),y
				sta BLU_PALLET,x
				inw table_pntr
				inx
				cpx #16*8
				bne -
				rts

ScrollPallet	asl a
				tax
				jmp (pal_scrolls,x)

blue1 			lda #15
				ldz #15
				jmp scrl_blue_up

grey2			lda #15
				ldz #15
				jsr scrl_red_up
				lda #15
				ldz #15
				jsr scrl_grn_up
				lda #7
				ldz #7
				jmp scrl_blue_dn
				
srg3			lda #14
				ldz #7
				jsr scrl_red_up
				lda #7
				ldz #7
				jmp scrl_grn_up	

rgy4			lda #15
				ldz #15
				jmp scrl_grn_up
				rts

rg5				lda #7
				ldz #7
				jsr scrl_red_up
				lda #14
				ldz #7
				jmp scrl_grn_up

grn6			lda #7
				ldz #7
				;jsr scrl_red_up
				lda #14
				ldz #1
				jmp scrl_grn_dn

scrl_red_up		clc
				adc BPCOMP
				tax 
				ldy RED_PALLET,x				
-				lda RED_PALLET-1,x
				sta RED_PALLET,x
				dex
				dez
				bne -
				sty RED_PALLET+1,x
				rts

scrl_red_dn		clc
				adc BPCOMP
				tax 
				ldy RED_PALLET,x				
-				lda RED_PALLET+1,x
				sta RED_PALLET,x
				inx	
				dez
				bne -
				sty RED_PALLET,x
				rts

scrl_grn_up		clc
				adc BPCOMP
				tax 
				ldy GRN_PALLET,x				
-				lda GRN_PALLET-1,x
				sta GRN_PALLET,x
				dex
				dez
				bne -
				sty GRN_PALLET+1,x
				rts

scrl_grn_dn		clc
				adc BPCOMP
				tax 
				ldy GRN_PALLET,x				
-				lda GRN_PALLET+1,x
				sta GRN_PALLET,x
				inx	
				dez
				bne -
				sty GRN_PALLET,x
				rts

scrl_blue_up	clc
				adc BPCOMP
				tax 
				ldy BLU_PALLET,x				
-				lda BLU_PALLET-1,x
				sta BLU_PALLET,x
				dex
				dez
				bne -
				sty BLU_PALLET+1,x
				rts

scrl_blue_dn	clc
				adc BPCOMP
				tax 
				ldy BLU_PALLET,x				
-				lda BLU_PALLET+1,x
				sta BLU_PALLET,x
				inx	
				dez
				bne -
				sty BLU_PALLET,x
none			rts

pal_scrolls		.word none, blue1, grey2, srg3, rgy4, rg5, grn6

colour_table
			;16 Pallet 0 Red/Green
			.byte $0,$0,$0 ;0 				0000
			.byte $0,$2,$0 ;1 				0001 
			.byte $0,$3,$0 ;2 				0010 
			.byte $0,$5,$0 ;3 				0011 
			.byte $0,$7,$0 ;4 				0100 
			.byte $0,$9,$0 ;5 				0101 
			.byte $0,$c,$0 ;6 				0110 
			.byte $0,$f,$0 ;7 				0111
			.byte $3,$0,$0 ;8 				1000 
			.byte $5,$0,$0 ;9 				1001 
			.byte $7,$0,$0 ;a 				1010 
			.byte $9,$0,$0 ;b 				1011 
			.byte $b,$0,$0 ;c 				1100 
			.byte $d,$0,$0 ;d 				1101
			.byte $f,$0,$0 ;e 				1110
			.byte $f,$f,$0 ;f 				1111
			;16 Pallet 1 Blue
			.byte $0,$0,$0 ;0 				0000
			.byte $1,$1,$1 ;1 				0001
			.byte $1,$1,$2 ;2 				0010
			.byte $1,$1,$3 ;3 				0011
			.byte $1,$1,$4 ;4 				0100
			.byte $1,$1,$5 ;5 				0101
			.byte $1,$1,$6 ;6 				0110
			.byte $1,$1,$7 ;7 				0111
			.byte $1,$1,$8 ;8 				1000
			.byte $1,$1,$9 ;9 				1001
			.byte $1,$1,$a ;a 				1010
			.byte $1,$1,$b ;b 				1011 
			.byte $1,$1,$c ;c 				1100
			.byte $1,$1,$d ;d 				1101
			.byte $1,$1,$e ;e 				1110
			.byte $1,$1,$f ;f 				1111
			;16 Pallet 2 Mulicolour
			.byte $0,$0,$0 ;0 				0000
			.byte $f,$0,$0 ;1 bp1 			0001 Red
			.byte $0,$c,$0 ;2 bp2			0010 Green
			.byte $1,$5,$a ;3 bp1+b2 		0011 Teal
			.byte $0,$0,$f ;4 bp3 			0100 Blue
			.byte $0,$c,$f ;5 bp2+bp3 		0101 Cyan
			.byte $f,$0,$f ;6 bp1+bp3 		0110 Magenta
			.byte $0,$0,$0 ;7 				0111 Black
			.byte $c,$c,$0 ;8 bp4 			1000 Yellow
			.byte $8,$8,$8 ;9 bp1+bp4 		1001 Grey
			.byte $8,$2,$f ;a bp2+bp4 		1010 Purple
			.byte $0,$0,$0 ;b 				1011 Black
			.byte $d,$7,$0 ;c bp3+bp4		1100 Orange
			.byte $0,$0,$0 ;d 				1101 Black
			.byte $0,$0,$0 ;e 				1110 Black
			.byte $f,$f,$f ;f 				1111 White
			;16 Pallet 3 first 8 primary
			.byte $0,$0,$0 ;0 				0000
			.byte $b,$0,$0 ;1 bp1 			0001 Red
			.byte $0,$9,$0 ;2 bp2			0010 Green
			.byte $f,$f,$0 ;3 bp1+b2 		0011 yellow
			.byte $0,$0,$b ;4 bp3 			0100 Blue
			.byte $f,$0,$f ;5 bp2+bp3 		0101 Cyan
			.byte $0,$f,$f ;6 bp1+bp3 		0110 Magenta
			.byte $f,$f,$f ;7 				0111
			.byte $0,$0,$0 ;8 	 			1000 
			.byte $0,$8,$2 ;9 bp1	 		1001 
			.byte $6,$0,$c ;a bp2	 		1010 
			.byte $6,$0,$c ;b 				1011 
			.byte $b,$5,$0 ;c bp3			1100
			.byte $0,$8,$2 ;d 				1101
			.byte $b,$5,$0 ;e 				1110
			.byte $a,$a,$a ;f 				1111
			;16 Pallet 4 Grey/Blue
			.byte $0,$0,$0 ;0 				0000
			.byte $1,$1,$6 ;1 bp1 			0001
			.byte $2,$2,$6 ;2 bp2			0010
			.byte $3,$3,$6 ;3 bp1+b2 		0011
			.byte $4,$4,$6 ;4 bp3 			0100
			.byte $5,$5,$6 ;5 bp2+bp3 		0101
			.byte $6,$6,$6 ;6 bp1+bp3 		0110
			.byte $7,$7,$6 ;7 				0111
			.byte $8,$8,$6 ;8 bp4 			1000
			.byte $9,$9,$6 ;9 bp1+bp4 		1001
			.byte $a,$a,$6 ;a bp2+bp4 		1010
			.byte $b,$b,$6 ;b 				1011 
			.byte $c,$c,$6 ;c bp3+bp4		1100
			.byte $d,$d,$6 ;d 				1101
			.byte $e,$e,$6 ;e 				1110
			.byte $f,$f,$6 ;f 				1111
			;16 Pallet 5 Red/Green/Yellow
			.byte $0,$0,$0 ;0 				0000
			.byte $1,$f,$0 ;1 bp1 			0001
			.byte $2,$e,$0 ;2 bp2			0010
			.byte $3,$d,$0 ;3 bp1+b2 		0011
			.byte $4,$c,$0 ;4 bp3 			0100
			.byte $5,$b,$0 ;5 bp2+bp3 		0101
			.byte $6,$a,$0 ;6 bp1+bp3 		0110
			.byte $7,$9,$0 ;7 				0111
			.byte $8,$8,$0 ;8 bp4 			1000
			.byte $9,$7,$0 ;9 bp1+bp4 		1001
			.byte $a,$6,$0 ;a bp2+bp4 		1010
			.byte $b,$5,$1 ;b 				1011 
			.byte $c,$4,$2 ;c bp3+bp4		1100
			.byte $d,$3,$3 ;d 				1101
			.byte $e,$2,$4 ;e 				1110
			.byte $f,$1,$5 ;f 				1111
			;16 Pallet 6 
			.byte $0,$0,$0 ;0 				0000
			.byte $2,$2,$6 ;1 bp1 			0001
			.byte $2,$4,$6 ;2 bp2			0010
			.byte $2,$6,$7 ;3 bp1+b2 		0011
			.byte $2,$8,$7 ;4 bp3 			0100
			.byte $2,$a,$8 ;5 bp2+bp3 		0101
			.byte $2,$c,$8 ;6 bp1+bp3 		0110
			.byte $2,$e,$9 ;7 				0111
			.byte $3,$2,$6 ;8 bp4 			1000
			.byte $5,$2,$6 ;9 bp1+bp4 		1001
			.byte $7,$2,$7 ;a bp2+bp4 		1010
			.byte $9,$2,$7 ;b 				1011 
			.byte $b,$2,$8 ;c bp3+bp4		1100
			.byte $d,$2,$8 ;d 				1101
			.byte $f,$2,$9 ;e 				1110
			.byte $f,$f,$f ;f 				1111
			;16 Pallet 7
			.byte $0,$0,$0 ;0 				0000
			.byte $0,$8,$0 ;1 bp1 			0001
			.byte $2,$6,$2 ;2 bp2			0010
			.byte $2,$8,$5 ;3 bp1+b2 		0011
			.byte $4,$5,$3 ;4 bp3 			0100
			.byte $1,$4,$1 ;5 bp2+bp3 		0101
			.byte $2,$5,$1 ;6 bp1+bp3 		0110
			.byte $5,$5,$0 ;7 				0111
			.byte $3,$4,$3 ;8 bp4 			1000
			.byte $0,$8,$0 ;9 bp1+bp4 		1001
			.byte $4,$4,$4 ;a bp2+bp4 		1010
			.byte $6,$6,$6 ;b 				1011 
			.byte $8,$8,$8 ;c bp3+bp4		1100
			.byte $1,$4,$1 ;d 				1101
			.byte $f,$8,$8 ;e 				1110
			.byte $f,$0,$0 ;f 				1111
			