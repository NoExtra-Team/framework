***************************************
* // INTROSTE.PRG                  // *
***************************************
* // Asm Intro Code Atari ST v0.42 // *
* // by Zorro 2/NoExtra (05/12/11) // *
* // http://www.noextra-team.com/  // *
***************************************
* // Original code :               // *
* // Gfx logo      :               // *
* // Gfx font      :               // *
* // Music         :               // *
* // Release date  : xx/xx/2012    // *
* // Update date   : xx/xx/2012    // *
***************************************
  OPT c+ ; Case sensitivity on        *
  OPT d- ; Debug off                  *
  OPT o- ; All optimisations off      *
  OPT w- ; Warnings off               *
  OPT x- ; Extended debug off         *
***************************************

***************************************************************
	SECTION	TEXT                                             // *
***************************************************************

**************************** OVERSCAN ******************************
BOTTOM_BORDER    equ 0         ; Use the bottom overscan           *
TOPBOTTOM_BORDER equ 1         ; Use the top and bottom overscan   *
NO_BORDER        equ 1         ; Use a standard screen             *
********************************************************************
PATTERN          equ $00000000 ; See the screen plan               *
SEEMYVBL         equ 1         ; See CPU used if you press ALT key *
ERROR_SYS        equ 1         ; Manage Errors System              *
FADE_INTRO       equ 0         ; Fade White to black palette       *
TEST_STE         equ 0         ; Code only for Atari STE machine   *
********************************************************************
*            Remarque : 0 = I use it / 1 = no need !               *
********************************************************************

Begin:
	move    SR,d0                    ; Test supervisor mode
	btst    #13,d0                   ; Specialy for relocation
	bne.s   mode_super_yet           ; programs
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
	
	clr.l	-(sp)                      ; Supervisor mode
	move.w	#32,-(sp)                ;
	trap	#1                         ;
	addq.l	#6,sp                    ;
	move.l	d0,Save_stack            ; Save adress of stack
mode_super_yet:

 IFEQ TEST_STE
	move.l	$5a0,a0                  ; Test STE machine
	cmp.l	#$0,a0                     ;
	beq	EXIT                         ; Pas de cookie_jar donc un vieux ST.
	move.l	$14(a0),d0               ;
	cmp.l	#$0,d0                     ; _MCH=0 alors c' est un ST-STf.
	beq	EXIT                         ;
 ENDC

	bsr	wait_for_drive               ; Stop floppy driver

	bsr	clear_bss                    ; Clean BSS stack
	
	bsr	Save_and_init_st             ; Save system parameters

	bsr	Init_screens                 ; Screen initialisations

	jsr	Multi_boot                   ; Multi Atari Boot code

	bsr	Init                         ; Initialisations

**************************** MAIN LOOP ************************>

default_loop:

	bsr	Wait_vbl                     ; Waiting after the VBL

	IFEQ	SEEMYVBL
	clr.b	$ffff8240.w
	ENDC

* < Put your code here >

	bsr	Display_Spectrum

* <

	lea     physique(pc),a0          ; Swapping two Screens
	move.l	(a0),d0                  ;
	move.l	4(a0),(a0)+              ;
	move.l	d0,(a0)                  ;
	move.b  d0,$ffff820d.w           ;
	move    d0,-(sp)                 ;
	move.b  (sp)+,d0                 ;
	move.l  d0,$ffff8200.w           ;

	IFEQ	SEEMYVBL
	cmp.b	#$38,$fffffc02.w           ; ALT key pressed ?
	bne.s	next_key                   ;
	move.b	#7,$ffff8240.w           ; See the rest of CPU
next_key:                          ;
	ENDC

	cmp.b	#$39,$fffffc02.w           ; SPACE key pressed ?
	bne	default_loop

**************************** MAIN LOOP ************************<

SORTIE:
	bsr	Restore_st                   ; Restore all registers

EXIT:
	move.l	Save_stack,-(sp)         ; Restore adress of stack
	move.w	#32,-(sp)                ; Restore user Mode
	trap	#1                         ;
	addq.l	#6,sp                    ;

	clr.w	-(sp)                      ; Pterm()
	trap	#1                         ; EXIT program

***************************************************************
*                                                             *
*                 Initialisations Routines                    *
*                                                             *
***************************************************************
Init:	movem.l	d0-d7/a0-a6,-(a7)

	IFEQ	FADE_INTRO
	bsr	fadein                       ; Fading white to black
	clr.w	$ffff8240.w                ; Set black background
	ENDC

	moveq	#1,d0                      ; Choice of the music (1 is default)
	jsr	MUSIC+0                      ; Init SNDH music

	lea	Vbl(pc),a0                   ; Launch VBL
	move.l	a0,$70.w                 ;

	bsr	DoBLiTTER__Copie_Image       ; Put picture on Screen

	lea	Palette_Image,a0             ; Put palette
	lea	$ffff8240.w,a1               ;
	movem.l	(a0),d0-d7               ;
	movem.l	d0-d7,(a1)               ;

	movem.l	(a7)+,d0-d7/a0-a6
	rts

