;******************************************************************
;
; Signed 8-bit multiply -> 16-bit result
; MA -128 to 127, MB 0 to 255
; MA*MB -> lo byte in MA, hi byte in HI
; Uses A, X, BA not changed
;
;	Auther: R Welbourn
;	File Name:Multiply6.asm
;	Discord: Stigodump
;	Date: 22/01/2022
;	Assembler: 64TAS Must be at least build 2625
;
;******************************************************************

	.section zero_page
MB 		.byte ?
MA		.byte ?
HI		.byte ?
	.send 

MultAB			ldx #0
				lda MA
				bpl +
				neg
				sta MA
				inx 
				
+				lda #0
    			clc

 				ror
				ror MA
				bcc +
				clc
				adc MB
				
+ 				ror
				ror MA
				bcc +
				clc
				adc MB
				
+ 				ror
				ror MA
				bcc +
				clc
				adc MB
				
+ 				ror
				ror MA
				bcc +
				clc
				adc MB
				
+ 				ror
				ror MA
				bcc +
				clc
				adc MB
				
+ 				ror
				ror MA
				bcc +
				clc
				adc MB
				
+ 				ror
				ror MA
				bcc +
				clc
				adc MB
				
+ 				ror
				ror MA
				bcc +
				clc
				adc MB
				
+ 				ror
				ror MA
				bcc +
				clc
				adc MB
				
+				sta HI
				cpx #0
				beq +
				eor #$ff
				sta HI
				lda MA
				eor #$ff
				sta MA
				inw MA

+				rts


