BasicUpstart2(start)
                        //------------------------------------------------------------------------------
						// import music.
                        //------------------------------------------------------------------------------
						* = $1000 "Music"
						.label music_init =*			 
						.label music_play =*+3			
                        .import binary "ode to 64.bin"	
                        //------------------------------------------------------------------------------
						// import standard library definitions
                        //------------------------------------------------------------------------------
						#import "standardLibrary.asm" 
                        //------------------------------------------------------------------------------

                        //------------------------------------------------------------------------------
                        *=$0900
                        //------------------------------------------------------------------------------
start:        			lda #$35
						sta $01
                        sei
                        lda #BLACK
                        sta border
                        sta screen

                        jsr setup_sprites

                        lda #$00
                        tax
                        tay
                        jsr music_init

						lda #$1b
						sta screenmode
						lda #$10
						sta raster
						lda #$81
						sta irqenable
						lda #26
						sta charset
						lda #216
						sta smoothpos
						lda #$7f
						sta $dc0d
						sta $dd0d
						lda #$01
						sta irqflag
						sta irqenable						

						ldx #<main_irq
						ldy #>main_irq
						stx $fffe
						sty $ffff

						cli
						
						jmp *
                        //------------------------------------------------------------------------------
setup_sprites:			lda #%11111111
						sta spriteset

                        lda #%00000000
                        sta spriteexpy
                        sta spriteexpx

            	        lda #%00000000
			            sta spritepr
                        lda #%00000000
                        sta spritermsb

                        ldx #$30
                        ldy #$32
                        stx X_POS
                        sty Y_POS

                        lda #WHITE
                        sta spritecolors
                        sta spritecolors+1
                        sta spritecolors+2
                        sta spritecolors+3
                        sta spritecolors+4
                        sta spritecolors+5
                        sta spritecolors+6
                        sta spritecolors+7

						// define '..case..' sprites
						
                        lda #(spr_imgSTOP / 64)
						sta 2040
						sta 2041
                        lda #(spr_imgM / 64)
						sta 2042
                        lda #(spr_imgI / 64) 
						sta 2043
                        lda #(spr_imgB / 64) 
						sta 2044
                        lda #(spr_imgR / 64)
						sta 2045
                        lda #(spr_imgI / 64)
                        sta 2046
                        lda #(spr_imgSTOP / 64)
                        sta 2047
                        				
						// define x position of sprites
                        
						lda X_POS
						sta sprite0x
						adc #26
						sta sprite1x
						adc #26
						sta sprite2x
						adc #26
						sta sprite3x
						adc #26
						sta sprite4x
						adc #26
						sta sprite5x
						adc #26
						sta sprite6x
						adc #26
						sta sprite7x
						
                        lda #50
                        sta sprite0y
                        sta sprite1y
                        sta sprite2y
                        sta sprite3y
                        sta sprite4y
                        sta sprite5y
                        sta sprite6y
						sta sprite7y

                        lda #$00
                        sta sin_counter0
                        lda #$20
                        sta sin_counter1
                        lda #$40
                        sta sin_counter2
                        lda #$60
                        sta sin_counter3
                        lda #$80
                        sta sin_counter4
                        lda #$a0
                        sta sin_counter5
                        lda #$b0
                        sta sin_counter6
                        lda #$c0
                        sta sin_counter7
						rts
                        //------------------------------------------------------------------------------

                        //------------------------------------------------------------------------------
						// main irq for 'moving' the sprites.
                        //------------------------------------------------------------------------------