***************************************************************
*                                                             *
*                       Screen Routines                       *
*                                                             *
***************************************************************
 IFEQ	BOTTOM_BORDER
SIZE_OF_SCREEN equ 160*250        ; Screen + Lower Border size
 ENDC
 IFEQ	TOPBOTTOM_BORDER
SIZE_OF_SCREEN equ 160*300        ; Screen + Top & Lower Border size
 ENDC
 IFEQ	NO_BORDER
SIZE_OF_SCREEN equ 160*200        ; Only Screen size
 ENDC

Init_screens:
	movem.l	d0-d7/a0-a6,-(a7)

	move.l	#Screen_1,d0             ; Set physical Screen #1
	add.w	#$ff,d0                    ;
	sf	d0                           ;
	move.l	d0,physique              ;

	move.l	#Screen_2,d0             ; Set logical Screen #2
	add.w	#$ff,d0                    ;
	sf	d0                           ;
	move.l	d0,physique+4            ;

	move.l	physique(pc),a0          ; Put PATTERN in two Screens
	move.l	physique+4(pc),a1        ;
	move.w  #(SIZE_OF_SCREEN)/4-1,d7 ;
	move.l  #PATTERN,(a0)+           ;
	move.l  #PATTERN,(a1)+           ;
	dbf	    d7,*-12                  ;

	move.l	physique(pc),d0          ; Put physical Screen
	move.b	d0,d1                    ;
	lsr.w	#8,d0                      ;
	move.b	d0,$ffff8203.w           ;
	swap	d0                         ;
	move.b	d0,$ffff8201.w           ;
	move.b	d1,$ffff820d.w           ;

	movem.l	(a7)+,d0-d7/a0-a6
	rts

physique:
	ds.l 2                           ; Number of screens declared

***************************************************************
*                                                             *
*                        Vbl Routines                         *
*                                                             *
***************************************************************
Vbl:	st	Vsync                    ; Synchronisation

	movem.l	d0-d7/a0-a6,-(a7)

	IFEQ	BOTTOM_BORDER
	clr.b   $fffffa1b.w              ; Disable timer B
	lea	Over_rout(pc),a0             ; HBL
	move.l	a0,$120.w                ; Timer B vector
	move.b	#199,$fffffa21.w         ; At the position
	move.b	#8,$fffffa1b.w           ; Launch HBL
	ENDC

	IFEQ	TOPBOTTOM_BORDER
	move.l	a0,-(a7)
	clr.b	(tacr).w                   ; Stop timer A
	lea	topbord(pc),a0               ; Launch HBL
	move.l	a0,$134.w                ; Timer A vector
	move.b	#99,(tadr).w             ; Countdown value for timer A
	move.b	#4,(tacr).w              ; Delay mode, clock divided by 50
	move.l	(a7)+,a0
	ENDC

	IFEQ	NO_BORDER
* // Declarations here ...
	ENDC

	jsr 	(MUSIC+8)                  ; Play SNDH music

	movem.l	(a7)+,d0-d7/a0-a6
	rte

Wait_vbl:                          ; Test Synchronisation
	move.l	a0,-(a7)                 ;
	lea	Vsync,a0                     ;
	sf	(a0)                         ;
.loop:	tst.b	(a0)                 ;
	beq.s	.loop                      ;
	move.l	(a7)+,a0                 ;
	rts

 IFEQ	NO_BORDER
***************************************************************
*                                                             *
*               < Here is the no border rout >                *
*                                                             *
***************************************************************
* // Declarations here ...
 ENDC

	IFEQ	BOTTOM_BORDER
***************************************************************
*                                                             *
*             < Here is the lower border rout >               *
*                                                             *
***************************************************************
Over_rout:
	sf	$fffffa21.w                  ; Stop Timer B
	sf	$fffffa1b.w                  ;
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

my_hbl:
	rte

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
	move.l	(a7)+,a0                 ;
	bclr.b	#5,(isra).w              ; Clear end of interrupt flag
	rte

