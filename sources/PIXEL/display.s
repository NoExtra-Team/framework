 SECTION TEXT
 
 move.w #0,-(a7)           ; set low resolution
 move.l #$78000,-(a7)      ; set physical screen
 move.l #$78000,-(a7)      ; set logical screen
 move.w #5,-(a7)           ; setscreen
 trap	#14                  ; XBIOS function called
 lea.l	12(a7),a7          ; for Atari 520 STF
 
 pea main(pc)              ; exec routs main in super mode
 move.w #$26,-(sp)
 trap #14
 addq.l #6,sp
 
 clr.l -(sp)               ; exit !
 trap #1
 
main:
 movem.l $ffff8240.w,d0-d7
 movem.l d0-d7,sav_pal     ; save palette system
 
 move.l #$00000777,$ffff8240.w ; put palette for color 0 and 1
 move.l #$00E70FC7,$ffff8250.w ; put palette for color 10 and 11
 
 lea.l	$78000,a0          ; Fill screen by chunck of 16 pixels
 move.w  #(160*200)/4-1,d7 ; in 20 parts
 move.l  #$00020000,(a0)+  ; of 2 first words
 dbf	d7,*-6               ; loop above line instruction
 
*> calculate position on the screen
 lea.l	$78000,a0          ; manage our screen
 lea	160*51(a0),a0        ; position Y = 51
 add.w	#(9-1)*8,a0        ; position X = 136
                           ; 9 chuncks - 1 x 2 x 4 words
*> put 16 pixels with a pixel color number 10 -> dc.w  $0000,$0100,$0000,$0100
 move.w #$0000,0(a0)       ; first bitplane
 move.w #$0100,2(a0)       ; second bitplane
 move.w #$0000,4(a0)       ; third bitplane
 move.w #$0100,6(a0)       ; fourth bitplane
 
 move.w   #7,-(sp)         ; wait for a key press
 trap   #1   
 addq.l   #2,sp
 
 movem.l sav_pal,d0-d7     ; restore palette system
 movem.l d0-d7,$ffff8240.w
 rts

sav_pal	ds.l 8