main_irq:				pha
						txa
						pha
						tya
						pha

                        ldx sin_counter0
                        lda sinetable,x
                        adc Y_POS
                        sta sprite0y 

                        ldx sin_counter1
                        lda sinetable,x
                        adc Y_POS
                        sta sprite1y

                        ldx sin_counter2
                        lda sinetable,x
                        adc Y_POS
                        sta sprite2y

                        ldx sin_counter3
                        lda sinetable,x
                        adc Y_POS
                        sta sprite3y

                        ldx sin_counter4
                        lda sinetable,x
                        adc Y_POS
                        sta sprite4y

                        ldx sin_counter5
                        lda sinetable,x
                        adc Y_POS
                        sta sprite5y

                        ldx sin_counter6
                        lda sinetable,x
                        adc Y_POS
                        sta sprite6y

                        ldx sin_counter7
                        lda sinetable,x
                        adc Y_POS
                        sta sprite7y

                        jsr sinus_move
                        jsr sinus_move
                        jsr sinus_move
                        jsr sinus_move

                        lda #$e0
                        cmp raster
                        bne *-3

                        jsr music_play
                        
                        lda #$01
						sta $d019	
						pla
						tay
						pla
						tax
						pla
						rti                        
                        //------------------------------------------------------------------------------

                        //------------------------------------------------------------------------------
						// control the 'Y' speed movement of the sprites.
                        //------------------------------------------------------------------------------
sinus_move:             lda sinus_delay
			            sec
			            sbc #$06
			            and #$07
			            sta sinus_delay
			            bcc sinus_move01
			            rts
sinus_move01:	        inc sin_counter0
                        inc sin_counter1
                        inc sin_counter2
                        inc sin_counter3
                        inc sin_counter4
                        inc sin_counter5
                        inc sin_counter6
                        inc sin_counter7
                        rts
                        //------------------------------------------------------------------------------

                        //------------------------------------------------------------------------------
						// data tables
                        //------------------------------------------------------------------------------

sinus_delay:            .byte $00                   

X_POS: 					.byte $a0,$00
Y_POS: 					.byte $32,$00
						
sin_counter0: 			.byte $00
sin_counter1: 			.byte $00
sin_counter2: 			.byte $00
sin_counter3: 			.byte $00
sin_counter4: 			.byte $00
sin_counter5: 			.byte $00
sin_counter6: 			.byte $00
sin_counter7: 			.byte $00

sinetable:              .byte $11,$11,$11,$12,$12,$12,$13,$13,$14,$14,$14,$15,$15,$16,$16,$16
                        .byte $17,$17,$17,$18,$18,$18,$19,$19,$19,$1a,$1a,$1a,$1b,$1b,$1b,$1c
                        .byte $1c,$1c,$1c,$1d,$1d,$1d,$1d,$1e,$1e,$1e,$1e,$1e,$1f,$1f,$1f,$1f
                        .byte $1f,$1f,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
                        .byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$1f
                        .byte $1f,$1f,$1f,$1f,$1f,$1e,$1e,$1e,$1e,$1e,$1d,$1d,$1d,$1d,$1c,$1c
                        .byte $1c,$1b,$1b,$1b,$1b,$1a,$1a,$1a,$19,$19,$19,$18,$18,$18,$17,$17
                        .byte $16,$16,$16,$15,$15,$15,$14,$14,$13,$13,$13,$12,$12,$11,$11,$11
                        .byte $10,$10,$10,$0f,$0f,$0e,$0e,$0e,$0d,$0d,$0c,$0c,$0c,$0b,$0b,$0b
                        .byte $0a,$0a,$09,$09,$09,$08,$08,$08,$07,$07,$07,$06,$06,$06,$06,$05
                        .byte $05,$05,$04,$04,$04,$04,$03,$03,$03,$03,$03,$02,$02,$02,$02,$02
                        .byte $02,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
                        .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$02,$02
                        .byte $02,$02,$02,$02,$03,$03,$03,$03,$03,$04,$04,$04,$04,$05,$05,$05
                        .byte $05,$06,$06,$06,$07,$07,$07,$08,$08,$08,$09,$09,$09,$0a,$0a,$0a
                        .byte $0b,$0b,$0b,$0c,$0c,$0d,$0d,$0d,$0e,$0e,$0f,$0f,$0f,$10,$10,$10

                        *=$3000 "sprite charset"
