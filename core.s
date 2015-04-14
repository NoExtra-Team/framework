*************************************
* // XXXXXXX.PRG                 // *
* // Intro Code version 0.36     // *
* // Original code :             // *
* // Gfx logo :                  // *
* // Gfx font :                  // *
* // Music    :                  // *
* // Release date : xx/xx/2011	 // *
* // Update date  : xx/xx/2011	 // *
*************************************
  OPT c+ ; Case sensitivity on      *
  OPT d- ; Debug off                *
  OPT o- ; All optimisations off    *
  OPT w- ; Warnings off             *
  OPT x- ; Extended debug off       *
*************************************

	SECTION	TEXT

********************************************************************
BOTTOM_BORDER    equ 1         ; Use the bottom overscan           *
TOPBOTTOM_BORDER equ 0         ; Use the top and bottom overscan   *
PATTERN          equ $00010001 ; See the screen plan               *
SEEMYVBL         equ 0         ; See CPU used if you press ALT key *
ERROR_SYS        equ 0	       ; Manage Errors System              *
FADE_INTRO       equ 1	       ; Fade White to black palette       *
*------------------------------------------------------------------*
* Remarque : 0 = I use it / 1 = no need !                          *
********************************************************************

Begin:
	move    SR,d0 
	btst    #13,d0
	bne.s   mode_super_yet
	move.l  4(sp),a5                 ; Address to basepage
	move.l  $0c(a5),d0               ; Length of TEXT segment
	add.l   $14(a5),d0               ; Length of DATA segment
	add.l   $1c(a5),d0               ; Length of BSS segment
	add.l   #$1000,d0                ; Length of stackpointer
	add.l   #$100,d0                 ; Length of basepage
	move.l  a5,d1                    ; Address to basepage
	add.l   d0,d1                    ; End of program
	and.l   #-2,d1                   ; Make address even
	move.l  d1,sp                    ; New stackspace

	move.l  d0,-(sp)                 ; Mshrink()
	move.l  a5,-(sp)                 ;
	move.w  d0,-(sp)                 ;
	move.w  #$4a,-(sp)               ;
	trap    #1                       ;
	lea 	12(sp),sp                  ;
	
	clr.l	-(sp)                      ; Supervisor Mode
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,Save_stack
mode_super_yet:

	IFEQ	ERROR_SYS
	bsr	SAVE_ERROR
	ENDC

	bsr	clear_bss                    ; Clean BSS stack
	
	bsr	Init_screens                 ; Screens initialisation

	bsr	Save_and_init_st             ; Save system parameters

	IFEQ	FADE_INTRO
	bsr	fadein                       ; Fading white to black
	ENDC

	bsr	Init                         ; Inits
	
******************************************************************************

default_loop:

	bsr	Wait_vbl                     ; Waiting after the VBL

	IFEQ	SEEMYVBL
	clr.b	$ffff8240.w
	ENDC

* Put your code here !
* >


* <

	move.l  Zorro_scr1,d0            ; Swapping screens
	move.l  Zorro_scr2,Zorro_scr1 
	move.l  d0,Zorro_scr2
	lsr.w   #8,d0 
	move.l  d0,$ffff8200.w
  	
	IFEQ	SEEMYVBL
	cmp.b	#$38,$fffffc02.w           ; ALT key
	bne.s	next_key
	move.b	#7,$ffff8240.w           ; See the rest of CPU
next_key:	
	ENDC

	cmp.b	#$39,$fffffc02.w           ; SPACE key
	bne	default_loop

******************************************************************************

SORTIE:
	bsr	Restore_st

	move.l	Save_stack,-(sp)         ; Restore Mode Supervisor
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.w	-(sp)                      ; Pterm()
	trap	#1                         ; EXIT program

	IFEQ	ERROR_SYS
************************************************
*                                              *
*               Error Routines                 *
*                                              *
************************************************
BUS_ERROR:
	move.w	#$0F00,$ffff8240.w
	move.l	#$20425553,512.w
	move.l	10(a7),516.w
	move.l	#SORTIE,2(a7)
	move.w	#9984,(a7)
	rte