botbord:
	move	#$2100,SR                  ;
	stop	#$2100                     ; sync with interrupt
	clr.b	(tacr).w                   ; stop timer A
	dcb.w	78,$4E71                   ; 78 nops
	clr.b	(herz).w                   ; 60 Hz
	dcb.w	18,$4E71                   ; 18 nops
	move.b	#2,(herz).w              ; 50 Hz
	bclr.b	#5,(isra).w              ;
	rte
	ENDC

***************************************************************
*                                                             *
*                Save/Restore System Routines                 *
*                                                             *
***************************************************************
Save_and_init_st:

	moveq #$13,d0                    ; Pause keyboard
	bsr	sendToKeyboard               ;

	move #$2700,sr
		
	lea	Save_all,a0                  ; Save adresses parameters
	move.b	$fffffa01.w,(a0)+        ; Datareg
	move.b	$fffffa03.w,(a0)+        ; Active edge
	move.b	$fffffa05.w,(a0)+        ; Data direction
	move.b	$fffffa07.w,(a0)+        ; Interrupt enable A
	move.b	$fffffa13.w,(a0)+        ; Interupt Mask A
	move.b	$fffffa09.w,(a0)+        ; Interrupt enable B
	move.b	$fffffa15.w,(a0)+        ; Interrupt mask B
	move.b	$fffffa17.w,(a0)+        ; Automatic/software end of interupt
	move.b	$fffffa19.w,(a0)+        ; Timer A control
	move.b	$fffffa1b.w,(a0)+        ; Timer B control
	move.b	$fffffa1d.w,(a0)+        ; Timer C & D control
	move.b	$fffffa27.w,(a0)+        ; Sync character
	move.b	$fffffa29.w,(a0)+        ; USART control
	move.b	$fffffa2b.w,(a0)+        ; Receiver status
	move.b	$fffffa2d.w,(a0)+        ; Transmitter status
	move.b	$fffffa2f.w,(a0)+        ; USART data

	move.b	$ffff8201.w,(a0)+        ; Save screen addresses
	move.b	$ffff8203.w,(a0)+
	move.b	$ffff820a.w,(a0)+
	move.b	$ffff820d.w,(a0)+
	
	lea	Save_rest,a0                 ; Save adresses parameters
	move.l	$068.w,(a0)+             ; HBL
	move.l	$070.w,(a0)+             ; VBL
	move.l	$110.w,(a0)+             ; TIMER D
	move.l	$114.w,(a0)+             ; TIMER C
	move.l	$118.w,(a0)+             ; ACIA
	move.l	$120.w,(a0)+             ; TIMER B
	move.l	$134.w,(a0)+             ; TIMER A
	move.l	$484.w,(a0)+             ; Conterm

	movem.l	$ffff8240.w,d0-d7        ; Save palette GEM system
	movem.l	d0-d7,(a0)

	bclr	#3,$fffffa17.w             ; Stop Timer C

	IFEQ	BOTTOM_BORDER
	clr.b	$fffffa07.w                ; Interrupt enable A (Timer-A & B)
	clr.b	$fffffa09.w                ; Interrupt enable B (Timer-C & D)
	sf	$fffffa21.w                  ; Timer B data (number of scanlines to next interrupt)
	sf	$fffffa1b.w                  ; Timer B control (event mode (HBL))
	lea	Over_rout(pc),a0             ; Launch HBL
	move.l	a0,$120.w                ;
	bset	#0,$fffffa07.w             ; Timer B vector
	bset	#0,$fffffa13.w             ; Timer B on
	ENDC

	IFEQ	TOPBOTTOM_BORDER
	move.b	#%00100000,(iera).w      ; Enable Timer A
	move.b	#%00100000,(imra).w
	and.b	#%00010000,(ierb).w        ; Disable all except Timer D
	and.b	#%00010000,(imrb).w
	or.b	#%01000000,(ierb).w        ; Enable keyboard
	or.b	#%01000000,(imrb).w
	clr.b	(tacr).w                   ; Timer A off
	lea	my_hbl(pc),a0
	move.l	a0,$68.w                 ; Horizontal blank
	lea	topbord(pc),a0
	move.l	a0,$134.w                ; Timer A vector
	ENDC

	IFEQ	NO_BORDER
	clr.b	$fffffa07.w                ; Interrupt enable A (Timer-A & B)
	clr.b	$fffffa09.w                ; Interrupt enable B (Timer-C & D)
	ENDC

	stop	#$2300

	clr.b	$484.w                     ; No bip, no repeat

	move	#4,-(sp)                   ; Save & Change Resolution (GetRez)
	trap	#14	                       ; Get Current Res.
	addq.l	#2,sp                    ;
	move	d0,Old_Resol+2             ; Save it

	move	#3,-(sp)                   ; Save Screen Address (Logical)
	trap	#14
	addq.l	#2,sp
	move.l	d0,Old_Screen+2

	moveq #$11,d0                    ; Resume keyboard
	bsr	sendToKeyboard               ;

	moveq #$12,d0                    ; Kill mouse
	bsr	sendToKeyboard               ;

	bsr	flush                        ; Init keyboard

	sf	$ffff8260.w                  ; Basse resolution if you don't use Multi_boot

	rts