sprites:                // butt fat white sprite set

spr_imgA:               .byte $ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff
                        .byte $ff,$fe,$ff,$ff,$fe,$ff,$ef,$fe,$ff,$ef,$fe,$ff,$ff,$fe,$ff,$ff
                        .byte $fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ef,$fe
                        .byte $ff,$ef,$fe,$ff,$ef,$fe,$ff,$ef,$fe,$ff,$ef,$fe,$ff,$ef,$fe,$05

spr_imgB:               .byte $ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff
                        .byte $ff,$fe,$ff,$fe,$fe,$ff,$fe,$fe,$ff,$ff,$fe,$ff,$ff,$e0,$ff,$ff
                        .byte $fe,$ff,$fe,$fe,$ff,$fe,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe
                        .byte $ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$05

spr_imgC:               .byte $ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff
                        .byte $ff,$fe,$ff,$fe,$fe,$ff,$fe,$fe,$ff,$fe,$fe,$ff,$fe,$00,$ff,$fe
                        .byte $fe,$ff,$fe,$fe,$ff,$fe,$fe,$ff,$fe,$fe,$ff,$ff,$fe,$ff,$ff,$fe
                        .byte $ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$05

spr_imgD:               .byte $ff,$ff,$fc,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff
                        .byte $ff,$fe,$ff,$ef,$fe,$ff,$ef,$fe,$ff,$ef,$fe,$ff,$ef,$fe,$ff,$ef
                        .byte $fe,$ff,$ef,$fe,$ff,$ef,$fe,$ff,$ef,$fe,$ff,$ef,$fe,$ff,$ff,$fe
                        .byte $ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fc,$05

spr_imgE:               .byte $ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff
                        .byte $ff,$fe,$ff,$ff,$00,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff
                        .byte $fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$00,$ff,$ff,$fe
                        .byte $ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$05

spr_imgF:               .byte $ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff
                        .byte $ff,$fe,$ff,$ff,$00,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff
                        .byte $fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$00,$ff,$ff,$00
                        .byte $ff,$ff,$00,$ff,$ff,$00,$ff,$ff,$00,$ff,$ff,$00,$ff,$ff,$00,$05

spr_imgG:               .byte $ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff
                        .byte $ff,$fe,$ff,$fe,$00,$ff,$fe,$fe,$ff,$fe,$fe,$ff,$fe,$fe,$ff,$fe
                        .byte $fe,$ff,$fe,$fe,$ff,$fe,$fe,$ff,$fe,$fe,$ff,$ff,$fe,$ff,$ff,$fe
                        .byte $ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$05

spr_imgH:               .byte $ff,$ef,$fe,$ff,$ef,$fe,$ff,$ef,$fe,$ff,$ef,$fe,$ff,$ef,$fe,$ff
                        .byte $ef,$fe,$ff,$ef,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff
                        .byte $fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ef,$fe,$ff,$ef,$fe
                        .byte $ff,$ef,$fe,$ff,$ef,$fe,$ff,$ef,$fe,$ff,$ef,$fe,$ff,$ef,$fe,$05

spr_imgI:               .byte $ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff
                        .byte $ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$00,$ff
                        .byte $00,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe
                        .byte $ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$05

spr_imgJ:               .byte $ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff
                        .byte $ff,$fe,$00,$00,$fe,$ff,$fe,$fe,$ff,$fe,$fe,$ff,$fe,$fe,$ff,$fe
                        .byte $fe,$ff,$fe,$fe,$ff,$fe,$fe,$ff,$fe,$fe,$ff,$ff,$fe,$ff,$ff,$fe
                        .byte $ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$05

