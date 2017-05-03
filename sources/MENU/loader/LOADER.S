***************************************
* // LOADER.PRG                    // *
***************************************
* // Loader "PEXEC 0" by Zorro 2 & // *
* // Maartau of NoExtra (11/2009)  // *
* // http://www.noextra-team.com/  // *
***************************************
  OPT c+ ; Case sensitivity ON        *
  OPT d- ; Debug OFF                  *
  OPT o- ; All optimisations OFF      *
  OPT w- ; Warnings OFF               *
  OPT x- ; Extended debug OFF         *
***************************************

***************************************************************
	SECTION	TEXT                                           // *
***************************************************************

Begin
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

	bsr	set_super                    ; Save for Restoring
	dc.w	$a00a
	bsr	get_original
	bsr	get_old_palette
	bsr	set_low_rez

	lea	LOGO_INTRO_Palette,a0
	bsr	set_new_palette

	movea.l	screen_base(pc),a1       ; Copy Logo Intro
	adda.l	#160*((200-40)/2),a1
	movea.l	#LOGO_INTRO_Img,a0
	move.l	#160*40/4-1,d0
	move.l	(a0)+,(a1)+
	dbf	d0,*-2

	move.w	#100,d7                  ; Waiting loop...
.display_logo:
	bsr	synchro_VBL
	dbra	d7,.display_logo

	lea	$484.w,a3                    ; Cut "Bip"
	move.b	(a3),old_484
	clr.b	(a3)

	lea       bufferfile,a0          ; Generate files board
	move.l    #null,(a0)+
	move.l    #null,(a0)+
	move.l    #dmofile_1,(a0)+
	move.l    #dmofile_2,(a0)+
	move.l    #dmofile_3,(a0)+
	move.l    #dmofile_4,(a0)+
	move.l    #dmofile_5,(a0)+
	move.l    #dmofile_6,(a0)+
	move.l    #dmofile_7,(a0)+
	move.l    #dmofile_8,(a0)+
	move.l    #dmofile_9,(a0)+
	move.l    #dmofile_10,(a0)+

	bsr	Send_ikbd                    ; Reset IKBD

loader_loop:
	bsr	cls_scr                      ; Fast Clear Screen

	bsr	Display_LOADING              ; Display texte LOADING

	clr.l	$40.w                      ; Memory access to choose file to execute

	pea	null(pc)                     ; Load Menu (PEXEC)
	pea	null(pc)
	pea	menufile(pc)
	clr.w	-(sp)
	move.w	#75,-(sp)
	trap	#1
	adda.l	#16,sp

	tst.l	d0                         ; No Menu to load ?
	bne.w	exit                       ; Go back to the GEM desktop

	bsr	Display_LOADING              ; Display texte LOADING

	bsr	Stop_Keyboard                ; Purge keybord
	MOVEQ #$13,D0                    ; Pause keyboard...
	BSR Writeikbd                    ; ...stop from sending
	MOVEQ #$11,D0                    ; Resume keyboard
	BSR Writeikbd                    ; No Key sending for an another program

	move.l	$40.w,d0                 ; Check the value sent by the Menu

	cmp.w	#1,d0                      ; Test ESCAPE Key sent to quit ?
	beq.w	exit

	cmp.w	#2,d0                      ; Then test the value
	blt	exit
	cmp.w	#12,d0                     ; If from Key F1 ... F10 ?
	bgt	exit

	lsl.w	#2,d0                      ; Yes it's a function key sent !
	lea	bufferfile,a0                ; Seek right file right now
	movea.l	0(a0,d0.w),a0

	pea	null                         ; Execute file in memory
	pea	null
	move.l	a0,-(sp)                 ; Name of the program to execute
	clr.w	-(sp)
	move.w	#75,-(sp)                ; #PEXEC $4B
	trap	#1
	adda.l	#16,sp

	move.l	d0,-(sp)
	bsr	cls_scr                      ; Fast Clear Screen
	move.l	(sp)+,d0

	tst.l	d0                         ; Loading Error ?
	beq.s	no_error

error:
	bsr	Display_ERROR                ; Display texte ERROR

	move.w	#100,d7                  ; Wait a while...
.wait_more:
	bsr	synchro_VBL
	dbra	d7,.wait_more

	bsr.s	boucle

no_error:
	bsr	Display_LOADING              ; Display texte LOADING

boucle:
	lea	$ffff8800.w,a0               ; Cut sound and noises
	move.l	#$8000000,(a0)
	move.l	#$9000000,(a0)
	move.l	#$a000000,(a0)

	bsr	set_low_rez                  ; Force the Low Resolution !

	bra.w	loader_loop                ; Loop an reload ...

exit:
	move.b	old_484(pc),$484.w       ; Restore old value
	bsr	cls_scr
	bsr	restaure_original
	bsr	set_old_palette
	bsr	set_user

	move.w	#$0,-(sp)	               ; Return to GEM desktop
	trap	#1

***************************************************************
; SUB-ROUTINES                                             // *
***************************************************************

synchro_VBL:
	move.l	d0,-(sp)
	move.l	$466.w,d0                ; Counter for vblank interrupts
.att:
	cmp.l	$466.w,d0
	beq.s	.att
	move.l	(sp)+,d0
	rts

set_super:
	clr.l	-(sp)		                   ; Set super stack equal
	move.w	#$20,-(sp)	             ; to user stack before call
	trap	#1
	addq.l	#6,sp		                 ; correct stack
	move.l	d0,stack_save            ; save old supervisor stack value
	rts

set_user:
	move.l	stack_save,-(sp)
	move.w	#$20,-(sp)
	trap	#1		                     ; back to user
	addq.l	#6,sp		                 ; correct stack
	rts