Restore_st:

	moveq #$13,d0                    ; Pause keyboard
	bsr	sendToKeyboard               ;

	move #$2700,sr

	jsr	MUSIC+4                      ; Stop SNDH music

	lea       $ffff8800.w,a0         ; Cut sound
	move.l    #$8000000,(a0)         ; Voice A
	move.l    #$9000000,(a0)         ; Voice B
	move.l    #$a000000,(a0)         ; Voice C

	IFEQ	ERROR_SYS
	bsr	OUTPUT_TRACE_ERROR
	ENDC

	lea	Save_all,a0                  ; Restore adresses parameters
	move.b	(a0)+,$fffffa01.w        ; Datareg
	move.b	(a0)+,$fffffa03.w        ; Active edge
	move.b	(a0)+,$fffffa05.w        ; Data direction
	move.b	(a0)+,$fffffa07.w        ; Interrupt enable A
	move.b	(a0)+,$fffffa13.w        ; Interupt Mask A
	move.b	(a0)+,$fffffa09.w        ; Interrupt enable B
	move.b	(a0)+,$fffffa15.w        ; Interrupt mask B
	move.b	(a0)+,$fffffa17.w        ; Automatic/software end of interupt
	move.b	(a0)+,$fffffa19.w        ; Timer A control
	move.b	(a0)+,$fffffa1b.w        ; Timer B control
	move.b	(a0)+,$fffffa1d.w        ; Timer C & D control
	move.b	(a0)+,$fffffa27.w        ; Sync character
	move.b	(a0)+,$fffffa29.w        ; USART control
	move.b	(a0)+,$fffffa2b.w        ; Receiver status
	move.b	(a0)+,$fffffa2d.w        ; Transmitter status
	move.b	(a0)+,$fffffa2f.w        ; USART data
	
	move.b	(a0)+,$ffff8201.w        ; Restore screen addresses
	move.b	(a0)+,$ffff8203.w        ;
	move.b	(a0)+,$ffff820a.w        ;
	move.b	(a0)+,$ffff820d.w        ;
	
	lea	Save_rest,a0                 ; Restore adresses parameters
	move.l	(a0)+,$068.w             ; HBL
	move.l	(a0)+,$070.w             ; VBL
	move.l	(a0)+,$110.w             ; TIMER D
	move.l	(a0)+,$114.w             ; TIMER C
	move.l	(a0)+,$118.w             ; ACIA
	move.l	(a0)+,$120.w             ; TIMER B
	move.l	(a0)+,$134.w             ; TIMER A
	move.l	(a0)+,$484.w             ; Conterm

	movem.l	(a0),d0-d7               ; Restore palette GEM system
	movem.l	d0-d7,$ffff8240.w        ;

	bset.b #3,$fffffa17.w            ; Re-active Timer C

	stop	#$2300

	moveq #$11,d0                    ; Resume keyboard
	bsr	sendToKeyboard               ;

	moveq #$8,d0                     ; Restore mouse
	bsr	sendToKeyboard               ;

	bsr	flush                        ; Init keyboard

Old_Resol:                         ; Restore Old Screen & Resolution
	move	#0,-(sp)                   ;
Old_Screen:                        ;
	move.l	#0,-(sp)                 ;
	move.l	(sp),-(sp)               ;
	move	#5,-(sp)                   ;
	trap	#14                        ;
	lea	12(sp),sp                    ;

	move.w	#$25,-(a7)               ; VSYNC()
	trap	#14                        ;
	addq.w	#2,a7                    ;

	rts

flush:	lea	$FFFFFC00.w,a0
.flush:	move.b	2(a0),d0
	btst	#0,(a0)
	bne.s	.flush
	rts

sendToKeyboard:
.wait:	btst	#1,$fffffc00.w
	beq.s	.wait
	move.b	d0,$FFFFFC02.w
	rts

wait_for_drive:
	move.w	$ffff8604.w,d0
	btst	#7,d0
	bne.s	wait_for_drive
	rts

clear_bss:
	lea	bss_start,a0
.loop:	clr.l	(a0)+
	cmp.l	#bss_end,a0
	blt.s	.loop
	rts

	IFEQ	FADE_INTRO