spr_imgK:               .byte $ff,$fe,$fe,$ff,$fe,$fe,$ff,$fe,$fe,$ff,$fe,$fe,$ff,$fe,$fe,$ff
                        .byte $fe,$fe,$ff,$fe,$fe,$ff,$fe,$fe,$ff,$ff,$fe,$ff,$ff,$e0,$ff,$ff
                        .byte $fe,$ff,$fe,$fe,$ff,$fe,$fe,$ff,$fe,$fe,$ff,$fe,$fe,$ff,$fe,$fe
                        .byte $ff,$fe,$fe,$ff,$fe,$fe,$ff,$fe,$fe,$ff,$fe,$fe,$ff,$fe,$fe,$05

spr_imgL:               .byte $ff,$ff,$00,$ff,$ff,$00,$ff,$ff,$00,$ff,$ff,$00,$ff,$ff,$00,$ff
                        .byte $ff,$00,$ff,$ff,$00,$ff,$ff,$00,$ff,$ff,$00,$ff,$ff,$00,$ff,$ff
                        .byte $00,$ff,$ff,$00,$ff,$ff,$00,$ff,$ff,$00,$ff,$ff,$fe,$ff,$ff,$fe
                        .byte $ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$05

spr_imgM:               .byte $ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff
                        .byte $ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff
                        .byte $fe,$ff,$ff,$fe,$ff,$ff,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe
                        .byte $fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$05

spr_imgN:               .byte $ff,$fe,$fe,$ff,$fe,$fe,$ff,$fe,$fe,$ff,$fe,$fe,$ff,$fe,$fe,$ff
                        .byte $fe,$fe,$ff,$fe,$fe,$ff,$fe,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff
                        .byte $fe,$ff,$ff,$fe,$ff,$ff,$fe,$fe,$ff,$fe,$fe,$ff,$fe,$fe,$ff,$fe
                        .byte $fe,$ff,$fe,$fe,$ff,$fe,$fe,$ff,$fe,$fe,$ff,$fe,$fe,$ff,$fe,$05

spr_imgO:               .byte $ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff
                        .byte $ff,$fe,$ff,$ef,$fe,$ff,$ef,$fe,$ff,$ef,$fe,$ff,$ef,$fe,$ff,$ef
                        .byte $fe,$ff,$ef,$fe,$ff,$ef,$fe,$ff,$ef,$fe,$ff,$ef,$fe,$ff,$ff,$fe
                        .byte $ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$05

spr_imgP:               .byte $ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff
                        .byte $ff,$fe,$ff,$fe,$fe,$ff,$fe,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff
                        .byte $fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$00,$ff,$ff,$00
                        .byte $ff,$ff,$00,$ff,$ff,$00,$ff,$ff,$00,$ff,$ff,$00,$ff,$ff,$00,$05

spr_imgQ:               .byte $ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff
                        .byte $ff,$fe,$ff,$ef,$fe,$ff,$ef,$fe,$ff,$ef,$fe,$ff,$ef,$fe,$ff,$ef
                        .byte $fe,$ff,$ef,$fe,$ff,$ef,$fe,$ff,$ef,$fe,$ff,$ef,$e0,$ff,$ff,$fe
                        .byte $ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$05

spr_imgR:               .byte $ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff
                        .byte $ff,$fe,$ff,$fe,$fe,$ff,$fe,$fe,$ff,$ff,$fe,$ff,$ff,$e0,$ff,$ff
                        .byte $fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$fe,$fe,$ff,$fe,$fe
                        .byte $ff,$fe,$fe,$ff,$fe,$fe,$ff,$fe,$fe,$ff,$fe,$fe,$ff,$fe,$fe,$05

spr_imgS:               .byte $ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff
                        .byte $ff,$fe,$ff,$ff,$fe,$ff,$ff,$00,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff
                        .byte $fe,$ff,$ff,$fe,$ff,$ff,$fe,$00,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe
                        .byte $ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$05