get_old_palette:                   ; Managed systems colors
	move.w	#8-1,d0
	lea	$ff8240,a0
	lea	old_palette,a1
get_old:
	move.l	(a0)+,(a1)+
	dbf	d0,get_old
	rts

set_new_palette:                   ; Managed palette colors
	bra	set_pal
set_old_palette:
	lea	old_palette,a0
set_pal:
	lea	$ff8240,a1
	move.w	#8-1,d0
set_p:	move.l	(a0)+,(a1)+
	dbf	d0,set_p
	rts

get_original:
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,screen_base           ; Save old Screen
	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	move.w	d0,original_rez          ; Save resolution Screen
	rts

restaure_original:
	move	original_rez,-(sp)         ; Restore Old Screen & Resolution
	move.l	screen_base,-(sp)        ;
	move.l	(sp),-(sp)               ;
	move	#5,-(sp)                   ;
	trap	#14                        ;
	lea	12(sp),sp                    ;

	move.w	#$25,-(a7)               ; VSYNC()
	trap	#14                        ;
	addq.w	#2,a7                    ;
	rts

set_low_rez:                       ; Set Low Resolution by Default
	clr.w	-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	rts

cls_scr:                           ; Clear a Screen 160 x 200 quickly !
	movea.l	screen_base,a0
	lea	160*200(a0),a0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	move.l	d1,a1
	move.l	d1,a2
	move.l	d1,a3
	move.l	d1,a4
	move.l	d1,a5
	move.l	d1,a6
	move	#152,d0
.clear:
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	dbra	d0,.clear
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d5,-(a0)
	rts

Writeikbd:                         ; Write d0 to IKBD
	BTST.B #1,$FFFFFC00.W            ;
	BEQ.S Writeikbd                  ; wait for ready
	MOVE.B D0,$FFFFFC02.W            ; and send...
	RTS

Send_ikbd:
	lea.l	ikbd_data(pc),a6
	moveq.s	#2,d0
	move.w	#$8001,(a6)              ; reset IKBD
	lea.l	$fffffc00.w,a0
	lea.l	ikbd_data(pc),a1
.waitkey:
	btst	#1,(a0)
	beq.s	.waitkey
	move.b	(a1)+,2(a0)
	subq.w	#1,d0
	bne.s	.waitkey
	rts

Stop_Keyboard:
	moveq	#-%01100000,d1
	and.b	$fffffc00.w,d1	           ; Keep Needed Bits
	beq.s	.Leave_Test                ; Is Sending Over?
	move.b	$fffffc02.w,d1	         ; If Not, Free Receive Register
	bra.s	Stop_Keyboard	             ; And Go Back to Test...
.Leave_Test:
	rts

Display_ERROR:
	lea	ERROR_Palette,a0             ; Put Palette
	bsr	set_new_palette
	movea.l	screen_base(pc),a0       ; Put ERROR Logo
	lea     160*((200-5)/2)(a0),a0
	movea.l	#ERROR_Img,a1
	move.l	#160*5/4-1,d0
	move.l	(a1)+,(a0)+
	dbf	d0,*-2
	rts

Display_LOADING:
	lea	LOAD_Palette,a0              ; Put Palette
	bsr	set_new_palette
	movea.l	screen_base(pc),a0       ; Put LOADING Logo
	lea     160*((200-5)/2)(a0),a0
	movea.l	#LOAD_Img,a1
	move.l	#160*5/4-1,d0
	move.l	(a1)+,(a0)+
	dbf	d0,*-2
	rts

***************************************************************
 SECTION	DATA                                             // *
***************************************************************

null:
	ds.l	1
menufile:
	dc.b	'EXTRA_V8.PRG',0     * Name of the Menu
dmofile_1:                   * 
	dc.b	'AL_ATF.PRG',0       * Program #1
dmofile_2:                   *
	dc.b	'AL_BILL.PRG',0          * Program #2
dmofile_3:                   *
	dc.b	'AL_CHALL.PRG',0     * Program #3
dmofile_4:                   *
	dc.b	'AL_GLOB.PRG',0      * Program #4
dmofile_5:                   *
	dc.b	'AL_LADEC.PRG',0     * Program #6
dmofile_6:                   *
	dc.b	'BENTLY3.PRG',0      * Program #6
dmofile_7:                   *
	dc.b	'BENTLY4.PRG',0      * Program #7
dmofile_8:                   *
	dc.b	'HERMINE.PRG',0      * Program #8
dmofile_9:                   *
	dc.b	'MAT45AN.PRG',0      * Program #9
dmofile_10:                  *
	dc.b	'OMONDE.PRG',0       * Program #10
	even
bufferfile:
	ds.l	12

LOAD_Palette:
	dc.w	$0001,$0000,$0fff,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
LOAD_Img:
	incbin	"LOAD.IMG"
	even
ERROR_Palette:
	dc.w	$0FFF,$0000,$0000,$0f00,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
ERROR_Img:
	incbin	"ERROR.IMG"
	even
LOGO_INTRO_Palette:
	dc.w	$0001,$07AF,$0E2F,$0626,$062F,$0D9F,$051F,$0C07
	dc.w	$0C8F,$0CBD,$0213,$0809,$0657,$0FBF,$0547,$0FFF
LOGO_INTRO_Img:
	incbin	"NOEXVIO.IMG"	;	Logo from Mister.A - 320x40
	even

***************************************************************
 SECTION	BSS                                              // *
***************************************************************

stack_save:
	ds.l	1
screen_base:
	ds.l	1
original_rez:
	ds.w	1
old_484:
	ds.w	1
old_palette:
	ds.w	16
ikbd_data:
	ds.l	4

******************************************************************
	END                                                       // *
******************************************************************