ADRESS_ERROR:
	move.w	#$0FF0,$ffff8240.w
	move.l	#$20414452,512.w
	move.l	10(a7),516.w
	move.l	#SORTIE,2(a7)
	move.w	#9984,(a7)
	rte

DIV0:
	move.w	#$0F0F,$ffff8240.w
	move.l	#$44495630,512.w
	move.l	2(a7),516.w
	move.l	#SORTIE,2(a7)
	move.w	#9984,(a7)
	rte

SAVE_ERROR:
	lea 	OLD_ERROR,a0
	move.l	8.w,(a0)+
	move.l	12.w,(a0)+
	move.l	20.w,(a0)+
	move.l	#BUS_ERROR,8.w
	move.l	#ADRESS_ERROR,12.w
	move.l	#DIV0,20.w
	rts

RESTORE_ERROR:
	lea 	OLD_ERROR,a0
	move.l	(a0)+,8.w
	move.l	(a0)+,12.w
	move.l	(a0)+,20.w
	rts

OLD_ERROR:
	dcb.w     6,$0
	even
	ENDC

************************************************
*                                              *
*               Init Routines                  *
*                                              *
************************************************
Init:	movem.l	d0-d7/a0-a6,-(a7)

	jsr	MUSIC+0                      ; Init music

	lea	Vbl(pc),a0                   ; Launch VBL
	move.l	a0,$70.w

	lea	Pal(pc),a0                   ; Put palette
	lea	$ffff8240.w,a1
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)

	movem.l	(a7)+,d0-d7/a0-a6
	rts

************************************************
*                                              *
*              Screen Routines                 *
*                                              *
************************************************
Init_screens:
	movem.l	d0-d7/a0-a6,-(a7)

	move.l	#Zorro_screen1,d0        ; Init screen #1
	add.w	#$ff,d0
	sf	d0
	move.l	d0,Zorro_scr1

	move.l	#Zorro_screen2,d0        ; Init screen #2
	add.w	#$ff,d0
	sf	d0
	move.l	d0,Zorro_scr2
	
	movea.l	Zorro_scr1,a6            ; Filed screen #1 with the pattern
	move.w	#Zorro_screen1_len/4-1,d1
	move.l	#PATTERN,(a6)+
	dbra	d1,*-6

	movea.l	Zorro_scr2,a6            ; Filed screen #2 with the pattern
	move.w	#Zorro_screen2_len/4-1,d1
	move.l	#PATTERN,(a6)+
	dbra	d1,*-6
	
	movem.l	(a7)+,d0-d7/a0-a6
	rts

Zorro_scr1:	dc.l	0                ; Screen #1
Zorro_scr2:	dc.l	0                ; Screen #2

************************************************
*                                              *
*               Vbl Routines                   *
*                                              *
************************************************
Vbl:
	movem.l	d0-d7/a0-a6,-(a7)

	st	Vsync                        ; Synchronisation

	IFEQ	BOTTOM_BORDER
	lea	Over_rout(pc),a0             ; HBL
	move.l	a0,$120.w                ; Timer B vector
	move.b	#199,$fffffa21.w         ; At the position
	move.b	#8,$fffffa1b.w           ; Launch HBL
	ENDC

	IFEQ	TOPBOTTOM_BORDER
	;move.l	a0,-(a7)
	clr.b	(tacr).w                   ; Stop timer A
	lea	topbord(pc),a0               ; Launch HBL
	move.l	a0,$134.w                ; Timer A vector
	move.b	#99,(tadr).w             ; Countdown value for timer A
	move.b	#4,(tacr).w              ; Delay mode, clock divided by 50
	;move.l	(a7)+,a0
	ENDC

	jsr 	(MUSIC+8)			; call music

	movem.l	(a7)+,d0-d7/a0-a6
	rte

Wait_vbl:                          ; Test Synchronisation
	move.l	a0,-(a7)
	lea	Vsync,a0
	sf	(a0)