***************************************************************
*                                                             *
*                    FADING WHITE TO BLACK                    *
*                  (Don't use VBL with it !)                  *
*                                                             *
***************************************************************
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

***************************************************************
; SUB-ROUTINES                                             // *
***************************************************************

***************************************************************
*                                                             *
*                 Spectrum Analyser routines                  *
*                                                             *
***************************************************************
WIDTH_PICTURE  equ 124
HEIGHT_PICTURE equ 161
NUMBER_OF_PLAN equ 4

DoBLiTTER__Copie_Image:
	movem.l	d0-d7/a0-a1,-(sp)

; Init operations
	bsr	Clear_halftone                ; Clean operation Blitter

; From adress
	move.l	#IMAGE,a0                ; FROM ADRESS DATA
	move.w	#0,d2                    ; LEFT FROM ADRESS DATA
	move.w	#0,d3                    ; TOP FROM ADRESS DATA
	move.w	#WIDTH_PICTURE,d4        ; WIDTH of bloc
	move.w	#HEIGHT_PICTURE,d5       ; HEIGHT of bloc
	move.w	#NUMBER_OF_PLAN,d6       ; Number of plane

; Destination 1st Screen adress
	move.l	physique(pc),a1          ; TO ADRESS SCREEN
	move.w	#(320/2)-(124/2),d0      ; LEFT TO ADRESS SCREEN
	move.w	#(200/2)-(161/2),d1      ; TOP TO ADRESS SCREEN

	bsr.s	DoBLiTTER__Operation       ; Launch blitter operation

; From adress
	move.l	#IMAGE,a0                ; FROM ADRESS DATA
	move.w	#0,d2                    ; LEFT FROM ADRESS DATA
	move.w	#0,d3                    ; TOP FROM ADRESS DATA
	move.w	#WIDTH_PICTURE,d4        ; WIDTH of bloc
	move.w	#HEIGHT_PICTURE,d5       ; HEIGHT of bloc
	move.w	#NUMBER_OF_PLAN,d6       ; Number of plane

; Destination 2nd Screen adress
	move.l	physique+4(pc),a1        ; TO ADRESS SCREEN
	move.w	#(320/2)-(124/2),d0      ; LEFT TO ADRESS SCREEN
	move.w	#(200/2)-(161/2),d1      ; TOP TO ADRESS SCREEN

	bsr.s	DoBLiTTER__Operation       ; Launch blitter operation

	movem.l	(sp)+,d0-d7/a0-a1
	rts                              ; And return.

DoBLiTTER__Operation:
	move.l	a6,-(sp)

	lea	bitblt(pc),a6                ; Address of blit table
	move.w	d4,0(a6)                 ; Store width. 
	move.w	d5,2(a6)                 ; Store height.
	move.w	d6,4(a6)                 ; Set up number of plan
	move.w	#0,6(a6)                 ; Fg_col
	move.w	#0,8(a6)                 ; Bg_col
	move.b	#3,10(a6)                ; For any resolution
	move.w	d2,14(a6)                ; Store left from position
	move.w	d3,16(a6)                ; Store top from position
	move.l	a0,18(a6)                ; Store 'from' address
	move.w	#8,22(a6)                ; For low resolution (number of plane * 2)
	move.w	d0,28(a6)                ; Store left to position
	move.w	d1,30(a6)                ; Store top to position
	move.l	a1,32(a6)                ; Store 'to' address
	move.w	#8,36(a6)                ; Number of word by line
	move.l	#0,42(a6)                ; Set up blit variables 
	dc.w	$a007                      ; Do the blit!

	move.l	(sp)+,a6
	rts

; Data for the Blit Routine
bitblt:
  DC.W	0       ; Width                        * 0
  DC.W	0       ; Height                       * 2
  DC.W	0       ; No. Planes                   * 4
  DC.W	0       ; Fg_col                       * 6
  DC.W	0       ; Bg_col                       * 8
  DC.L	0       ; Log. ops                     * 10 & 12
  DC.W	0       ; Left source x                * 14
  DC.W	0       ; Top source y                 * 16
  DC.L	0       ; Source screen top address    * 18 & 20
  DC.W	8       ; Word in line (8=low 4=med)   * 22
  DC.W	160     ; 160 for med/low              * 24
  DC.W	2       ;                              * 26
  DC.W	0       ; Left dest x                  * 28
  DC.W	0       ; Top dest y                   * 30
  DC.L	0       ; Dest screen top address      * 32 & 34
  DC.W	8       ; Word in line                 * 36
  DC.W	160     ; Line in plane                * 38
  DC.W	2       ;                              * 40
  DC.L	0       ; Pattern Address              * 42 & 44
  DC.W	0       ;                              * 46
  DC.W	0       ;                              * 48
  DC.W	0       ;                              * 50
  DCB.W	100,$0  ; Filler                       * 52 -> 152
	EVEN

Clear_halftone:
	lea.l $ffff8a00.w,a0             ; 32 bytes halftone memory
	rept 16
	clr.l (a0)+
	endr
	rts

***************************************************************
*                                                             *
*                 Spectrum Analyser routines                  *
*                                                             *
***************************************************************
MAX_BARS equ 80
AFINE    equ 00
ACOURSE  equ 01
BFINE    equ 02
BCOURSE  equ 03
CFINE    equ 04
CCOURSE  equ 05
AAMP     equ 08
BAMP     equ 09
CAMP     equ 10

Display_Spectrum:

; Clear Spectrum in one plane
	move.w #0,$ffff8a20.w            ; Source x inc
	move.w #0,$ffff8a22.w            ; Source y inc
	*move.l empty_adr,$ffff8a24.w    ; Source address
	move.w #-1,$ffff8a28.w           ; Endmask 1
	move.w #-1,$ffff8a2a.w           ; Endmask 2
	move.w #-1,$ffff8a2c.w           ; Endmask 3
	move.w #8,$ffff8a2e.w            ; Dest x inc
	move.w #8,$ffff8a30.w            ; Dest y inc
	move.l	physique(pc),a0
	add.w	#160*188,a0                ; Add 188 lines to start at the end of the screen
	addq.w	#6,a0                    ; Add plane for the color
	move.l a0,$ffff8a32.w            ; Destination address
	move.w #20,$ffff8a36.w           ; x count (n words per line to copy)
	move.w #26,$ffff8a38.w           ; y count (n lines to copy)
	move.b #%00000001,$ffff8a3a.w    ; Blit hop (halftone mix)
	move.b #%00000000,$ffff8a3b.w    ; Blit op (logic op)
	move.b #%11000000,$ffff8a3c.w    ; Blitter control, start blitter

; Calcul Spectrums
	lea	spec_values,a0
	moveq	#(MAX_BARS-1),d0
.cnt_down
	tst.w	(a0)+
	beq.s	.next
	subq.w	#1,-2(a0)
.next
	dbf	d0,.cnt_down

	lea	$ffff8800.w,a1
	lea	spec_values,a2
	lea	spec_data,a3
	moveq	#12,d2

A_channel:
	move.b	#AAMP,(a1)
	move.b	(a1),d1
	and.b	#15,d1
	beq.s	B_channel
	moveq	#0,d0
	move.b	#ACOURSE,(a1)
	move.b	(a1),d0
	lsl.w	#8,d0
	move.b	#AFINE,(a1)
	move.b	(a1),d0
	tst.w	d0
	beq.s	B_channel

	add.w	d0,d0
	move.w	(a3,d0),d0
	bmi.s	B_channel
	add.w	d0,d0
	move.w	d2,(a2,d0)

B_channel:
	move.b	#BAMP,(a1)
	move.b	(a1),d1
	and.b	#15,d1
	beq.s	C_channel
	moveq	#0,d0
	move.b	#BCOURSE,(a1)
	move.b	(a1),d0
	lsl.w	#8,d0
	move.b	#BFINE,(a1)
	move.b	(a1),d0
	tst.w	d0
	beq.s	C_channel

	add.w	d0,d0
	move.w	(a3,d0),d0
	bmi.s	C_channel
	add.w	d0,d0
	move.w	d2,(a2,d0)

C_channel:
	move.b	#CAMP,(a1)
	move.b	(a1),d1
	and.b	#15,d1
	beq.s	print_speccy
	moveq	#0,d0
	move.b	#CCOURSE,(a1)
	move.b	(a1),d0
	lsl.w	#8,d0
	move.b	#CFINE,(a1)
	move.b	(a1),d0
	tst.w	d0
	beq.s	print_speccy

	add.w	d0,d0
	move.w	(a3,d0),d0
	bmi.s	print_speccy
	add.w	d0,d0
	move.w	d2,(a2,d0)

print_speccy:
	movea.l	physique(pc),a0
	add.w	#160*200,a0                ; Add 200 lines to start at the end of the screen
	addq.w	#6,a0                    ; Add plane for the color

	lea	spec_values,a2
	moveq	#(80/4)-1,d1
.loop
	move.w	(a2)+,d0
	beq.s	.nib2
	move.l	a0,a1
	lea	160(a0),a3
	moveq	#%11100000,d2
.loop1	move.b	d2,(a1)
	move.b	d2,(a3)
	lea	-160(a1),a1
	lea	160(a3),a3
	dbf	d0,.loop1

.nib2
	move.w	(a2)+,d0
	beq.s	.nib3
	move.l	a0,a1
	lea	160(a0),a3
	moveq	#%00001110,d2
.loop2	or.b	d2,(a1)
	or.b	d2,(a3)
	lea	-160(a1),a1
	lea	160(a3),a3
	dbf	d0,.loop2

.nib3	move.w	(a2)+,d0
	beq.s	.nib4
	lea	1(a0),a1
	lea	161(a0),a3
	moveq	#%11100000,d2
.loop3	move.b	d2,(a1)
	move.b	d2,(a3)
	lea	-160(a1),a1
	lea	160(a3),a3
	dbf	d0,.loop3

.nib4	move.w	(a2)+,d0
	beq.s	.nonib
	lea	1(a0),a1
	lea	161(a0),a3
	moveq	#%00001110,d2
.loop4	or.b	d2,(a1)
	or.b	d2,(a3)
	lea	-160(a1),a1
	lea	160(a3),a3
	dbf	d0,.loop4

.nonib	addq.w	#8,a0
	dbf	d1,.loop
	rts

***************************************************************
 SECTION	DATA                                             // *
***************************************************************

* Full data here :
* >
; Picture
Palette_Image:
	include "LOGOA2.S"
	even
IMAGE: ; 320 x 161
	incbin	"LOGOA2.IMG"
	even
; Spectrum
spec_data:
	incbin	"SPECTRUM.DAT"
spec_values:
	dcb.w	MAX_BARS,0
	even

* <

MUSIC:	* SNDH music -> Not compressed please !!!
	incbin	"*.SND"
	even

***************************************************************
 SECTION	BSS                                              // *
***************************************************************

bss_start:

* < Full data here >


* <
Vsync:
	ds.w	1

Save_stack:
	ds.l	1

Save_all:
	ds.b	16 * MFP
	ds.b	4	 * Video : f8201.w -> f820d.w

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
	ds.w	16 * Palette System

bss_end:

Screen_1:
	ds.b	256
	ds.b	SIZE_OF_SCREEN
Screen_2:
	ds.b	256
	ds.b	SIZE_OF_SCREEN

***************************************************************
	SECTION	TEXT                                             // *
***************************************************************

	IFEQ	ERROR_SYS
***************************************************************
*                                                             *
*               Error Routines (Dbug 2/Next)                  *
*          http://www.defence-force.org/index.htm             *
*                                                             *
***************************************************************
INPUT_TRACE_ERROR:
	lea $8.w,a0                       ; Adresse de base des vecteurs (Erreur de Bus)
	lea liste_vecteurs,a1             ;
	moveq #10-1,d0                    ; On d�tourne toutes les erreur possibles...
.b_sauve_exceptions:
	move.l (a1)+,d1                   ; Adresse de la nouvelle routine
	move.l (a0)+,-4(a1)               ; Sauve l'ancienne
	move.l d1,-4(a0)                  ; Installe la mienne
	dbra d0,.b_sauve_exceptions
	rts

OUTPUT_TRACE_ERROR:
	lea $8.w,a0
	lea liste_vecteurs,a1
	moveq #10-1,d0
.restaure_illegal:
	move.l (a1)+,(a0)+
	dbra d0,.restaure_illegal
	rts

routine_bus:
	move.w #$070,d0
	bra.s execute_detournement
routine_adresse:
	move.w #$007,d0
	bra.s execute_detournement
routine_illegal:
	move.w #$700,d0
	bra.s execute_detournement
routine_div:
	move.w #$770,d0
	bra.s execute_detournement
routine_chk:
	move.w #$077,d0
	bra.s execute_detournement
routine_trapv:
	move.w #$777,d0
	bra.s execute_detournement
routine_viole:
	move.w #$707,d0
	bra.s execute_detournement
routine_trace:
	move.w #$333,d0
	bra.s execute_detournement
routine_line_a:
	move.w #$740,d0
	bra.s execute_detournement
routine_line_f:
	move.w #$474,d0
execute_detournement:
	move.w #$2700,sr                  ; Deux erreurs � suivre... non mais !

	move.w	#$0FF,d1
.loop:
	move.w d0,$ffff8240.w             ; Effet raster
	move.w #0,$ffff8240.w
	cmp.b #$3b,$fffffc02.w
	dbra d1,.loop

	pea SORTIE                        ; Put the return adress
	move.w #$2700,-(sp)               ; J'esp�re !!!...
	addq.l #2,2(sp)                   ; 24/6
	rte                               ; 20/5 => Total hors tempo = 78-> 80/20 nops

liste_vecteurs:
	dc.l routine_bus	Vert
	dc.l routine_adresse	Bleu
	dc.l routine_illegal	Rouge
	dc.l routine_div	Jaune
	dc.l routine_chk	Ciel
	dc.l routine_trapv	Blanc
	dc.l routine_viole	Violet
	dc.l routine_trace	Gris
	dc.l routine_line_a	Orange
	dc.l routine_line_f	Vert pale
	even
	ENDC

***************************************************************************
*                                                                         *
* Multi Atari Boot code.                                                  *
* If you have done an ST demo, use that boot to run it on these machines: *
* ST, STe, Mega-ST,TT,Falcon,CT60                                         *
* More info:                                                              *
* http://leonard.oxg.free.fr/articles/multi_atari/multi_atari.html        *
*                                                                         *
***************************************************************************
Multi_boot:
	sf $1fe.w
	move.l $5a0.w,d0
	beq noCookie
	move.l d0,a0
.loop:
	move.l (a0)+,d0
	beq noCookie
	cmp.l #'_MCH',d0
	beq.s .find
	cmp.l #'CT60',d0
	bne.s .skip

; CT60, switch off the cache
	pea (a0)

	lea bCT60(pc),a0
	st (a0)

	clr.w -(a7) ; param = 0 ( switch off all caches )
	move.w #5,-(a7) ; opcode
	move.w #160,-(a7)
	trap #14
	addq.w #6,a7
	move.l (a7)+,a0
.skip:
	addq.w #4,a0
	bra.s .loop

.find:
	move.w (a0)+,d7
	beq noCookie ; STF
	move.b d7,$1fe.w

	cmpi.w #1,d7
	bne.s .noSTE
	btst.b #4,1(a0)
	beq.s .noMegaSTE
	clr.b $ffff8e21.w ; 8Mhz MegaSTE

.noMegaSTE:
	bra noCookie

.noSTE:
; => here TT or FALCON

 IFEQ TEST_STE
; Mode STE on Falcon
	bclr.b	#5,$FFFF8007.w
; Blitter at 8Mhz
	bclr.b	#2,$FFFF8007.w
 ENDC

; Always switch off the cache on these machines.
	move.b bCT60(pc),d0
	bne.s .noMovec

	moveq #0,d0
	dc.l $4e7b0002 ; movec d0,cacr ; switch off cache
.noMovec:

	cmpi.w #3,d7
	bne.s noCookie

; Here FALCON
	move.w #$59,-(a7) ;check monitortype (falcon)
	trap #14
	addq.l #2,a7
	lea rgb50(pc),a0
	subq.w #1,d0
	beq.s .setRegs
	subq.w #2,d0
	beq.s .setRegs
	lea vga50(pc),a0

.setRegs:
	move.l (a0)+,$ffff8282.w
	move.l (a0)+,$ffff8286.w
	move.l (a0)+,$ffff828a.w
	move.l (a0)+,$ffff82a2.w
	move.l (a0)+,$ffff82a6.w
	move.l (a0)+,$ffff82aa.w
	move.w (a0)+,$ffff820a.w
	move.w (a0)+,$ffff82c0.w
	move.w (a0)+,$ffff8266.w
	clr.b $ffff8260.w
	move.w (a0)+,$ffff82c2.w
	move.w (a0)+,$ffff8210.w

noCookie:

; Set res for all machines exept falcon or ct60
	cmpi.b #3,$1fe.w
	beq letsGo

	clr.w -(a7) ;set stlow (st/tt)
	moveq #-1,d0
	move.l d0,-(a7)
	move.l d0,-(a7)
	move.w #5,-(a7)
	trap #14
	lea 12(a7),a7

	cmpi.b #2,$1fe.w ; enough in case of TT
	beq.s letsGo

	move.w $468.w,d0
.vsync:
	cmp.w $468.w,d0
	beq.s .vsync

	move.b #2,$ffff820a.w
	clr.b $ffff8260.w

letsGo:
	IFEQ	ERROR_SYS
	bsr	INPUT_TRACE_ERROR
	ENDC
	rts

vga50:
	dc.l $170011
	dc.l $2020E
	dc.l $D0012
	dc.l $4EB04D1
	dc.l $3F00F5
	dc.l $41504E7
	dc.w $0200
	dc.w $186
	dc.w $0
	dc.w $5
	dc.w $50

rgb50:
	dc.l $300027
	dc.l $70229
	dc.l $1e002a
	dc.l $2710265
	dc.l $2f0081
	dc.l $211026b
	dc.w $0200
	dc.w $185
	dc.w $0
	dc.w $0
	dc.w $50

bCT60: dc.b 0
	even

******************************************************************
	END                                                         // *
******************************************************************
