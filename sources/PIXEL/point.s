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
 
 clr.l -(sp)
 trap #1
 
main:
 movem.l	$ffff8240.w,d0-d7
 movem.l	d0-d7,sav_pal    ; save palette system
 
 move.l #$00000777,$ffff8240.w; put palette for color 0 and 1
 
 lea.l	$78000,a0          ; Fill screen
 move.w  #(160*200)/4-1,d7 ; in 20 parts
 move.l  #$00020000,(a0)+  ; of 8 words
 dbf	d7,*-6
 
*> Display one pixel with the first bitplane
 lea.l	$78000,a0          ; adress of the screen
 move.w	#136,d0            ; position X is 136
 move.w	#51,d1             ; position Y is 51
 move.w  d0,d2             ; backup X in the register d2
 andi.w  #$fff0,d0         ; which cluster of 16 pixels to display ?
 sub.w   d0,d2             ; sub multiple of 16 with the X position
 subi.w  #15,d2            ; seek bitnumber between 16 pixels
 neg.w   d2                ; the bitplane for the bset instruction
 lsr.w   #1,d0             ; divided by 2 : offset X done !
 mulu.w  #160,d1           ; multiplication by 160 : offset Y done !
 add.w   d0,d1             ; position in the screen : $7A060
 move.w  (a0,d1.l),d0      ; get bitplane word : $0080
 bset    d2,d0             ; activate the bit for display
 move.w  d0,(a0,d1.l)      ; display pixel on screen offset
 
 move.w   #7,-(sp)         ; wait for a key press
 trap   #1   
 addq.l   #2,sp
 
 movem.l sav_pal,d0-d7     ; restore palette system
 movem.l d0-d7,$ffff8240.w
 rts

sav_pal	ds.l 8