spr_imgT:               .byte $ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff
                        .byte $ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff
                        .byte $fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$01,$ff,$00,$01,$ff,$00
                        .byte $01,$ff,$00,$01,$ff,$00,$01,$ff,$00,$01,$ff,$00,$01,$ff,$00,$05

spr_imgU:               .byte $ff,$ef,$fe,$ff,$ef,$fe,$ff,$ef,$fe,$ff,$ef,$fe,$ff,$ef,$fe,$ff
                        .byte $ef,$fe,$ff,$ef,$fe,$ff,$ef,$fe,$ff,$ef,$fe,$ff,$ef,$fe,$ff,$ef
                        .byte $fe,$ff,$ef,$fe,$ff,$ef,$fe,$ff,$ef,$fe,$ff,$ff,$fe,$ff,$ff,$fe
                        .byte $ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$05

spr_imgV:               .byte $ff,$ef,$fe,$ff,$ef,$fe,$ff,$ef,$fe,$ff,$ef,$fe,$ff,$ef,$fe,$ff
                        .byte $ef,$fe,$ff,$ef,$fe,$ff,$ef,$fe,$ff,$ef,$fe,$ff,$ef,$fe,$ff,$ef
                        .byte $fe,$ff,$ef,$fe,$ff,$ef,$fe,$ff,$ef,$fe,$ff,$ff,$fe,$ff,$ff,$fe
                        .byte $ff,$ff,$fe,$01,$ff,$00,$01,$ff,$00,$01,$ff,$00,$01,$ff,$00,$05

spr_imgW:               .byte $fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe
                        .byte $fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe
                        .byte $fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe,$ff,$ff,$fe,$ff,$ff,$fe
                        .byte $ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$05

spr_imgX:               .byte $ff,$ef,$fe,$ff,$ef,$fe,$ff,$ef,$fe,$ff,$ef,$fe,$ff,$ef,$fe,$ff
                        .byte $ef,$fe,$ff,$ef,$fe,$ff,$ef,$fe,$ff,$ff,$fe,$0f,$ff,$e0,$ff,$ff
                        .byte $fe,$ff,$ff,$fe,$ff,$ef,$fe,$ff,$ef,$fe,$ff,$ef,$fe,$ff,$ef,$fe
                        .byte $ff,$ef,$fe,$ff,$ef,$fe,$ff,$ef,$fe,$ff,$ef,$fe,$ff,$ef,$fe,$05

spr_imgY:               .byte $ff,$ef,$fe,$ff,$ef,$fe,$ff,$ef,$fe,$ff,$ef,$fe,$ff,$ef,$fe,$ff
                        .byte $ef,$fe,$ff,$ef,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff
                        .byte $fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$01,$ff,$00,$01,$ff,$00
                        .byte $01,$ff,$00,$01,$ff,$00,$01,$ff,$00,$01,$ff,$00,$01,$ff,$00,$05

spr_imgZ:               .byte $ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff
                        .byte $ff,$fe,$ff,$ff,$fe,$00,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff
                        .byte $fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$00,$ff,$ff,$fe,$ff,$ff,$fe
                        .byte $ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe,$05

spr_imgEXC:             .byte $00,$ff,$00,$00,$ff,$00,$00,$ff,$00,$00,$ff,$00,$00,$ff,$00,$00
                        .byte $ff,$00,$00,$ff,$00,$00,$ff,$00,$00,$ff,$00,$00,$ff,$00,$00,$ff
                        .byte $00,$00,$ff,$00,$00,$ff,$00,$00,$ff,$00,$00,$00,$00,$00,$ff,$00
                        .byte $00,$ff,$00,$00,$ff,$00,$00,$ff,$00,$00,$ff,$00,$00,$ff,$00,$05

spr_imgSTOP:            .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                        .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                        .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$ff,$00
                        .byte $00,$ff,$00,$00,$ff,$00,$00,$ff,$00,$00,$ff,$00,$00,$ff,$00,$05