.loop:	tst.b	(a0)
	beq.s	.loop
	move.l	(a7)+,a0
	rts

	IFEQ	BOTTOM_BORDER
***************************************************************
*                                                             *
*             < Here is the lower border rout >               *
*                                                             *
***************************************************************
Over_rout:
	sf	$fffffa21.w                  ; Stop Timer B
	sf	$fffffa1b.w
	dcb.w	95,$4e71                   ; 95 nops	Wait line end
	sf	$ffff820a.w                  ; Modif Frequency 60 Hz !
	dcb.w	28,$4e71                   ; 28 nops	Wait line end
	move.b	#$2,$ffff820a.w          ; 50 Hz !
	rte
	ENDC

	IFEQ	TOPBOTTOM_BORDER
***************************************************************
*                                                             *
*          < Here is the top and lower border rout >          *
*                                                             *
***************************************************************
herz = $FFFF820A
iera = $FFFFFA07
ierb = $FFFFFA09
isra = $FFFFFA0F
isrb = $FFFFFA11
imra = $FFFFFA13
imrb = $FFFFFA15
tacr = $FFFFFA19
tadr = $FFFFFA1F
my_hbl:rte

topbord:
	move.l	a0,-(a7)
	move	#$2100,sr
	stop	#$2100                     ; Sync with interrupt
	clr.b	(tacr).w                   ; Stop timer A
	dcb.w	78,$4E71                   ; 78 nops
	clr.b	(herz).w                   ; 60 Hz
	dcb.w	18,$4E71                   ; 18 nops
	move.b	#2,(herz).w              ; 50 Hz
	lea	botbord(pc),a0
	move.l	a0,$134.w                ; Timer A vector
	move.b	#178,(tadr).w            ; Countdown value for timer A
	move.b	#7,(tacr).w              ; Delay mode, clock divided by 200
	move.l	(a7)+,a0
	bclr.b	#5,(isra).w              ; Clear end of interrupt flag
	rte

botbord:
	move	#$2100,sr
	stop	#$2100			; sync with interrupt
	clr.b	(tacr).w		; stop timer A
	dcb.w	78,$4E71		; 78 nops
	clr.b	(herz).w		; 60 Hz
	dcb.w	18,$4E71		; 18 nops
	move.b	#2,(herz).w		; 50 Hz
	bclr.b	#5,(isra).w
	rte
	ENDC

************************************************
*                                              *
*         Save/Restore System Routines         *
*                                              *
************************************************
Save_and_init_st:

	move #$2700,sr
		
	lea	Save_all,a0                  ; Save adress parameters
	move.b	$fffffa03.w,(a0)+
	move.b	$fffffa07.w,(a0)+
	move.b	$fffffa09.w,(a0)+
	move.b	$fffffa11.w,(a0)+
	move.b	$fffffa13.w,(a0)+
	move.b	$fffffa15.w,(a0)+
	move.b	$fffffa17.w,(a0)+
	move.b	$fffffa19.w,(a0)+

	move.b	$fffffa1b.w,(a0)+
	move.b	$fffffa1d.w,(a0)+
	move.b	$fffffa1f.w,(a0)+
	move.b	$fffffa21.w,(a0)+

	move.b	$ffff8201.w,(a0)+
	move.b	$ffff8203.w,(a0)+
	move.b	$ffff820a.w,(a0)+
	move.b	$ffff820d.w,(a0)+
	
	lea	Save_rest,a0                  ; Save adress parameters
	move.l	$068.w,(a0)+	
	move.l	$070.w,(a0)+	
	move.l	$110.w,(a0)+	
	move.l	$114.w,(a0)+	
	move.l	$118.w,(a0)+	
	move.l	$120.w,(a0)+	
	move.l	$134.w,(a0)+	
	move.l	$484.w,(a0)+	

	movem.l	$ffff8240.w,d0-d7        ; Save palette system
	movem.l	d0-d7,(a0)

	bclr	#3,$fffffa17.w             ; Clear Timers
	clr.b	$fffffa07.w
	clr.b	$fffffa09.w 
	clr.b	$484.w                     ; No bip, no repeat

	stop	#$2300

	move	#4,-(sp)                   ; Save & Change Resolution
	trap	#14	                       ; Get Current Res.
	addq.l	#2,sp
	move	d0,Old_Resol+2

	clr	-(sp)
	move.l	#-1,-(sp)
	move.l	(sp),-(sp)
	move	#5,-(sp)
	trap	#14                        ; Switch to Low Resolution
	lea	12(sp),sp

	move	#2,-(sp)                   ; Save Screen Address
	trap	#14
	addq.l	#2,sp
	move.l	d0,Old_Screen+2

	move.l	Zorro_scr1(pc),d0        ; Put the new screen
	move.b	d0,d1
	lsr.w	#8,d0
	move.b	d0,$ffff8203.w
	swap	d0
	move.b	d0,$ffff8201.w
	move.b	d1,$ffff820d.w

	bsr	hide_mouse                   ; Keyboard and mouse
	bsr	flush
	move.b	#$12,d0
	bsr	setkeyboard

	IFEQ	BOTTOM_BORDER
	sf	$fffffa21.w                  ; Stop the Timer B
	sf	$fffffa1b.w
	lea	Over_rout(pc),a0             ; HBL
	move.l	a0,$120.w                ; Timer B vector
	bset	#0,$fffffa07.w             ; Timer B on
	bset	#0,$fffffa13.w
	ENDC

	IFEQ	TOPBOTTOM_BORDER
	move.b	#%00100000,(iera).w      ; Enable timer A
	move.b	#%00100000,(imra).w
	and.b	#%00010000,(ierb).w        ; Disable all except timer D
	and.b	#%00010000,(imrb).w
	or.b	#%01000000,(ierb).w        ; Enable keyboard
	or.b	#%01000000,(imrb).w
	clr.b	(tacr).w                   ; Timer A off
	lea	my_hbl(pc),a0
	move.l	a0,$68.w                 ; Horizontal blank
	lea	topbord(pc),a0
	move.l	a0,$134.w                ; Timer A vector
	ENDC

	rts

Restore_st:

	move #$2700,sr

	jsr	MUSIC+4                      ; de-init music

	lea       $ffff8800.w,a0         ; Cut sound
	move.l    #$8000000,(a0)
	move.l    #$9000000,(a0)
	move.l    #$a000000,(a0)
	
	lea	Save_all,a0                  ; Restore parameters
	move.b	(a0)+,$fffffa03.w
	move.b	(a0)+,$fffffa07.w
	move.b	(a0)+,$fffffa09.w
	move.b	(a0)+,$fffffa11.w
	move.b	(a0)+,$fffffa13.w
	move.b	(a0)+,$fffffa15.w
	move.b	(a0)+,$fffffa17.w
	move.b	(a0)+,$fffffa19.w

	move.b	(a0)+,$fffffa1b.w
	move.b	(a0)+,$fffffa1d.w
	move.b	(a0)+,$fffffa1f.w
	move.b	(a0)+,$fffffa21.w
	
	move.b	(a0)+,$ffff8201.w
	move.b	(a0)+,$ffff8203.w
	move.b	(a0)+,$ffff820a.w
	move.b	(a0)+,$ffff820d.w
	
	lea	Save_rest,a0                 ; Restore parameters
	move.l	(a0)+,$068.w
	move.l	(a0)+,$070.w
	move.l	(a0)+,$110.w
	move.l	(a0)+,$114.w
	move.l	(a0)+,$118.w
	move.l	(a0)+,$120.w
	move.l	(a0)+,$134.w
	move.l	(a0)+,$484.w

	movem.l	(a0),d0-d7               ; Restore palette system
	movem.l	d0-d7,$ffff8240.w

	bset.b #3,$fffffa17.w            ; Active Timer C

	stop	#$2300

	bsr	flush                        ; Restore keyboard and mouse
	move.b	#8,d0
	bsr	setkeyboard	
	bsr	show_mouse

Old_Resol:                         ; Restore Old Screen & Resolution
	move	#0,-(sp)
Old_Screen:
	move.l	#0,-(sp)
	move.l	(sp),-(sp)
	move	#5,-(sp)
	trap	#14
	lea	12(sp),sp

	move.w	#$25,-(a7)               ; VSYNC
	trap	#14
	addq.w	#2,a7

	rts

hide_mouse:
	movem.l	d0-d2/a0-a2,-(sp)
	dc.w	$a00a
	movem.l	(sp)+,d0-d2/a0-a2
	rts

show_mouse:
	movem.l	d0-d2/a0-a2,-(sp)
	dc.w	$A009
	movem.l	(sp)+,d0-d2/a0-a2
	rts

flush:	lea	$FFFFFC00.w,a0
.flush:	move.b	2(a0),d0
	btst	#0,(a0)
	bne.s	.flush
	rts

setkeyboard:
.wait:	btst	#1,$fffffc00.w
	beq.s	.wait
	move.b	d0,$FFFFFC02.w
	rts

clear_bss:
	lea	bss_start,a0
.loop:	clr.l	(a0)+
	cmp.l	#bss_end,a0
	blt.s	.loop
	rts

	IFEQ	FADE_INTRO
************************************************
*           FADING WHITE TO BLACK              *
*         (Don't use VBL with it !)            *
************************************************
fadein:	move.l	#$777,d0
.deg:	bsr.s	wart
	bsr.s	wart
	bsr.s	wart
	lea	$ffff8240.w,a0
	moveq	#15,d1
.chg1:	move.w	d0,(a0)+
	dbf	d1,.chg1
	sub.w	#$111,d0
	bne.s	.deg
	clr.w	$ffff8240.w
	rts

wart:	move.l	d0,-(sp)
	move.l	$466.w,d0
.att:	cmp.l	$466.w,d0
	beq.s	.att
	move.l	(sp)+,d0
	rts
	ENDC

************************************************
*                                              *
*               Sub Routines                   *
*                                              *
************************************************



******************************************************************
	SECTION	DATA
******************************************************************

Pal:	
	dc.w	$000,$777,$111,$222,$333,$444,$555,$666
	dc.w	$777,$111,$222,$333,$444,$555,$666,$777

* Full data here :
* >


* <

MUSIC:
	incbin	*.snd                    ; Not compressed please !!!
	even

******************************************************************
	SECTION	BSS
******************************************************************

bss_start:

* Full data here :
* >


* <

Vsync:	ds.w	1
Save_stack:	ds.l	1

Save_all:
	ds.b	8	* Mfp : fa03.w -> fa19.w
	ds.b	4	* Mfp : fa1b.w -> fa21.w
	ds.b	4	* Video : f8201.w -> f820d.w

Save_rest:
	ds.l	1	* Autovector (HBL)
	ds.l	1	* Autovector (VBL)
	ds.l	1	* Timer D (USART timer)
	ds.l	1	* Timer C (200hz Clock)
	ds.l	1	* Keyboard/MIDI (ACIA) 
	ds.l	1	* Timer B (HBL)
	ds.l	1	* Timer A
	ds.l	1	* Output Bip Bop
Palette:
	ds.w	16	* Palette

Zorro_screen1:	
	ds.b	256
start1:	
	ds.b	160*200
	IFEQ	BOTTOM_BORDER
	ds.b	160*50
	ENDC
	IFEQ	TOPBOTTOM_BORDER
	ds.b	160*90
	ENDC
Zorro_screen1_len:	equ	*-start1

Zorro_screen2:	
	ds.b	256
start2:	
	ds.b	160*200
	IFEQ	BOTTOM_BORDER
	ds.b	160*50
	ENDC
	IFEQ	TOPBOTTOM_BORDER
	ds.b	160*90
	ENDC
Zorro_screen2_len:	equ	*-start2

bss_end:

******************************************************************
	END
******************************************************************
