
                                        Intro_46.S           Page 1       5:05:16 pm 9-May-2023        RMAC 2.2.07 (Win32)


    1                                   *****************************************
    2                                   * // INTRO_46.PRG                    // *
    3                                   *****************************************
    4                                   * // Asm Intro Code Atari ST v0.46   // *
    5                                   * // by Zorro 2/NoExtra.             // *
    6                                   * // https://github.com/NoExtra-Team // *
    7                                   *****************************************
    8                                   * // RMAC & MAD MAC 68000 Macro      // *
    9                                   * // Assembler supported with script // *
   10                                   * // http://rmac.is-slick.com/       // *
   11                                   *****************************************
   12                                   * // Original code :                 // *
   13                                   * // Gfx logo      :                 // *
   14                                   * // Gfx font      :                 // *
   15                                   * // Music         : JEDI/SECTOR ONE // *
   16                                   * // Release date  : 06/09/2022      // *
   17                                   * // Update date   : xx/xx/2022      // *
   18                                   *****************************************
   19                                     OPT "~oall" ; All optimisations OFF   *
   20                                     OPT "+o2"   ; Warnings ON             *
   21                                     OPT "~op"   ; Extended debug OFF      *
   22                                     OPT "~o10"  ; Use short format        *  
   23                                   *****************************************
   24                                   
   25                                   **********************************************************************
   26                                   	TEXT                                                          // *
   27                                   **********************************************************************
   28                                   
   29                                   ************************* OVERSCAN MODE ******************************
   30           =00000000               NO_BORDER        equ 0           ; Use a standard Low-screen         *
   31           =00000001               BOTTOM_BORDER    equ 1           ; Use the bottom overscan           *
   32           =00000001               TOPBOTTOM_BORDER equ 1           ; Use the top and bottom overscan   *
   33                                   ***************************** SCREENS ********************************
   34           =00010001               PATTERN          equ $00010001   ; Fill Screens with a plan pattern  *
   35           =00000000               ONE_SCREEN       equ 0           ; One Screen used                   *
   36           =00000001               TWO_SCREENS      equ 1           ; Two Screens used                  *
   37           =00000001               NB_OF_SCREEN     equ TWO_SCREENS ; Number of Screen used             *
   38                                   *************************** PARAMETERS *******************************
   39           =00000000               SEEMYVBL         equ 0           ; See CPU used if you press ALT key *
   40           =00000001               ERROR_SYS        equ 1           ; Manage exit system errors         *
   41           =00000001               FADE_INTRO       equ 1           ; Fade White to black palette       *
   42           =00000001               TEST_STE         equ 1           ; Code only for Atari STE machine   *
   43           =00000000               STF_INITS        equ 0           ; STF compatibility MODE            *
   44           =00000001               BLITTER          equ 1           ; Sync effect with Blitter          *
   45                                   *DEBUGTIMER       equ 0           ; Cut all Timers for tests         *
   46                                   **********************************************************************
   47                                   *              Notes : 0 = I use it / 1 = no need !                  *
   48                                   **********************************************************************
   49                                   
   50                                   Begin:
   51  00000000  2A6F0004               	move.l  4(sp),a5                 ; Address to basepage
   52  00000004  202D000C               	move.l  $0c(a5),d0               ; Length of TEXT segment
   53  00000008  D0AD0014               	add.l   $14(a5),d0               ; Length of DATA segment
   54  0000000C  D0AD001C               	add.l   $1c(a5),d0               ; Length of BSS segment
   55  00000010  D0BC00001000           	add.l   #$1000,d0                ; Length of stackpointer
   56  00000016  D0BC00000100           	add.l   #$100,d0                 ; Length of basepage


                                        Intro_46.S           Page 2       5:05:16 pm 9-May-2023        RMAC 2.2.07 (Win32)


   57  0000001C  220D                   	move.l  a5,d1                    ; Address to basepage
   58  0000001E  D280                   	add.l   d0,d1                    ; End of program
   59  00000020  C2BCFFFFFFFE           	and.l   #-2,d1                   ; Make address even
   60  00000026  2E41                   	move.l  d1,sp                    ; New stackspace
   61                                   
   62  00000028  2F00                   	move.l  d0,-(sp)                 ; Mshrink()
   63  0000002A  2F0D                   	move.l  a5,-(sp)                 ;
   64  0000002C  3F00                   	move.w  d0,-(sp)                 ;
   65  0000002E  3F3C004A               	move.w  #$4a,-(sp)               ;
   66  00000032  4E41                   	trap    #1                       ;
   67  00000034  4FEF000C               	lea     12(sp),sp                ;
   68                                   
   69  00000038  42A7                   	clr.l   -(sp)                    ; Supervisor mode set
   70  0000003A  3F3C0020               	move.w  #32,-(sp)                ;
   71  0000003E  4E41                   	trap    #1                       ;
   72  00000040  5C8F                   	addq.l  #6,sp                    ;
   73  00000042  23C0xxxxxxxx           	move.l  d0,Save_stack            ; Save adress of stack
   74                                   
   75                                   .if (TEST_STE = 0)
   76                                 - 	move.l	$5a0,a0                  ; Test if STE computer
   77                                 - 	cmp.l	#$0,a0                   ;
   78                                 - 	beq.w	EXIT_PRG                 ; No cookie_jar inside an old ST
   79                                 - 	move.l	$14(a0),d0               ;
   80                                 - 	cmp.l	#$0,d0                   ; _MCH=0 then it's an ST-STF-STFM
   81                                 - 	beq.w	EXIT_PRG                 ;
   82                                 - .endif
   83                                   
   84                                   .prgflags 0                          ; Clean BSS stack
   85                                   	
   86  00000048  6100xxxx               	bsr	Save_and_init_st             ; Save system parameters
   87                                   
   88  0000004C  6100xxxx               	bsr	Init_screens                 ; Screen initialisations
   89                                   
   90                                   .if (STF_INITS = 0)
   91  00000050  4EB9xxxxxxxx           	jsr	Multi_boot                   ; Multi Atari Boot code from LEONARD/OXG
   92                                   .endif
   93                                   
   94                                   .if (BLITTER = 0)
   95                                 - .macro Sync_Blit                     ; Macro must be used with blitter effect outside the VBL
   96                                 -                                      ; for synchronisations
   97                                 - .wait_blitter:                       ; Fast Blitter Reboot
   98                                 - 	bset	#7,$ffff8a3c.w
   99                                 - 	nop
  100                                 - 	bne.s	.wait_blitter
  101                                 - .endm
  102                                 - 
  103                                 - 	move.w	#$80,$ffff8a3c.w         ; Launch Blitter !
  104                                 - 	nop
  105                                 - .restart:
  106                                 - 	bset	#7,$ffff8a3c.w
  107                                 - 	nop
  108                                 - 	bne.s	.restart
  109                                 - .endif
  110                                   
  111  00000056  61xx                   	bsr.s	Inits                        ; Other Initialisations
  112                                   


                                        Intro_46.S           Page 3       5:05:16 pm 9-May-2023        RMAC 2.2.07 (Win32)


  113                                   **************************** MAIN LOOP ************************>
  114                                   
  115                                   default_loop:
  116  00000058  6100xxxx               	bsr	Wait_vbl                     ; Waiting after the VBL
  117                                   
  118                                   .if (SEEMYVBL = 0)
  119  0000005C  21F9xxxxxxxx8240       	move.l Default_palette,$ffff8240.w ; init line of CPU
  120                                   .endif
  121                                   
  122                                   * << Put your code here in the main loop >>
  123                                   
  124                                   
  125                                   * <
  126                                   
  127                                   .if (NB_OF_SCREEN = 1)
  128  00000064  41FAxxxx               	lea     physique(pc),a0          ; Swapping Screens
  129  00000068  2010                   	move.l	(a0),d0                  ; if more than one screen
  130  0000006A  20E80004               	move.l	4(a0),(a0)+              ;
  131  0000006E  2080                   	move.l	d0,(a0)                  ;
  132  00000070  11C0820D               	move.b  d0,$ffff820d.w           ;
  133  00000074  3F00                   	move    d0,-(sp)                 ;
  134  00000076  101F                   	move.b  (sp)+,d0                 ;
  135  00000078  21C08200               	move.l  d0,$ffff8200.w           ;
  136                                   .endif
  137                                   
  138                                   .if (SEEMYVBL = 0)
  139  0000007C  0C380038FC02           	cmp.b #$38,$fffffc02.w           ; ALT key pressed ?
  140  00000082  66xx                   	bne.s .next_key                  ;
  141  00000084  11FC00078240           	move.b	#7,$ffff8240.w           ; See the rest of CPU (pink color used)
  142                                   .next_key:                         ;
  143                                   .endif
  144                                   
  145  0000008A  0C380039FC02           	cmp.b #$39,$fffffc02.w           ; SPACE key pressed ?
  146  00000090  66C6                   	bne.s	default_loop
  147                                   
  148                                   **************************** MAIN LOOP ************************<
  149                                   
  150                                   ESCAPE_PRG:
  151  00000092  6100xxxx               	bsr	Restore_st                   ; Restore all registers
  152                                   
  153                                   EXIT_PRG:
  154  00000096  2F39xxxxxxxx           	move.l  Save_stack,-(sp)         ; Restore adress of stack
  155  0000009C  3F3C0020               	move.w  #32,-(sp)                ; Restore user Mode
  156  000000A0  4E41                   	trap    #1                       ;
  157  000000A2  5C8F                   	addq.l  #6,sp                    ;
  158                                   
  159  000000A4  4267                   	clr.w   -(sp)                    ; Pterm()
  160  000000A6  4E41                   	trap    #1                       ; EXIT program
  161                                   
  162                                   ***************************************************************
  163                                   *                                                             *
  164                                   *                 Initialisations Routines                    *
  165                                   *                                                             *
  166                                   ***************************************************************
  167                                   Inits:
  168  000000A8  48E7FFFE               	movem.l	d0-d7/a0-a6,-(a7)


                                        Intro_46.S           Page 4       5:05:16 pm 9-May-2023        RMAC 2.2.07 (Win32)


  169                                   
  170                                   .if (FADE_INTRO = 0)
  171                                 - 	bsr	fadein                       ; Fading White to Black Screen
  172                                 - .endif
  173                                   
  174  000000AC  41F9xxxxxxxx           	lea	Default_palette,a0           ; Put Default palette
  175  000000B2  43F88240               	lea	$ffff8240.w,a1               ;
  176  000000B6  4CD000FF               	movem.l	(a0),d0-d7               ;
  177  000000BA  48D100FF               	movem.l	d0-d7,(a1)               ;
  178                                   
  179  000000BE  7001                   	moveq #1,d0                      ; Choice of the music (1 is default)
  180  000000C0  4EB9xxxxxxxx           	jsr	MUSIC+0                      ; Init SNDH music
  181                                   
  182  000000C6  41FAxxxx               	lea	Vbl(pc),a0                   ; Launch VBL
  183  000000CA  21C80070               	move.l	a0,$70.w                 ;
  184                                   
  185  000000CE  4CDF7FFF               	movem.l	(a7)+,d0-d7/a0-a6
  186  000000D2  4E75                   	rts
  187                                   
  188                                   ***************************************************************
  189                                   *                                                             *
  190                                   *                       Screen Routines                       *
  191                                   *                                                             *
  192                                   ***************************************************************
  193                                   ; Only Screen Size in Low Resolution
  194           =00007D00               .iif ( NO_BORDER = 0 & (BOTTOM_BORDER = 1 & TOPBOTTOM_BORDER = 1)), SIZE_OF_SCREEN equ 160*200
  195                                   ; Size of Screen + Lower Border Size
  196                                   .iif (BOTTOM_BORDER = 0 & (NO_BORDER = 1 & TOPBOTTOM_BORDER = 1)), SIZE_OF_SCREEN equ 160*250
  197                                   ; Size of Screen + Top & Lower Border Size
  198                                   .iif (TOPBOTTOM_BORDER = 0 & (NO_BORDER = 1 & BOTTOM_BORDER = 1)), SIZE_OF_SCREEN equ 160*300
  199                                   
  200                                   Init_screens:
  201  000000D4  48E7FFFE               	movem.l	d0-d7/a0-a6,-(a7)
  202                                   
  203  000000D8  203Cxxxxxxxx           	move.l #Screen+256,d0            ; Set physical Screen #1
  204  000000DE  4200                   	clr.b d0                         ;
  205  000000E0  23C0xxxxxxxx           	move.l d0,physique               ;
  206                                   
  207  000000E6  207Axxxx               	move.l	physique(pc),a0          ; Fill PATTERN in Screen #1
  208  000000EA  3E3C1F3F               	move.w  #(SIZE_OF_SCREEN)/4-1,d7 ;
  209  000000EE  20FC00010001           	move.l  #PATTERN,(a0)+           ;
  210  000000F4  51CFFFF8               	dbf	    d7,*-6                   ;
  211                                   
  212                                   .if (NB_OF_SCREEN = 1)
  213  000000F8  D0BC00007D00           	add.l #SIZE_OF_SCREEN,d0         ; Set logical Screen #2
  214  000000FE  4200                   	clr.b d0                         ;
  215  00000100  23C0xxxxxxxx           	move.l d0,physique+4             ;
  216                                   
  217  00000106  207Axxxx               	move.l	physique+4(pc),a0        ; Fill PATTERN in Screen #2
  218  0000010A  3E3C1F3F               	move.w  #(SIZE_OF_SCREEN)/4-1,d7 ;
  219  0000010E  20FC00010001           	move.l  #PATTERN,(a0)+           ;
  220  00000114  51CFFFF8               	dbf	    d7,*-6                   ;
  221                                   .endif
  222                                   
  223                                   .if (NB_OF_SCREEN < 1)               ; Test if one Screen need to display
  224                                 - 	move.l	physique(pc),d0          ; Put physical Screen


                                        Intro_46.S           Page 5       5:05:16 pm 9-May-2023        RMAC 2.2.07 (Win32)


  225                                 - 	move.b	d0,d1                    ;
  226                                 - 	lsr.w #8,d0                      ;
  227                                 - 	move.b	d0,$ffff8203.w           ;
  228                                 - 	swap d0                          ;
  229                                 - 	move.b	d0,$ffff8201.w           ;
  230                                 - 	move.b	d1,$ffff820d.w           ;
  231                                 - .endif
  232                                   
  233  00000118  4CDF7FFF               	movem.l	(a7)+,d0-d7/a0-a6
  234  0000011C  4E75                   	rts
  235                                   
  236                                   physique:
  237  0000011E  0000000000000000       	ds.l (NB_OF_SCREEN+1)            ; Number of screens declared
  238                                   
  239                                   ***************************************************************
  240                                   *                                                             *
  241                                   *                        Vbl Routines                         *
  242                                   *                                                             *
  243                                   ***************************************************************
  244                                   Vbl:
  245                                   .if (BLITTER = 0)
  246                                 - .sync_blitter:                       ; Sync Blitter with effect
  247                                 - 	bclr.b	#7,$ffff8a3c.w
  248                                 - 	nop
  249                                 - 	btst.b	#7,$ffff8a3c.w
  250                                 - 	bne.s	.sync_blitter
  251                                 - .endif
  252                                   
  253  00000126  50F9xxxxxxxx           	st	Vsync                        ; Synchronisation
  254                                   
  255  0000012C  48E7FFFE               	movem.l	d0-d7/a0-a6,-(a7)
  256                                   
  257                                   .if (BOTTOM_BORDER = 0)
  258                                 - 	clr.b   $fffffa1b.w              ; Disable timer B
  259                                 - 	lea	Over_rout(pc),a0             ; HBL
  260                                 - 	move.l	a0,$120.w                ; Timer B vector
  261                                 - 	move.b	#199,$fffffa21.w         ; At the position
  262                                 - 	move.b	#8,$fffffa1b.w           ; Launch HBL
  263                                 - .endif
  264                                   
  265                                   .if (TOPBOTTOM_BORDER = 0)
  266                                 - tacr = $FFFFFA19
  267                                 - tadr = $FFFFFA1F
  268                                 - 
  269                                 - 	move.l	a0,-(a7)
  270                                 - 	clr.b (tacr).w                   ; Stop timer A
  271                                 - 	lea	topbord(pc),a0               ; Launch HBL
  272                                 - 	move.l	a0,$134.w                ; Timer A vector
  273                                 - 	move.b	#99,(tadr).w             ; Countdown value for timer A
  274                                 - 	move.b	#4,(tacr).w              ; Delay mode, clock divided by 50
  275                                 - 	move.l	(a7)+,a0
  276                                 - .endif
  277                                   
  278                                   .if (NO_BORDER = 0)
  279                                   * // Declarations here ...
  280                                   .endif


                                        Intro_46.S           Page 6       5:05:16 pm 9-May-2023        RMAC 2.2.07 (Win32)


  281                                   
  282  00000130  4EB9xxxxxxxx           	jsr (MUSIC+8)                    ; Play SNDH music
  283                                   
  284  00000136  4CDF7FFF               	movem.l	(a7)+,d0-d7/a0-a6
  285                                   
  286                                   .if (BLITTER = 0)
  287                                 - 	bset.b	#7,$ffff8a3c.w           ; Launch Blitter
  288                                 - 	nop
  289                                 - .endif
  290  0000013A  4E73                   	rte
  291                                   
  292                                   Wait_vbl:
  293  0000013C  2F08                   	move.l	a0,-(a7)                 ; Test Synchronisation
  294  0000013E  41F9xxxxxxxx           	lea	Vsync,a0                     ;
  295  00000144  51D0                   	sf	(a0)                         ;
  296  00000146  4A10                   .loop:	tst.b	(a0)                 ;
  297  00000148  67FC                   	beq.s .loop                      ;
  298  0000014A  205F                   	move.l	(a7)+,a0                 ;
  299  0000014C  4E75                   	rts
  300                                   
  301                                   .if (NO_BORDER = 0)
  302                                   ***************************************************************
  303                                   *                                                             *
  304                                   *               < Here is the no border rout >                *
  305                                   *                                                             *
  306                                   ***************************************************************
  307                                   * // Declarations here ...
  308                                   .endif
  309                                   
  310                                   .if (BOTTOM_BORDER = 0)
  311                                 - ***************************************************************
  312                                 - *                                                             *
  313                                 - *             < Here is the lower border rout >               *
  314                                 - *                                                             *
  315                                 - ***************************************************************
  316                                 - Over_rout:
  317                                 - 	sf $fffffa21.w                   ; Stop Timer B
  318                                 - 	sf $fffffa1b.w                   ;
  319                                 - 	dcb.w 95,$4e71                   ; 95 nops - Wait line end
  320                                 - 	sf	$ffff820a.w                  ; Modif Frequency 60 Hz !
  321                                 - 	dcb.w 28,$4e71                   ; 28 nops - Wait line end
  322                                 - 	move.b #$2,$ffff820a.w           ; 50 Hz !
  323                                 - 	rte
  324                                 - .endif
  325                                   
  326                                   .if (TOPBOTTOM_BORDER = 0)
  327                                 - ***************************************************************
  328                                 - *                                                             *
  329                                 - *          < Here is the top and lower border rout >          *
  330                                 - *                                                             *
  331                                 - ***************************************************************
  332                                 - herz = $FFFF820A
  333                                 - iera = $FFFFFA07
  334                                 - ierb = $FFFFFA09
  335                                 - isra = $FFFFFA0F
  336                                 - imra = $FFFFFA13


                                        Intro_46.S           Page 7       5:05:16 pm 9-May-2023        RMAC 2.2.07 (Win32)


  337                                 - imrb = $FFFFFA15
  338                                 - 
  339                                 - topbord:
  340                                 - 	move.l	a0,-(a7)
  341                                 - 	move #$2100,SR
  342                                 - 	stop #$2100                      ; Sync with interrupt
  343                                 - 	clr.b (tacr).w                   ; Stop timer A
  344                                 - 	dcb.w 78,$4E71                   ; 78 nops
  345                                 - 	clr.b (herz).w                   ; 60 Hz
  346                                 - 	dcb.w 18,$4E71                   ; 18 nops
  347                                 - 	move.b #2,(herz).w               ; 50 Hz
  348                                 - 	lea	botbord(pc),a0
  349                                 - 	move.l a0,$134.w                 ; Timer A vector
  350                                 - 	move.b #178,(tadr).w             ; Countdown value for timer A
  351                                 - 	move.b #7,(tacr).w               ; Delay mode, clock divided by 200
  352                                 - 	move.l (a7)+,a0                  ;
  353                                 - 	bclr.b #5,(isra).w               ; Clear end of interrupt flag
  354                                 - my_hbl:
  355                                 - 	rte
  356                                 - 
  357                                 - botbord:
  358                                 - 	move #$2100,SR                   ;
  359                                 - 	stop #$2100                      ; sync with interrupt
  360                                 - 	clr.b (tacr).w                   ; stop timer A
  361                                 - 	dcb.w 78,$4E71                   ; 78 nops
  362                                 - 	clr.b (herz).w                   ; 60 Hz
  363                                 - 	dcb.w 18,$4E71                   ; 18 nops
  364                                 - 	move.b #2,(herz).w               ; 50 Hz
  365                                 - 	bclr.b #5,(isra).w               ;
  366                                 - 	rte
  367                                 - .endif
  368                                   
  369                                   ***************************************************************
  370                                   *                                                             *
  371                                   *                Save/Restore System Routines                 *
  372                                   *                                                             *
  373                                   ***************************************************************
  374                                   Save_and_init_st:
  375  0000014E  7013                   	moveq #$13,d0                    ; Pause keyboard
  376  00000150  6100xxxx               	bsr	sendToKeyboard               ;
  377                                   
  378  00000154  46FC2700               	move #$2700,SR                   ; Interrupts OFF
  379                                   		
  380  00000158  41F9xxxxxxxx           	lea	Save_all,a0                  ; Save adresses parameters
  381  0000015E  10F8FA01               	move.b $fffffa01.w,(a0)+         ; Datareg
  382  00000162  10F8FA03               	move.b $fffffa03.w,(a0)+         ; Active edge
  383  00000166  10F8FA05               	move.b $fffffa05.w,(a0)+         ; Data direction
  384  0000016A  10F8FA07               	move.b $fffffa07.w,(a0)+         ; Interrupt enable A
  385  0000016E  10F8FA13               	move.b $fffffa13.w,(a0)+         ; Interupt Mask A
  386  00000172  10F8FA09               	move.b $fffffa09.w,(a0)+         ; Interrupt enable B
  387  00000176  10F8FA15               	move.b $fffffa15.w,(a0)+         ; Interrupt mask B
  388  0000017A  10F8FA17               	move.b $fffffa17.w,(a0)+         ; Automatic/software end of Interupt
  389  0000017E  10F8FA19               	move.b $fffffa19.w,(a0)+         ; Timer A control
  390  00000182  10F8FA1B               	move.b $fffffa1b.w,(a0)+         ; Timer B control
  391  00000186  10F8FA1D               	move.b $fffffa1d.w,(a0)+         ; Timer C & D control
  392  0000018A  10F8FA27               	move.b $fffffa27.w,(a0)+         ; Sync character


                                        Intro_46.S           Page 8       5:05:16 pm 9-May-2023        RMAC 2.2.07 (Win32)


  393  0000018E  10F8FA29               	move.b $fffffa29.w,(a0)+         ; USART control
  394  00000192  10F8FA2B               	move.b $fffffa2b.w,(a0)+         ; Receiver status
  395  00000196  10F8FA2D               	move.b $fffffa2d.w,(a0)+         ; Transmitter status
  396  0000019A  10F8FA2F               	move.b $fffffa2f.w,(a0)+         ; USART data
  397                                             
  398  0000019E  10F88201               	move.b $ffff8201.w,(a0)+         ; Save Video addresses
  399  000001A2  10F88203               	move.b $ffff8203.w,(a0)+         ;
  400  000001A6  10F8820A               	move.b $ffff820a.w,(a0)+         ;
  401  000001AA  10F8820D               	move.b $ffff820d.w,(a0)+         ;
  402                                   	
  403  000001AE  41F9xxxxxxxx           	lea	Save_rest,a0                 ; Save adresses parameters
  404  000001B4  20F80068               	move.l $068.w,(a0)+              ; HBL
  405  000001B8  20F80070               	move.l $070.w,(a0)+              ; VBL
  406  000001BC  20F80110               	move.l $110.w,(a0)+              ; TIMER D
  407  000001C0  20F80114               	move.l $114.w,(a0)+              ; TIMER C
  408  000001C4  20F80118               	move.l $118.w,(a0)+              ; ACIA
  409  000001C8  20F80120               	move.l $120.w,(a0)+              ; TIMER B
  410  000001CC  20F80134               	move.l $134.w,(a0)+              ; TIMER A
  411  000001D0  20F80484               	move.l $484.w,(a0)+              ; Conterm
  412                                   
  413  000001D4  4CF800FF8240           	movem.l	$ffff8240.w,d0-d7        ; Save palette GEM system
  414  000001DA  48D000FF               	movem.l	d0-d7,(a0)
  415                                   
  416                                   .if (ERROR_SYS =0)
  417                                 - 	bsr	INPUT_TRACE_ERROR            ; Save vectors list
  418                                 - .endif
  419                                   
  420                                   
  421                                   ; Available interrupt commands for music if needed...
  422                                   .if (^^referenced DEBUGTIMER)
  423                                 - 	clr.b $fffffa07.w                ; Interrupt enable A (Timer-A & B)
  424                                 - 	clr.b $fffffa09.w                ; Interrupt enable B (Timer-C & D)
  425                                 - 	clr.b $fffffa13.w                ; Interrupt mask A (Timer-A & B)
  426                                 - 	clr.b $fffffa15.w                ; Interrupt mask B (Timer-C & D)
  427                                 - 	clr.b $fffffa19.w                ; Stop Timer A
  428                                 - 	clr.b $fffffa1b.w                ; Stop Timer B
  429                                 - 	clr.b $fffffa21.w                ; Timer B data at zero
  430                                 - 	clr.b $fffffa1d.w                ; Stop Timer C & D
  431                                 - .endif
  432                                   
  433                                   .if (BOTTOM_BORDER = 0)
  434                                 - 	sf $fffffa21.w                   ; Timer B data (number of scanlines to next interrupt)
  435                                 - 	sf $fffffa1b.w                   ; Timer B control (event mode (HBL))
  436                                 - 	lea	Over_rout(pc),a0             ; Launch HBL
  437                                 - 	move.l a0,$120.w                 ;
  438                                 - 	bset #0,$fffffa07.w              ; Timer B vector
  439                                 - 	bset #0,$fffffa13.w              ; Timer B on
  440                                 - 	bclr #3,$fffffa17.w              ; Automatic End-Interrupt hbl ON
  441                                 - .endif
  442                                   
  443                                   .if (TOPBOTTOM_BORDER = 0)
  444                                 - 	move.b #%00100000,(iera).w       ; Enable Timer A
  445                                 - 	move.b #%00100000,(imra).w       ;
  446                                 - 	and.b #%00010000,(ierb).w        ; Disable all except Timer D
  447                                 - 	and.b #%00010000,(imrb).w        ;
  448                                 - 	or.b #%01000000,(ierb).w         ; Enable keyboard


                                        Intro_46.S           Page 9       5:05:16 pm 9-May-2023        RMAC 2.2.07 (Win32)


  449                                 - 	or.b #%01000000,(imrb).w         ;
  450                                 - 	clr.b (tacr).w                   ; Timer A off
  451                                 - 	lea	my_hbl(pc),a0                ;
  452                                 - 	move.l	a0,$68.w                 ; Horizontal blank
  453                                 - 	lea	topbord(pc),a0               ;
  454                                 - 	move.l a0,$134.w                 ; Timer A vector
  455                                 - 	bclr #3,$fffffa17.w              ; Automatic End-Interrupt hbl ON
  456                                 - .endif
  457                                   
  458                                   .if (NO_BORDER = 0)
  459                                   * // Code here....
  460                                   .endif
  461                                   
  462  000001DE  4E722300               	stop #$2300                      ; Interrupts ON
  463                                   
  464  000001E2  42380484               	clr.b $484.w                     ; No bip, no repeat
  465                                   
  466  000001E6  3F3C0004               	move #4,-(sp)                    ; Save & Change Resolution (GetRez)
  467  000001EA  4E4E                   	trap #14	                       ; Get Current Res.
  468  000001EC  548F                   	addq.l #2,sp                     ;
  469  000001EE  33C0xxxxxxxx           	move d0,Old_Resol+2              ; Save it
  470                                   
  471  000001F4  3F3C0003               	move #3,-(sp)                    ; Save Screen Address (Logical)
  472  000001F8  4E4E                   	trap #14                         ;
  473  000001FA  548F                   	addq.l #2,sp                     ;
  474  000001FC  23C0xxxxxxxx           	move.l d0,Old_Screen+2           ;
  475                                   
  476  00000202  7011                   	moveq #$11,d0                    ; Resume keyboard
  477  00000204  6100xxxx               	bsr	sendToKeyboard               ;
  478                                   
  479  00000208  7012                   	moveq #$12,d0                    ; Kill mouse
  480  0000020A  6100xxxx               	bsr	sendToKeyboard               ;
  481                                   
  482  0000020E  6100xxxx               	bsr	flush                        ; Clear buffer keyboard
  483                                   
  484                                   ; If you don't use Multi_boot option...
  485  00000212  51F88260               	sf	$ffff8260.w                  ; Low resolution
  486  00000216  11FC0002820A           	move.b	#$2,$ffff820a.w          ; 50 Hz !
  487  0000021C  4E75                   	rts
  488                                   
  489                                   Restore_st:
  490  0000021E  7013                   	moveq #$13,d0                    ; Pause keyboard
  491  00000220  6100xxxx               	bsr	sendToKeyboard               ;
  492                                   
  493  00000224  46FC2700               	move #$2700,SR                   ; Interrupts OFF
  494                                   
  495  00000228  4EB9xxxxxxxx           	jsr	MUSIC+4                      ; Stop SNDH music
  496                                   
  497  0000022E  41F88800               	lea $ffff8800.w,a0               ; Cut sound
  498  00000232  20BC08000000           	move.l #$8000000,(a0)            ; Voice A
  499  00000238  20BC09000000           	move.l #$9000000,(a0)            ; Voice B
  500  0000023E  20BC0A000000           	move.l #$a000000,(a0)            ; Voice C
  501                                   
  502                                   .if (ERROR_SYS = 0)
  503                                 - 	bsr	OUTPUT_TRACE_ERROR           ; Restore vectors list
  504                                 - .endif


                                        Intro_46.S           Page 10      5:05:16 pm 9-May-2023        RMAC 2.2.07 (Win32)


  505                                   
  506  00000244  41F9xxxxxxxx           	lea	Save_all,a0                  ; Restore adresses parameters
  507  0000024A  11D8FA01               	move.b (a0)+,$fffffa01.w         ; Datareg
  508  0000024E  11D8FA03               	move.b (a0)+,$fffffa03.w         ; Active edge
  509  00000252  11D8FA05               	move.b (a0)+,$fffffa05.w         ; Data direction
  510  00000256  11D8FA07               	move.b (a0)+,$fffffa07.w         ; Interrupt enable A
  511  0000025A  11D8FA13               	move.b (a0)+,$fffffa13.w         ; Interupt Mask A
  512  0000025E  11D8FA09               	move.b (a0)+,$fffffa09.w         ; Interrupt enable B
  513  00000262  11D8FA15               	move.b (a0)+,$fffffa15.w         ; Interrupt mask B
  514  00000266  11D8FA17               	move.b (a0)+,$fffffa17.w         ; Automatic/software end of interupt
  515  0000026A  11D8FA19               	move.b (a0)+,$fffffa19.w         ; Timer A control
  516  0000026E  11D8FA1B               	move.b (a0)+,$fffffa1b.w         ; Timer B control
  517  00000272  11D8FA1D               	move.b (a0)+,$fffffa1d.w         ; Timer C & D control
  518  00000276  11D8FA27               	move.b (a0)+,$fffffa27.w         ; Sync character
  519  0000027A  11D8FA29               	move.b (a0)+,$fffffa29.w         ; USART control
  520  0000027E  11D8FA2B               	move.b (a0)+,$fffffa2b.w         ; Receiver status
  521  00000282  11D8FA2D               	move.b (a0)+,$fffffa2d.w         ; Transmitter status
  522  00000286  11D8FA2F               	move.b (a0)+,$fffffa2f.w         ; USART data
  523                                   	                                 
  524  0000028A  11D88201               	move.b (a0)+,$ffff8201.w         ; Restore Video addresses
  525  0000028E  11D88203               	move.b (a0)+,$ffff8203.w         ;
  526  00000292  11D8820A               	move.b (a0)+,$ffff820a.w         ;
  527  00000296  11D8820D               	move.b (a0)+,$ffff820d.w         ;
  528                                   	
  529  0000029A  41F9xxxxxxxx           	lea	Save_rest,a0                 ; Restore adresses parameters
  530  000002A0  21D80068               	move.l (a0)+,$068.w              ; HBL
  531  000002A4  21D80070               	move.l (a0)+,$070.w              ; VBL
  532  000002A8  21D80110               	move.l (a0)+,$110.w              ; TIMER D
  533  000002AC  21D80114               	move.l (a0)+,$114.w              ; TIMER C
  534  000002B0  21D80118               	move.l (a0)+,$118.w              ; ACIA
  535  000002B4  21D80120               	move.l (a0)+,$120.w              ; TIMER B
  536  000002B8  21D80134               	move.l (a0)+,$134.w              ; TIMER A
  537  000002BC  21D80484               	move.l (a0)+,$484.w              ; Conterm
  538                                   
  539  000002C0  4CD000FF               	movem.l	(a0),d0-d7               ; Restore palette GEM system
  540  000002C4  48F800FF8240           	movem.l	d0-d7,$ffff8240.w        ;
  541                                   
  542  000002CA  08F80003FA17           	bset.b #3,$fffffa17.w            ; Re-activate Timer C
  543                                   
  544  000002D0  4E722300               	stop #$2300                      ; Interrupts ON
  545                                   
  546  000002D4  7011                   	moveq #$11,d0                    ; Resume keyboard
  547  000002D6  61xx                   	bsr.s sendToKeyboard             ;
  548                                   
  549  000002D8  7008                   	moveq #$8,d0                     ; Restore mouse
  550  000002DA  61xx                   	bsr.s sendToKeyboard             ;
  551                                   
  552  000002DC  61xx                   	bsr.s flush                      ; Clear buffer keyboard
  553                                   
  554                                   Old_Resol:                           ; Restore Old Screen & Resolution
  555  000002DE  3F3C0000               	move	#0,-(sp)                 ;
  556                                   Old_Screen:                          ;
  557  000002E2  2F3C00000000           	move.l #0,-(sp)                  ;
  558  000002E8  2F17                   	move.l (sp),-(sp)                ;
  559  000002EA  3F3C0005               	move #5,-(sp)                    ;
  560  000002EE  4E4E                   	trap #14                         ;


                                        Intro_46.S           Page 11      5:05:16 pm 9-May-2023        RMAC 2.2.07 (Win32)


  561  000002F0  4FEF000C               	lea	12(sp),sp                    ;
  562                                   
  563  000002F4  3F3C0025               	move.w #$25,-(a7)                ; VSYNC()
  564  000002F8  4E4E                   	trap #14                         ;
  565  000002FA  544F                   	addq.w #2,a7                     ;
  566  000002FC  4E75                   	rts
  567                                   
  568                                   sendToKeyboard:                    ; Keyboard access
  569                                   .wait:
  570  000002FE  08380001FC00           	btst	#1,$fffffc00.w
  571  00000304  67F8                   	beq.s	.wait
  572  00000306  11C0FC02               	move.b	d0,$FFFFFC02.w
  573  0000030A  4E75                   	rts
  574                                   
  575                                   flush:                             ; Empty buffer
  576  0000030C  41F8FC00               	lea	$FFFFFC00.w,a0
  577                                   .flush:
  578  00000310  10280002               	move.b	2(a0),d0
  579  00000314  08100000               	btst	#0,(a0)
  580  00000318  66F6                   	bne.s	.flush
  581  0000031A  4E75                   	rts
  582                                   
  583                                   ***************************************************************
  584                                   ; SUB-ROUTINES                                             // *
  585                                   ***************************************************************
  586                                   
  587                                   
  588                                   
  589                                   ***************************************************************
  590  0000031C                         	DATA                                                   // *
  591                                   ***************************************************************
  592                                   
  593                                   Default_palette:
  594  00000000  00000777011102220333   	dc.w	$000,$777,$111,$222,$333,$444,$555,$666
       0000000A  044405550666           
  595  00000010  07770111022203330444   	dc.w	$777,$111,$222,$333,$444,$555,$666,$777
       0000001A  055506660777           
  596                                   
  597                                   * << Full data here >>
  598                                   
  599                                   
  600                                   * <
  601                                   
  602                                   MUSIC:
  603  00000020  60000064600000906000   	incbin "include\\JEDIFUN.SND"            ; SNDH Music played at the VBL
       0000002A  00AA534E44485449544C   
       00000034  4A6564692046756E0043   
       0000003E  4F4D4D4A656469005249   
       00000048  50504772617A6579202F   
       00000052  2050484600434F4E5647   
       0000005C  72617A6579202F205048   
       00000066  46005945415200232330   
       00000070  31002123303100544335   
       0000007A  300054494D4500004844   
       00000084  4E5341FA019A43FA0FF8   
       0000008E  203C0000039622D851C8   


                                        Intro_46.S           Page 12      5:05:16 pm 9-May-2023        RMAC 2.2.07 (Win32)


       00000098  FFFC43FA0FE8203A0FE0   
       000000A2  33400204334004BC3340   
       000000AC  077270014EBA0FD24E75   
       000000B6  41F8880020BC0707FFFF   
       000000C0  20BC0808000020BC0909   
       000000CA  000020BC0A0A00004E75   
       000000D4  61000FB64E7500002F08   
       000000DE  40E746FC270041FA00EC   
       000000E8  11D8FA0111D8FA0311D8   
       000000F2  FA0511D8FA0711D8FA09   
       000000FC  11D8FA0B11D8FA0D11D8   
       00000106  FA0F11D8FA1111D8FA13   
       00000110  11D8FA1511D8FA1711D8   
       0000011A  FA1911D8FA1B11D8FA1D   
       00000124  11D8FA1F11D8FA2111D8   
       0000012E  FA2311D8FA25D1FC0000   
       00000138  000121D8009421D80110   
       00000142  21D8011421D8012021D8   
       0000014C  013446DF205F11FC00C0   
       00000156  FA234E752F0840E746FC   
       00000160  270041FA006E10F8FA01   
       0000016A  10F8FA0310F8FA0510F8   
       00000174  FA0710F8FA0910F8FA0B   
       0000017E  10F8FA0D10F8FA0F10F8   
       00000188  FA1110F8FA1310F8FA15   
       00000192  10F8FA1710F8FA1910F8   
       0000019C  FA1B10F8FA1D10F8FA1F   
       000001A6  10F8FA2110F8FA2310F8   
       000001B0  FA25D1FC0000000120F8   
       000001BA  009420F8011020F80114   
       000001C4  20F8012020F8013446DF   
       000001CE  205F4E75000000000000   
       000001D8  00000000000000000000   
       000001E2  00000000000000000000   
       000001EC  00000000000000000000   
       000001F6  00000000000000000000   
       00000200  00000000000000000000   
       0000020A  00000000000000000000   
       00000214  00000000000000000000   
       0000021E  000000006000000A6000   
       00000228  00D26000012848E7FFFE   
       00000232  610000C641FA0C7443FA   
       0000023C  0C3045D12658B7FCFFFF   
       00000246  FFFF672649F2B8002659   
       00000250  4BF2B800288D60E80C18   
       0000025A  00FF66FA0C10005466F4   
       00000264  52880C10004866EC5288   
       0000026E  4E7541FA0E0A4DFA0C76   
       00000278  2CC861DC0C10003F670C   
       00000282  0C10004B66F252882CC8   
       0000028C  60EC52884DFA043E2D48   
       00000296  FD4861BE0C10004B66F8   
       000002A0  52882C8861B20C10004B   
       000002AA  66F852882D4802B611FC   
       000002B4  000D880011FC000A8802   
       000002BE  41FA099043FA0B6E20C9   


                                        Intro_46.S           Page 13      5:05:16 pm 9-May-2023        RMAC 2.2.07 (Win32)


       000002C8  20C92089207A014A227A   
       000002D2  0C1A247A03FA47D1287A   
       000002DC  06AA4BD3700072007400   
       000002E6  760078007A007C007E00   
       000002F0  08B800000484600008E4   
       000002FA  485041F88800429020BC   
       00000304  0101000020BC02020000   
       0000030E  20BC0303000020BC0404   
       00000318  000020BC0505000020BC   
       00000322  0606000020BC0707FFFF   
       0000032C  20BC0808000020BC0909   
       00000336  000020BC0A0A000020BC   
       00000340  0B0B000020BC0C0C0000   
       0000034A  20BC0D0D0000205F4E75   
       00000354  48E7FFFE4CFA3FFF089C   
       0000035E  4DFA08E051D64A406600   
       00000368  00C072004DFA08D53D7C   
       00000372  FFFF0205426E000351D6   
       0000037C  1218227A08B40C0100FB   
       00000386  650000982C3C000000FF   
       00000390  9C01E54E2E3B68064EFB   
       0000039A  78160000006600000050   
       000003A4  000000420000002C0000   
       000003AE  00007E001C181E181210   
       000003B8  4DFA08921C87BE016502   
       000003C2  44064DFA087D1C864DFA   
       000003CC  08B6DE473E3670004DFA   
       000003D6  0A723C8760A04DFA0964   
       000003E0  72001218E9414DF61000   
       000003EA  23CE0000A290608A1218   
       000003F4  44014DFA084B1C816000   
       000003FE  FF7E4DFA0AEA1218D241   
       00000408  D24123F610000000A274   
       00000412  6000FF5641F90000AE2B   
       0000041C  6000FF4C70001018C0FC   
       00000426  000653400C1100FF6700   
       00000430  01D24DFA07B61E190C07   
       0000043A  00F56500013A2C3C0000   
       00000444  00FE9C07E54E2E3B6806   
       0000044E  4EFB782A000000000000   
       00000458  000E0000001C0000002C   
       00000462  00000032000000400000   
       0000046C  006400000092000000C0   
       00000476  0000002408EE00030007   
       00000480  08AE0000000760AE08EE   
       0000048A  0000000708AE00030007   
       00000494  60A0022E00F600076098   
       0000049E  002E0009000760901D59   
       000004A8  0006608A7E001E11227A   
       000004B2  0782D3C76000FF7E50F9   
       000004BC  0000A2801D59000B51EE   
       000004C6  000C1E19E14F1E19E15F   
       000004D0  33C70000A48251EE0008   
       000004DA  6000013A4DFA096250EE   
       000004E4  FDFE1D5900011C994DFA   
       000004EE  07943E01DE19DE473E36   


                                        Intro_46.S           Page 14      5:05:16 pm 9-May-2023        RMAC 2.2.07 (Win32)


       000004F8  70004DFA06F951EEFFFD   
       00000502  1CC7E04F1C876000010C   
       0000050C  4DFA06E751EEFFFD50EE   
       00000516  004B1D5900011C993E01   
       00000520  DE19DE474DFA075C3E36   
       0000052A  70004DFA09141CC7E04F   
       00000534  1C87600000DE4DFA0746   
       0000053E  50EEFFBE51EEFF707E00   
       00000548  3E01DE19DE473E367000   
       00000552  4DFA08EE3C071C86E04E   
       0000055C  1D4600017C001C19ECBF   
       00000566  640252471D47FDB3E04F   
       00000570  1D47FDB4600000A02C7A   
       0000057A  06D6488713F670000000   
       00000584  A2321E1948873F014DFA   
       0000058E  06F4D24132361000D247   
       00000598  1E3A06A948874DFA06A6   
       000005A2  DF56D2563C3A08A00C46   
       000005AC  FFFF671E4A476B14B246   
       000005B6  651632061F7A06900001   
       000005C0  425651EEFFFD6006B246   
       000005CA  640260EA32174DFA06B0   
       000005D4  D219D241323610001E29   
       000005DE  FFFE4887D2471E3A065D   
       000005E8  48874DFA065ADF56D256   
       000005F2  4DFA05F61C81E0491D41   
       000005FC  0001321F60144DFA05E6   
       00000606  3216E1591E3A06374887   
       00000610  D2473F0160E04DFA062A   
       0000061A  51D64A42660000C04DFA   
       00000624  06203D7CFFFF0206426E   
       0000062E  000451D67600161A267A   
       00000638  06040C0300FB65000098   
       00000642  2C3C000000FF9C03E54E   
       0000064C  2E3B68064EFB78160000   
       00000656  00660000005000000042   
       00000660  0000002C000000007E00   
       0000066A  1C1A1E1A16124DFA05DB   
       00000674  1C87BE03650244064DFA   
       0000067E  05C61C864DFA05FEDE47   
       00000688  3E3670004DFA07BC3C87   
       00000692  609E4DFA06AC7600161A   
       0000069C  E9434DF6300023CE0000   
       000006A6  A2946088161A44034DFA   
       000006B0  05941C836000FF7C4DFA   
       000006BA  0832161AD643D64323F6   
       000006C4  30000000A27C6000FF56   
       000006CE  45F90000AEDF6000FF4C   
       000006D8  7400141AC4FC00065342   
       000006E2  0C1300FF670001D04DFA   
       000006EC  05071E1B0C0700F56500   
       000006F6  01382C3C000000FE9C07   
       00000700  E54E2E3B68064EFB782A   
       0000070A  000000000000000E0000   
       00000714  001C0000002C00000032   
       0000071E  00000040000000620000   


                                        Intro_46.S           Page 15      5:05:16 pm 9-May-2023        RMAC 2.2.07 (Win32)


       00000728  0090000000BE00000024   
       00000732  08EE0004FFFE08AE0001   
       0000073C  FFFE60AE08EE0001FFFE   
       00000746  08AE0004FFFE60A0022E   
       00000750  00EDFFFE6098002E0012   
       0000075A  FFFE60901D5BFFFD608A   
       00000764  7E001E13267A04D2D7C7   
       0000076E  6000FF7E50F90000A282   
       00000778  1D5B000251EE00031E1B   
       00000782  E14F1E1BE15F33C70000   
       0000078C  A48451D66000013A4DFA   
       00000796  06AE50EEFDFE1D5B0001   
       000007A0  1C9B4DFA04DE3E03DE1B   
       000007AA  DE473E3670004DFA0443   
       000007B4  51EEFFFE1CC7E04F1C87   
       000007BE  6000010C4DFA043151EE   
       000007C8  FFFE50EE004D1D5B0001   
       000007D2  1C9B3E03DE1BDE474DFA   
       000007DC  04A63E3670004DFA0660   
       000007E6  1CC7E04F1C87600000DE   
       000007F0  4DFA049050EEFFC051EE   
       000007FA  FF717E003E03DE1BDE47   
       00000804  3E3670004DFA063A3C07   
       0000080E  1C86E04E1D4600017C00   
       00000818  1C1BECBF640252471D47   
       00000822  FDB1E04F1D47FDB26000   
       0000082C  00A02C7A0424488713F6   
       00000836  70000000A2331E1B4887   
       00000840  3F034DFA043ED6433636   
       0000084A  3000D6471E3A03F44887   
       00000854  4DFA03F2DF56D6563C3A   
       0000085E  05EC0C46FFFF671E4A47   
       00000868  6B14B646651636061F7A   
       00000872  03DB0001425651EEFFFC   
       0000087C  6006B646640260EA3617   
       00000886  4DFA03FAD61BD6433636   
       00000890  30001E2BFFFE4887D647   
       0000089A  1E3A03A848874DFA03A6   
       000008A4  DF56D6564DFA03421C83   
       000008AE  E04B1D430001361F6014   
       000008B8  4DFA03323616E15B1E3A   
       000008C2  03824887D6473F0360E0   
       000008CC  4DFA037351D64A446600   
       000008D6  00C04DFA036B3D7CFFFF   
       000008E0  0207426E000551D67A00   
       000008EA  1A1C2A7A034A0C0500FB   
       000008F4  650000982C3C000000FF   
       000008FE  9C05E54E2E3B68064EFB   
       00000908  78160000006600000050   
       00000912  000000420000002C0000   
       0000091C  00007E001C1C1E1C1A14   
       00000926  4DFA03261C87BE056502   
       00000930  44064DFA03111C864DFA   
       0000093A  0348DE473E3670004DFA   
       00000944  05083C87609E4DFA03F6   
       0000094E  7A001A1CE9454DF65000   


                                        Intro_46.S           Page 16      5:05:16 pm 9-May-2023        RMAC 2.2.07 (Win32)


       00000958  23CE0000A29860881A1C   
       00000962  44054DFA02DF1C856000   
       0000096C  FF7C4DFA057C1A1CDA45   
       00000976  DA4523F650000000A278   
       00000980  6000FF5649F90000AF91   
       0000098A  6000FF4C7800181CC8FC   
       00000994  000653440C1500FF6700   
       0000099E  01D04DFA02521E1D0C07   
       000009A8  00F5650001382C3C0000   
       000009B2  00FE9C07E54E2E3B6806   
       000009BC  4EFB782A000000000000   
       000009C6  000E0000001C0000002C   
       000009D0  00000032000000400000   
       000009DA  006200000090000000BE   
       000009E4  0000002408EE0005FFFD   
       000009EE  08AE0002FFFD60AE08EE   
       000009F8  0002FFFD08AE0005FFFD   
       00000A02  60A0022E00DBFFFD6098   
       00000A0C  002E0024FFFD60901D5D   
       00000A16  FFFC608A7E001E152A7A   
       00000A20  0218DBC76000FF7E50F9   
       00000A2A  0000A2811D5D000151EE   
       00000A34  00021E1DE14F1E1DE15F   
       00000A3E  33C70000A48651D66000   
       00000A48  013A4DFA03FA50EEFDFB   
       00000A52  1D5D00011C9D4DFA0228   
       00000A5C  3E05DE1DDE473E367000   
       00000A66  4DFA018D51EEFFFF1CC7   
       00000A70  E04F1C876000010C4DFA   
       00000A7A  017B51EEFFFF50EE004C   
       00000A84  1D5D00011C9D3E05DE1D   
       00000A8E  DE474DFA01F03E367000   
       00000A98  4DFA03AC1CC7E04F1C87   
       00000AA2  600000DE4DFA01DA50EE   
       00000AAC  FFBF51EEFF727E003E05   
       00000AB6  DE1DDE473E3670004DFA   
       00000AC0  03863C071C86E04E1D46   
       00000ACA  00017C001C1DECBF6402   
       00000AD4  52471D47FDAFE04F1D47   
       00000ADE  FDB0600000A02C7A0172   
       00000AE8  488713F670000000A234   
       00000AF2  1E1D48873F054DFA0188   
       00000AFC  DA453A365000DA471E3A   
       00000B06  013F48874DFA013EDF56   
       00000B10  DA563C3A03380C46FFFF   
       00000B1A  671E4A476B14BA466516   
       00000B24  3A061F7A012600014256   
       00000B2E  51EEFFFB6006BA466402   
       00000B38  60EA3A174DFA0144DA1D   
       00000B42  DA453A3650001E2DFFFE   
       00000B4C  4887DA471E3A00F34887   
       00000B56  4DFA00F2DF56DA564DFA   
       00000B60  008E1C85E04D1D450001   
       00000B6A  3A1F60144DFA007E3A16   
       00000B74  E15D1E3A00CD4887DA47   
       00000B7E  3F0560E04DFA006E0896   


                                        Intro_46.S           Page 17      5:05:16 pm 9-May-2023        RMAC 2.2.07 (Win32)


       00000B88  00044A2E004E670A3D7A   
       00000B92  02B0FFF808D6000408AE   
       00000B9C  000400014A2E0050670C   
       00000BA6  3D7A029CFFFA08EE0004   
       00000BB0  000108AE000400024A2E   
       00000BBA  004F670C3D7A0286FFFC   
       00000BC4  08EE000400027E0C4DFA   
       00000BCE  002911C7880011E68802   
       00000BD8  51CFFFF64DFA001A48D6   
       00000BE2  3FFF4CDF7FFF4E759401   
       00000BEC  9201450600F80E0E0E00   
       00000BF6  00000000001800000027   
       00000C00  00000018000000270000   
       00000C0A  00000000000F0000FFFF   
       00000C14  0000FFFF0000AE410000   
       00000C1E  A76E0000AEF50000A70D   
       00000C28  0000B0510000A8180000   
       00000C32  00000000A7250000A805   
       00000C3C  0000A6C4000000000000   
       00000C46  0000000000004D757A61   
       00000C50  0000A4720000A4720000   
       00000C5A  A4726500627900536563   
       00000C64  746F72004F6E65006672   
       00000C6E  6F6D0054686500486561   
       00000C78  7679004B696C6C657273   
       00000C82  0EEE0E180D4D0C8E0BDA   
       00000C8C  0B2F0A8F09F7096808E1   
       00000C96  086107E90777070C06A7   
       00000CA0  064705ED0598054704FC   
       00000CAA  04B40470043103F403BC   
       00000CB4  03860353032402F602CC   
       00000CBE  02A4027E025A02380218   
       00000CC8  01FA01DE01C301AA0192   
       00000CD2  017B01660152013F012D   
       00000CDC  011C010C00FD00EF00E1   
       00000CE6  00D500C900BE00B300A9   
       00000CF0  009F0096008E0086007F   
       00000CFA  00770071006A0064005F   
       00000D04  005900540050004B0047   
       00000D0E  0043003F003C00380035   
       00000D18  0032002F002D002A0028   
       00000D22  0026002400220020001E   
       00000D2C  001C001B001900180016   
       00000D36  00150014001300120011   
       00000D40  00100000000000000000   
       00000D4A  00000000000000000000   
       00000D54  00000000000001010101   
       00000D5E  01010101000000000101   
       00000D68  01010101010102020202   
       00000D72  00000001010101010202   
       00000D7C  02020203030300000101   
       00000D86  01010202020203030303   
       00000D90  04040000010101020202   
       00000D9A  03030304040405050000   
       00000DA4  01010202020303040404   
       00000DAE  05050606000001010202   


                                        Intro_46.S           Page 18      5:05:16 pm 9-May-2023        RMAC 2.2.07 (Win32)


       00000DB8  03030404050506060707   
       00000DC2  00010102020303040405   
       00000DCC  05060607070800010102   
       00000DD6  02030404050506070708   
       00000DE0  08090001010203030405   
       00000DEA  050607070809090A0001   
       00000DF4  01020304040506070708   
       00000DFE  090A0A0B000102020304   
       00000E08  0506060708090A0A0B0C   
       00000E12  00010203030405060708   
       00000E1C  090A0A0B0C0D00010203   
       00000E26  040506070708090A0B0C   
       00000E30  0D0E0001020304050607   
       00000E3A  08090A0B0C0D0E0F4661   
       00000E44  6E6F7500FFFFFFFFFFFF   
       00000E4E  0079610021002D004A65   
       00000E58  6469002D00666F72006D   
       00000E62  7900626162792E2E2E00   
       00000E6C  FFFFFDE4FFFFFDC8FFFF   
       00000E76  FDD4FFFFFFD6FFFFFD86   
       00000E80  FFFFFDD0FFFFFDD6FFFF   
       00000E8A  FFD8FFFFFD87FFFFFDCC   
       00000E94  FFFFFDD5FFFFFFDAFFFF   
       00000E9E  FD88FFFFFDE8FFFFFDEC   
       00000EA8  FFFFFFFFFFFFF580FFFF   
       00000EB2  F5A2FFFFF650FFFFF666   
       00000EBC  FFFFF716FFFFF85AFFFF   
       00000EC6  F908FFFFF91EFFFFF9CC   
       00000ED0  FFFFFB10FFFFFBBEFFFF   
       00000EDA  FBD4FFFFFC82FFFFF838   
       00000EE4  FFFFFAEEFFFFFFFF0000   
       00000EEE  A6BC0000A6C40000A725   
       00000EF8  0000A8050000A84C0000   
       00000F02  AAD40000AC590000AC86   
       00000F0C  0000ACD70000ACF20000   
       00000F16  00000000000000000000   
       00000F20  00000000000000000000   
       00000F2A  00000000000000000000   
       00000F34  00000000000000000000   
       00000F3E  00000000000000000000   
       00000F48  00000000000000000000   
       00000F52  00000000000000000000   
       00000F5C  00000000000000000000   
       00000F66  00000000000000000000   
       00000F70  00000000000000000000   
       00000F7A  00000000000000000000   
       00000F84  00000000000000000000   
       00000F8E  00000000000000000000   
       00000F98  00000000000000000000   
       00000FA2  00000000000000000000   
       00000FAC  00000000000000000000   
       00000FB6  00000000000000000000   
       00000FC0  00000000000000000000   
       00000FCA  00000000000000000000   
       00000FD4  00000000000000000000   
       00000FDE  00000000000000000000   


                                        Intro_46.S           Page 19      5:05:16 pm 9-May-2023        RMAC 2.2.07 (Win32)


       00000FE8  00000000000000000000   
       00000FF2  00000000000000000000   
       00000FFC  00000000000000000000   
       00001006  00000000000000000000   
       00001010  00000000000000000000   
       0000101A  00000000000000000000   
       00001024  00000000000000000000   
       0000102E  00000000000000000000   
       00001038  00000000000000000000   
       00001042  00000000000000000000   
       0000104C  00000000000000000000   
       00001056  00000000000000000000   
       00001060  00000000000000000000   
       0000106A  00000000000000000000   
       00001074  0000000000000000F500   
       0000107E  00000000000600000000   
       00001088  00000000000000000000   
       00001092  00000000000000000000   
       0000109C  00000000000000000000   
       000010A6  00000000000000000000   
       000010B0  00000000000000000000   
       000010BA  00000000000000000000   
       000010C4  00000000000000000000   
       000010CE  00000000000000000000   
       000010D8  00000000000000000000   
       000010E2  00000000000000000000   
       000010EC  00000000000000000000   
       000010F6  00000000000000000000   
       00001100  00000000000000000000   
       0000110A  00000000000000000000   
       00001114  00000000000000000000   
       0000111E  00000000000000000000   
       00001128  00000000000000000000   
       00001132  00000000000000000000   
       0000113C  00000000000000000000   
       00001146  00000000000000000000   
       00001150  00000000000000000000   
       0000115A  00000000000000000000   
       00001164  00000000000000000000   
       0000116E  00000000000000000000   
       00001178  00000000000000000000   
       00001182  00000000000000000000   
       0000118C  00000000000000000000   
       00001196  00000000000000000000   
       000011A0  00000000000000000000   
       000011AA  00000000000000000000   
       000011B4  00000000000000000000   
       000011BE  00000000000000000000   
       000011C8  00000000000000000000   
       000011D2  00000000000000000000   
       000011DC  00000000000000000000   
       000011E6  00000000000000000000   
       000011F0  00000000000000000000   
       000011FA  00000000000000000000   
       00001204  00000000000000000000   
       0000120E  00000000000000000000   


                                        Intro_46.S           Page 20      5:05:16 pm 9-May-2023        RMAC 2.2.07 (Win32)


       00001218  00000000000000000000   
       00001222  00000000000000000000   
       0000122C  00000000000000000000   
       00001236  00000000000000000000   
       00001240  00000000000000000000   
       0000124A  00000000000000000000   
       00001254  00000000000000000000   
       0000125E  00000000000000000000   
       00001268  00000000000000000000   
       00001272  00000000000000000000   
       0000127C  00000000000000000000   
       00001286  00000000000000000000   
       00001290  00000000000000000000   
       0000129A  00000000000000000000   
       000012A4  00000000000000000000   
       000012AE  00000000000000000000   
       000012B8  00000000000000000000   
       000012C2  00000000000000000000   
       000012CC  00000000000000000000   
       000012D6  00000000000000000000   
       000012E0  00000000000000000000   
       000012EA  00000000000000000000   
       000012F4  00000000000000000000   
       000012FE  00000000000000000000   
       00001308  00000000000000000000   
       00001312  00000000000000000000   
       0000131C  00000000000000000000   
       00001326  00000000000000000000   
       00001330  00000000000000000000   
       0000133A  00000000000000000000   
       00001344  00000000000000000000   
       0000134E  00000000000000000000   
       00001358  00000000000000000000   
       00001362  00000000000000000000   
       0000136C  00000000000000000000   
       00001376  00000000000000000000   
       00001380  00000000000000000000   
       0000138A  00000000000000000000   
       00001394  00000000000000000000   
       0000139E  00000000000000000000   
       000013A8  00000000000000000000   
       000013B2  00000000000000000000   
       000013BC  00000000000000000000   
       000013C6  00000000000000000000   
       000013D0  00000000000000000000   
       000013DA  00000000000000000000   
       000013E4  00000000000000000000   
       000013EE  00000000000000000000   
       000013F8  00000000000000000000   
       00001402  00000000000000000000   
       0000140C  00000000000000000000   
       00001416  00000000000000000000   
       00001420  00000000000000000000   
       0000142A  00000000000000000000   
       00001434  00000000000000000000   
       0000143E  00000000000000000000   


                                        Intro_46.S           Page 21      5:05:16 pm 9-May-2023        RMAC 2.2.07 (Win32)


       00001448  00000000000000000000   
       00001452  00000000000000000000   
       0000145C  00000000000000000000   
       00001466  00000000000000000000   
       00001470  00000000000000000000   
       0000147A  00000000000000000000   
       00001484  00000000000000000000   
       0000148E  00000000000000000000   
       00001498  00000000000000000000   
       000014A2  00000000000000000000   
       000014AC  00000000000000000000   
       000014B6  00000000000000000000   
       000014C0  00000000000000000000   
       000014CA  00000000000000000000   
       000014D4  00000000000000000000   
       000014DE  00000000000000000000   
       000014E8  00000000000000000000   
       000014F2  00000000000000000000   
       000014FC  00000000000000000000   
       00001506  00000000000000000000   
       00001510  00000000000000000000   
       0000151A  00000000000000000000   
       00001524  00000000000000000000   
       0000152E  00000000000000000000   
       00001538  00000000000000000000   
       00001542  00000000000000000000   
       0000154C  00000000000000000000   
       00001556  00000000000000000000   
       00001560  00000000000000000000   
       0000156A  00000000000000000000   
       00001574  00000000000000000000   
       0000157E  00000000000000000000   
       00001588  00000000000000000000   
       00001592  00000000000000000000   
       0000159C  00000000000000000000   
       000015A6  00000000000000000000   
       000015B0  00000000000000000000   
       000015BA  00000000000000000000   
       000015C4  00000000000000000000   
       000015CE  00000000000000000000   
       000015D8  00000000000000000000   
       000015E2  00000000000000000000   
       000015EC  00000000000000000000   
       000015F6  00000000000000000000   
       00001600  00000000000000000000   
       0000160A  00000000000000000000   
       00001614  00000000000000000000   
       0000161E  00000000000000000000   
       00001628  00000000000000000000   
       00001632  00000000000000000000   
       0000163C  00000000000000000000   
       00001646  00000000000000000000   
       00001650  00000000000000000000   
       0000165A  00000000000000000000   
       00001664  00000000000000000000   
       0000166E  00000000000000000000   


                                        Intro_46.S           Page 22      5:05:16 pm 9-May-2023        RMAC 2.2.07 (Win32)


       00001678  00000000000000000000   
       00001682  00000000000000000000   
       0000168C  00000000000000000000   
       00001696  00000000000000000000   
       000016A0  00000000000000000000   
       000016AA  00000000000000000000   
       000016B4  00000000000000000000   
       000016BE  00000000000000000000   
       000016C8  00000000000000000000   
       000016D2  00000000000000000000   
       000016DC  00000000000000000000   
       000016E6  00000000000000000000   
       000016F0  00000000000000000000   
       000016FA  00000000000000000000   
       00001704  00000000000000000000   
       0000170E  00000000000000000000   
       00001718  00000000000000000000   
       00001722  00000000000000000000   
       0000172C  00000000000000000000   
       00001736  00000000000000000000   
       00001740  00000000000000000000   
       0000174A  00000000000000000000   
       00001754  00000000000000000000   
       0000175E  00000000000000000000   
       00001768  00000000000000000000   
       00001772  00000000000000000000   
       0000177C  00000000000000000000   
       00001786  00000000000000000000   
       00001790  00000000000000000000   
       0000179A  00000000000000000000   
       000017A4  00000000000000000000   
       000017AE  00000000000000000000   
       000017B8  00000000000000000000   
       000017C2  00000000000000000000   
       000017CC  00000000000000000000   
       000017D6  00000000000000000000   
       000017E0  00000000000000000000   
       000017EA  00000000000000000000   
       000017F4  00000000000000000000   
       000017FE  00000000000000000000   
       00001808  00000000000000000000   
       00001812  00000000000000000000   
       0000181C  00000000000000000000   
       00001826  00000000000000000000   
       00001830  00000000000000000000   
       0000183A  00000000000000000000   
       00001844  00000000000000000000   
       0000184E  00000000000000000000   
       00001858  00000000000000000000   
       00001862  00000000000000000000   
       0000186C  00000000000000000000   
       00001876  00000000000000000000   
       00001880  00000000000000000000   
       0000188A  00000000000000000000   
       00001894  00000000000000000000   
       0000189E  00000000000000000000   


                                        Intro_46.S           Page 23      5:05:16 pm 9-May-2023        RMAC 2.2.07 (Win32)


       000018A8  00000000000000000000   
       000018B2  00000000000000000000   
       000018BC  00000000000000000000   
       000018C6  00000000000000000000   
       000018D0  00000000000000000000   
       000018DA  00000000000000000000   
       000018E4  00000000000000000000   
       000018EE  00000000000000000000   
       000018F8  00000000000000000000   
       00001902  00000000000000000000   
       0000190C  00000000000000000000   
       00001916  00000000000000000000   
       00001920  00000000000000000000   
       0000192A  00000000000000000000   
       00001934  00000000000000000000   
       0000193E  00000000000000000000   
       00001948  00000000000000000000   
       00001952  00000000000000000000   
       0000195C  00000000000000000000   
       00001966  00000000000000000000   
       00001970  00000000000000000000   
       0000197A  00000000000000000000   
       00001984  00000000000000000000   
       0000198E  00000000000000000000   
       00001998  00000000000000000000   
       000019A2  00000000000000000000   
       000019AC  00000000000000000000   
       000019B6  00000000000000000000   
       000019C0  00000000000000000000   
       000019CA  00000000000000000000   
       000019D4  00000000000000000000   
       000019DE  00000000000000000000   
       000019E8  00000000000000000000   
       000019F2  00000000000000000000   
       000019FC  00000000000000000000   
       00001A06  00000000000000000000   
       00001A10  00000000000000000000   
       00001A1A  00000000000000000000   
       00001A24  00000000000000000000   
       00001A2E  00000000000000000000   
       00001A38  00000000000000000000   
       00001A42  00000000000000000000   
       00001A4C  00000000000000000000   
       00001A56  00000000000000000000   
       00001A60  00000000000000000000   
       00001A6A  00000000000000000000   
       00001A74  00000000000000000000   
       00001A7E  00000000000000000000   
       00001A88  00000000000000000000   
       00001A92  00000000000000000000   
       00001A9C  00000000000000000000   
       00001AA6  00000000000000000000   
       00001AB0  00000000000000000000   
       00001ABA  00000000000000000000   
       00001AC4  00000000000000000000   
       00001ACE  00000000000000000000   


                                        Intro_46.S           Page 24      5:05:16 pm 9-May-2023        RMAC 2.2.07 (Win32)


       00001AD8  00000000000000000000   
       00001AE2  00000000000000000000   
       00001AEC  00000000000000000000   
       00001AF6  00000000000000000000   
       00001B00  00000000000000000000   
       00001B0A  00000000000000000000   
       00001B14  00000000000000000000   
       00001B1E  00000000000000000000   
       00001B28  00000000000000000000   
       00001B32  00000000000000000000   
       00001B3C  00000000000000000000   
       00001B46  00000000000000000000   
       00001B50  00000000000000000000   
       00001B5A  00000000000000000000   
       00001B64  00000000000000000000   
       00001B6E  00000000000000000000   
       00001B78  00000000000000000000   
       00001B82  00000000000000000000   
       00001B8C  00000000000000000000   
       00001B96  00000000000000000000   
       00001BA0  00000000000000000000   
       00001BAA  00000000000000000000   
       00001BB4  00000000000000000000   
       00001BBE  00000000000000000000   
       00001BC8  00000000000000000000   
       00001BD2  00000000000000000000   
       00001BDC  00000000000000000000   
       00001BE6  00000000000000000000   
       00001BF0  00000000000000000000   
       00001BFA  00000000000000000000   
       00001C04  00000000000000000000   
       00001C0E  00000000000000000000   
       00001C18  00000000000000000000   
       00001C22  00000000000000000000   
       00001C2C  00000000000000000000   
       00001C36  00000000000000000000   
       00001C40  00000000000000000000   
       00001C4A  00000000000000000000   
       00001C54  00000000000000000000   
       00001C5E  00000000000000000000   
       00001C68  00000000000000000000   
       00001C72  00000000000000000000   
       00001C7C  00000000000000000000   
       00001C86  00000000000000000000   
       00001C90  00000000000000000000   
       00001C9A  00000000000000000000   
       00001CA4  00000000000000000000   
       00001CAE  00000000000000000000   
       00001CB8  00000000000000000000   
       00001CC2  00000000000000000000   
       00001CCC  00000000000000000000   
       00001CD6  00000000000000000000   
       00001CE0  00000000000000000000   
       00001CEA  00000000000000000000   
       00001CF4  00000000000000000000   
       00001CFE  00000000000000000000   


                                        Intro_46.S           Page 25      5:05:16 pm 9-May-2023        RMAC 2.2.07 (Win32)


       00001D08  00000000000000000000   
       00001D12  00000000000000000000   
       00001D1C  00000000000000000000   
       00001D26  00000000000000000000   
       00001D30  00000000000000000000   
       00001D3A  00000000000000000000   
       00001D44  00000000000000000000   
       00001D4E  00000000000000000000   
       00001D58  00000000000000000000   
       00001D62  00000000000000000000   
       00001D6C  00000000000000000000   
       00001D76  00000000000000000000   
       00001D80  00000000000000000000   
       00001D8A  00000000000000000000   
       00001D94  00000000000000000000   
       00001D9E  00000000000000000000   
       00001DA8  00000000000000000000   
       00001DB2  00000000000000000000   
       00001DBC  00000000000000000000   
       00001DC6  00000000000000000000   
       00001DD0  00000000000000000000   
       00001DDA  00000000000000000000   
       00001DE4  00000000000000000000   
       00001DEE  00000000000000000000   
       00001DF8  00000000000000000000   
       00001E02  00000000000000000000   
       00001E0C  00000000000000000000   
       00001E16  00000000000000000000   
       00001E20  00000000000000000000   
       00001E2A  00000000000000000000   
       00001E34  00000000000000000000   
       00001E3E  00000000000000000000   
       00001E48  00000000000000000000   
       00001E52  00000000000000000000   
       00001E5C  00000000000000000000   
       00001E66  00000000000000000000   
       00001E70  00000000000000000000   
       00001E7A  00000000000000000000   
       00001E84  00000000000000000000   
       00001E8E  00000000000000000000   
       00001E98  00000000000000000000   
       00001EA2  00000000000000000000   
       00001EAC  00000000000000000000   
       00001EB6  00000000000000000000   
       00001EC0  00000000000000000000   
       00001ECA  00000000000000000000   
       00001ED4  00000000000000000000   
       00001EDE  00000000FF54484BFE0F   
       00001EE8  000C0F00000E00000E00   
       00001EF2  000D00000D00000C0000   
       00001EFC  FA13FF54484BFDFB070D   
       00001F06  0018FE0F00170F00130F   
       00001F10  00100D0008000000FF54   
       00001F1A  484BFDFB0B0D0014FE0F   
       00001F24  001E0F0022FDFB070F00   
       00001F2E  180E0010FE0E0013FD0C   


                                        Intro_46.S           Page 26      5:05:16 pm 9-May-2023        RMAC 2.2.07 (Win32)


       00001F38  0018000000FF54484BFE   
       00001F42  0F00000F00030E00070E   
       00001F4C  000C0D00000D00030C00   
       00001F56  070C000C0B00000B0003   
       00001F60  0A00070A000C09000009   
       00001F6A  000308000708000C0700   
       00001F74  0007000306000706000C   
       00001F7E  05000005000304000704   
       00001F88  000C0300000300030200   
       00001F92  0702000C010000010003   
       00001F9C  000000FF54484BFE0F00   
       00001FA6  000F00040E00070E000C   
       00001FB0  0D00000D00040C00070C   
       00001FBA  000C0B00000B00040A00   
       00001FC4  070A000C090000090004   
       00001FCE  08000708000C07000007   
       00001FD8  000406000706000C0500   
       00001FE2  0005000404000704000C   
       00001FEC  03000003000402000702   
       00001FF6  000C0100000100040000   
       00002000  00FF54484BFE0F00000E   
       0000200A  00000D00000D01000D02   
       00002014  000D01000D00000DFF00   
       0000201E  0DFE000DFF000D00000D   
       00002028  01000D02000D01000D00   
       00002032  000DFF000DFE000DFF00   
       0000203C  0D00000D01000D02000D   
       00002046  01000D00000DFF000DFE   
       00002050  000DFF000D00000D0100   
       0000205A  0D02000D01000D00000D   
       00002064  FF000DFE000DFF000D00   
       0000206E  000D01000D02000D0100   
       00002078  0D00000DFF000DFE000D   
       00002082  FF000D00000D01000D02   
       0000208C  000D01000D00000DFF00   
       00002096  0DFE000DFF000D00000D   
       000020A0  01000D02000D01000D00   
       000020AA  000DFF000DFE000DFF00   
       000020B4  0D00000D01000D02000D   
       000020BE  01000D00000DFF000DFE   
       000020C8  000DFF000D00000D0100   
       000020D2  0D02000D01000D00000D   
       000020DC  FF000DFE000DFF000D00   
       000020E6  000D01000D02000D0100   
       000020F0  0D00000DFF000DFE000D   
       000020FA  FF000D00000D01000D02   
       00002104  000D01000D00000DFF00   
       0000210E  0DFE000DFF000D00000D   
       00002118  01000D02000D01000D00   
       00002122  000DFF000DFE000DFF00   
       0000212C  0D00000D01000D02000D   
       00002136  01000D00000DFF000DFE   
       00002140  000DFF000D00000D0100   
       0000214A  0D02000D01000D00000D   
       00002154  FF000DFE000DFF000D00   
       0000215E  000D01000D02000D0100   


                                        Intro_46.S           Page 27      5:05:16 pm 9-May-2023        RMAC 2.2.07 (Win32)


       00002168  0D00000DFF000DFE000D   
       00002172  FF000D00000D01000D02   
       0000217C  000D01000D00000DFF00   
       00002186  0DFE000DFF000D00000D   
       00002190  01000D02000D01000D00   
       0000219A  000DFF000DFE000DFF00   
       000021A4  0D00000D01000D02000D   
       000021AE  01000D00000DFF000000   
       000021B8  00FF54484BFEF9000016   
       000021C2  F901001BF9010020F902   
       000021CC  0025F902002AF903002F   
       000021D6  F9030034F9040039F904   
       000021E0  003EF9050043F9050048   
       000021EA  F906004DF9060052F907   
       000021F4  0057F907005CF9080061   
       000021FE  F9080066F909006BF909   
       00002208  0070F90A0075F90A007A   
       00002212  F90B007FF90B0084F90C   
       0000221C  0089F90C008EF90D0093   
       00002226  F90D0098F90E009DF90E   
       00002230  00A2F90F00A7F90F00AC   
       0000223A  F91000B1F91000B6F911   
       00002244  00BBF91100C0F91200C5   
       0000224E  F91200CAF91300CFF913   
       00002258  00D4F91400D9F91400DE   
       00002262  F91500E3F91500E8F916   
       0000226C  00EDF91600F2F91700F7   
       00002276  F91700FCF9180101F918   
       00002280  0106F919010BF9190110   
       0000228A  F91A0115F91A011AF91B   
       00002294  011FF91B0124F91C0129   
       0000229E  F91C012EF91D0133F91D   
       000022A8  0138F91E013DF91E0142   
       000022B2  F91F0147F91F014CF920   
       000022BC  0151F9200156F921015B   
       000022C6  F9210160F9220165F922   
       000022D0  016AF923016FF9230174   
       000022DA  F9240179F924017EF925   
       000022E4  0183F9250188F926018D   
       000022EE  F9260192F9270197F927   
       000022F8  019CF92801A1F92801A6   
       00002302  F92901ABF92901B0F92A   
       0000230C  01B5F92A01BAF92B01BF   
       00002316  F92B01C4F92C01C9F92C   
       00002320  01CEF92D01D3F92D01D8   
       0000232A  F92E01DDF92E0107F92F   
       00002334  01E7F92F01ECF93001F1   
       0000233E  F93001F6F93101FBF931   
       00002348  0200F9320205F932020A   
       00002352  F933020FF9330214F934   
       0000235C  0219F934021EF9350223   
       00002366  F9350228F936022DF936   
       00002370  0232F9370237F937023C   
       0000237A  F9380241F9380246F939   
       00002384  024BF9390250F93A0255   
       0000238E  F93A025AF93B025FF93B   


                                        Intro_46.S           Page 28      5:05:16 pm 9-May-2023        RMAC 2.2.07 (Win32)


       00002398  0264F93C0269F93C026E   
       000023A2  F93D0273F93D0278F93E   
       000023AC  027DF93E0282F93F0287   
       000023B6  F93F028CF94002910000   
       000023C0  00FF54483FFE02FC0F00   
       000023CA  08000800080008000800   
       000023D4  08000800080008000800   
       000023DE  08000800080008000800   
       000023E8  080002FE043002300230   
       000023F2  02FE020002FE04300230   
       000023FC  023002FE020002FE052E   
       00002406  022E022E02FE020002FE   
       00002410  052E022E022E02FE0200   
       0000241A  02FE04300230023002FE   
       00002424  020002FE043002300230   
       0000242E  02FE020002FE05330233   
       00002438  023302FE020002FE0533   
       00002442  02FE0435023702FE0200   
       0000244C  02FE04300230023002FE   
       00002456  020002FE043002300230   
       00002460  02FE020002FE052E022E   
       0000246A  022E02FE020002FE052E   
       00002474  022E022E02FE020002FE   
       0000247E  04300230023002FE0200   
       00002488  02FE04300230023002FE   
       00002492  020002FE053302330233   
       0000249C  02FE020002FE053302FE   
       000024A6  0435023702FE020002FE   
       000024B0  04300230023002FE0200   
       000024BA  02FE04300230023002FE   
       000024C4  020002FE052E022E022E   
       000024CE  02FE020002FE052E022E   
       000024D8  022E02FE020002FE0430   
       000024E2  0230023002FE020002FE   
       000024EC  04300230023002FE0200   
       000024F6  02FE05330233023302FE   
       00002500  020002FE053302FE0435   
       0000250A  023702FE020002FE0430   
       00002514  0230023002FE020002FE   
       0000251E  04300230023002FE0200   
       00002528  02FE052E022E022E02FE   
       00002532  020002FE052E022E022E   
       0000253C  02FE020002FE04300230   
       00002546  023002FE020002FE0430   
       00002550  0230023002FE020002FE   
       0000255A  05330233023302FE0200   
       00002564  02FE053302FE04350237   
       0000256E  02FE020002FE04300230   
       00002578  023002FE020002FE0430   
       00002582  0230023002FE020002FE   
       0000258C  052E022E022E02FE0200   
       00002596  02FE052E022E022E02FE   
       000025A0  020002FE043002300230   
       000025AA  02FE020002FE04300230   
       000025B4  023002FE020002FE0533   
       000025BE  0233023302FE020002FE   


                                        Intro_46.S           Page 29      5:05:16 pm 9-May-2023        RMAC 2.2.07 (Win32)


       000025C8  053302FE0435023702FE   
       000025D2  020002FE043002300230   
       000025DC  02FE020002FE04300230   
       000025E6  023002FE020002FE052E   
       000025F0  022E022E02FE020002FE   
       000025FA  052E022E022E02FE0200   
       00002604  02FE04300230023002FE   
       0000260E  020002FE043002300230   
       00002618  02FE020002FE05330233   
       00002622  023302FE020002FE0533   
       0000262C  02FE043501FE000001FE   
       00002636  043701FE000001FE0200   
       00002640  02FE04300230023002FE   
       0000264A  020002FE043002300230   
       00002654  02FE020002FE052E022E   
       0000265E  022E02FE020002FE052E   
       00002668  022E022E02FE020002FE   
       00002672  04300230023002FE0200   
       0000267C  02FE04300230023002FE   
       00002686  020002FE053302330233   
       00002690  02FE020002FE053302FE   
       0000269A  043501FE000001FE0437   
       000026A4  01FE000001FE020002FE   
       000026AE  04300230023002FE0200   
       000026B8  02FE04300230023002FE   
       000026C2  020004FE052E04FE0200   
       000026CC  04FE052E04FE020006FE   
       000026D6  0430063006FE053306FE   
       000026E0  02000800080008000800   
       000026EA  08000800080008000800   
       000026F4  08000800080008000800   
       000026FE  0800080008FF54484BFE   
       00002708  01FC0F18020C02FE0300   
       00002712  02FE010C011301180216   
       0000271C  011301FE030002FE010C   
       00002726  020A0207010A01FE0300   
       00002730  02FE010A020E02110113   
       0000273A  01FE0300020002FE010C   
       00002744  04FE030002FE0118011B   
       0000274E  01180213010C01FE0300   
       00002758  02FE010C010E010F0218   
       00002762  011601FE030002FE0118   
       0000276C  010C011B021D011F01FE   
       00002776  030001FE012201FE0300   
       00002780  010001FE0118020C02FE   
       0000278A  030002FE010C01130118   
       00002794  0216011301FE030002FE   
       0000279E  010C020A0207010A01FE   
       000027A8  030002FE010A020E0211   
       000027B2  011301FE0300020002FE   
       000027BC  010C04FE030002FE0118   
       000027C6  011B01180213010C01FE   
       000027D0  030002FE010C010E010F   
       000027DA  0218011601FE030002FE   
       000027E4  0118010C011B021D011F   
       000027EE  01FE030001FE012201FE   


                                        Intro_46.S           Page 30      5:05:16 pm 9-May-2023        RMAC 2.2.07 (Win32)


       000027F8  0300010001FE0118020C   
       00002802  02FE030002FE010C0113   
       0000280C  01180216011301FE0300   
       00002816  02FE010C020A0207010A   
       00002820  01FE030002FE010A020E   
       0000282A  0211011301FE03000200   
       00002834  02FE010C04FE030002FE   
       0000283E  0118011B01180213010C   
       00002848  01FE030002FE010C010E   
       00002852  010F0218011601FE0300   
       0000285C  02FE0118010C011B021D   
       00002866  011F01FE030001FE0122   
       00002870  01FE0300010001FE0118   
       0000287A  020C02FE030002FE010C   
       00002884  011301180216011301FE   
       0000288E  030002FE010C020A0207   
       00002898  010A01FE030002FE010A   
       000028A2  020E0211011301FE0300   
       000028AC  020002FE010C04FE0300   
       000028B6  02FE0118011B01180213   
       000028C0  010C01FE030002FE010C   
       000028CA  010E010F0218011601FE   
       000028D4  030002FE0118010C011B   
       000028DE  021D011F01FE030001FE   
       000028E8  012201FE0300010001FE   
       000028F2  0118020C02FE030002FE   
       000028FC  010C0113011802160113   
       00002906  01FE030002FE010C020A   
       00002910  0207010A01FE030002FE   
       0000291A  010A020E0211011301FE   
       00002924  0300020002FE010C04FE   
       0000292E  030002FE0118011B0118   
       00002938  0213010C01FE030002FE   
       00002942  010C010E010F02180116   
       0000294C  01FE030002FE0118010C   
       00002956  011B021D011F01FE0300   
       00002960  01FE012201FE03000100   
       0000296A  01FE0118020C02FE0300   
       00002974  02FE010C011301180216   
       0000297E  011301FE030002FE010C   
       00002988  020A0207010A01FE0300   
       00002992  02FE010A020E02110113   
       0000299C  01FE0300020002FE010C   
       000029A6  04FE030002FE0118011B   
       000029B0  01180213010C01FE0300   
       000029BA  02FE010C010E010F0218   
       000029C4  011601FE030002FE0118   
       000029CE  010C011B021D011F01FE   
       000029D8  030001FE012201FE0300   
       000029E2  010001FE0118020C02FE   
       000029EC  030002FE010C01130118   
       000029F6  0216011301FE030002FE   
       00002A00  010C020A0207010A01FE   
       00002A0A  030002FE010A020E0211   
       00002A14  011301FE0300020002FE   
       00002A1E  010C04FE030002FE0118   


                                        Intro_46.S           Page 31      5:05:16 pm 9-May-2023        RMAC 2.2.07 (Win32)


       00002A28  011B01180213010C01FE   
       00002A32  030002FE010C010E010F   
       00002A3C  0218011601FE030002FE   
       00002A46  0118010C011B021D011F   
       00002A50  01FE030001FE012201FE   
       00002A5A  0300010001FE0118020C   
       00002A64  02FE030002FE010C0113   
       00002A6E  01180216011301FE0300   
       00002A78  02FE010C020A0207010A   
       00002A82  01FE030002FE010A020E   
       00002A8C  0211011301FE03000200   
       00002A96  02FE010C04FE030002FE   
       00002AA0  0118011B01180213010C   
       00002AAA  01FE030002FE010C010E   
       00002AB4  010F0218011601FE0300   
       00002ABE  02FE0118010C011B021D   
       00002AC8  011F01FE0300020002FE   
       00002AD2  0118020C02FE030002FE   
       00002ADC  010C0113011802160113   
       00002AE6  01FE030002FE010C020A   
       00002AF0  0207010A01FE030002FE   
       00002AFA  010A020E0211011301FE   
       00002B04  0300020002FE010C04FE   
       00002B0E  030002FE0118011B0118   
       00002B18  0213010C01FE030002FE   
       00002B22  010C010E010F02180116   
       00002B2C  01FE030002FE0118010C   
       00002B36  011B021D011F01FE0300   
       00002B40  020002FE0118020C02FE   
       00002B4A  030002FE010C01130118   
       00002B54  0216011301FE030002FE   
       00002B5E  010C020A0207010A01FE   
       00002B68  030002FE010A020E0211   
       00002B72  011301FE0300020002FE   
       00002B7C  010C04FE030002FE0118   
       00002B86  011B01180213010C01FE   
       00002B90  030002FE010C010E010F   
       00002B9A  0218011601FE030002FE   
       00002BA4  0118010C011B021D011F   
       00002BAE  01FE0300020002FE0118   
       00002BB8  020C02FE030002FE010C   
       00002BC2  011301180216011301FE   
       00002BCC  030002FE010C020A0207   
       00002BD6  010A01FE030002FE010A   
       00002BE0  020E0211011301FE0300   
       00002BEA  020002FE010C04FE0300   
       00002BF4  02FE0118011B01180213   
       00002BFE  010C01FE030002FE010C   
       00002C08  010E010F0218011601FE   
       00002C12  030002FE0118010C011B   
       00002C1C  021D011F01FE03000200   
       00002C26  02FE0118020C02FE0300   
       00002C30  02FE010C011301180216   
       00002C3A  011301FE030002FE010C   
       00002C44  020A0207010A01FE0300   
       00002C4E  02FE010A020E02110113   


                                        Intro_46.S           Page 32      5:05:16 pm 9-May-2023        RMAC 2.2.07 (Win32)


       00002C58  01FE0300020002FE010C   
       00002C62  04FE030002FE0118011B   
       00002C6C  01180213010C01FE0300   
       00002C76  02FE010C010E010F0218   
       00002C80  011601FE030002FE0118   
       00002C8A  010C011B021D011F01FE   
       00002C94  0300020002FF54484BFE   
       00002C9E  00FC0000400080FE06FC   
       00002CA8  0F3006FE002402FE062E   
       00002CB2  02FE002402FE062D02FE   
       00002CBC  002402FE062B082E042B   
       00002CC6  022E023006FE002402FE   
       00002CD0  062E02FE002402FE0629   
       00002CDA  01240126022708FE073C   
       00002CE4  08FE063006FE002402FE   
       00002CEE  062E02FE002402FE062D   
       00002CF8  02FE002402FE062B082E   
       00002D02  042B022E023006FE0024   
       00002D0C  02FE062E02FE002402FE   
       00002D16  062901240126022708FE   
       00002D20  073C08FE063001FE0024   
       00002D2A  01FE062B022E0230022B   
       00002D34  022E0230022B022E01FE   
       00002D3E  002407FE063202FE0024   
       00002D48  02FE063502FE002402FE   
       00002D52  063701FE002401FE0630   
       00002D5C  02330237023002330237   
       00002D66  0230023302FE072402FE   
       00002D70  062E02FE072402FE062B   
       00002D7A  02FE07240224022402FE   
       00002D84  063001FE002401FE062B   
       00002D8E  022E0230022B022E0230   
       00002D98  022B022E01FE002407FE   
       00002DA2  063202FE002402FE0635   
       00002DAC  02FE002402FE063701FE   
       00002DB6  002401FE063002330237   
       00002DC0  02300233023702300233   
       00002DCA  02FE072402FE062E02FE   
       00002DD4  072402FE062B02FE0724   
       00002DDE  0224022402FE063C0137   
       00002DE8  0133013001330137013C   
       00002DF2  01370133013001330137   
       00002DFC  013C013701330130012E   
       00002E06  01290126012201260129   
       00002E10  012E0129012601220126   
       00002E1A  0129012E012901260122   
       00002E24  01240127012B0130012B   
       00002E2E  012701240127012B0130   
       00002E38  012B012701240127012B   
       00002E42  013001330137013A013F   
       00002E4C  013A013701330137013A   
       00002E56  013F013A013701340235   
       00002E60  01FE003001FE063C0137   
       00002E6A  0133013001330137013C   
       00002E74  01370133013001330137   
       00002E7E  013C013701330130012E   


                                        Intro_46.S           Page 33      5:05:16 pm 9-May-2023        RMAC 2.2.07 (Win32)


       00002E88  01290126012201260129   
       00002E92  012E0129012601220126   
       00002E9C  0129012E012901260122   
       00002EA6  01240127012B0130012B   
       00002EB0  012701240127012B0130   
       00002EBA  012B012701240127012B   
       00002EC4  013001330137013A013F   
       00002ECE  013A013701330137013A   
       00002ED8  013F013A013701340235   
       00002EE2  01FE003001FE07483C48   
       00002EEC  024802FE04FC0154014F   
       00002EF6  014C014901FC0254014E   
       00002F00  015D015901FC0353014F   
       00002F0A  015B014E01FC044D0151   
       00002F14  014C015801FC05540151   
       00002F1E  0148014B01FC0654015D   
       00002F28  0157015901FC07540151   
       00002F32  014B014D01FC08540148   
       00002F3C  014C014901FC0951015F   
       00002F46  0156014C01FC0A540148   
       00002F50  014B014E01FC0B4E0150   
       00002F5A  014D014C01FC0C540150   
       00002F64  014D015E01FC0D54014C   
       00002F6E  0148014901FC0E4D015D   
       00002F78  0159015101FC0F54014B   
       00002F82  01490152014D014F014C   
       00002F8C  014D01480154014F014D   
       00002F96  014B015D0157014F01FC   
       00002FA0  0E54014F014C014B01FC   
       00002FAA  0D48015B0158015601FC   
       00002FB4  0C540151014D014F01FC   
       00002FBE  0B54014E014B015901FC   
       00002FC8  0A54014F014C014801FC   
       00002FD2  09540151014E015001FC   
       00002FDC  0854014F014D015201FC   
       00002FE6  0754014B0149014D01FC   
       00002FF0  064F01500159015B01FC   
       00002FFA  0549014D0151014C01FC   
       00003004  044F01530151015201FC   
       0000300E  034C014A0148014901FC   
       00003018  024D014F015B015001FC   
       00003022  014C014F014B015601FF   
       0000302C  54484B450000           
  604                                   	even
  605                                   
  606                                   ***************************************************************
  607  00003032                         	BSS                                                    // *
  608                                   ***************************************************************
  609                                   
  610                                   * << Full data here >>
  611                                   
  612                                   
  613                                   * <
  614                                   
  615                                   Vsync:
  616  00000000 =00000001               	ds.w 1  ; Vertical Sync with int $70.w


                                        Intro_46.S           Page 34      5:05:16 pm 9-May-2023        RMAC 2.2.07 (Win32)


  617                                   
  618                                   Save_stack:
  619  00000002 =00000001               	ds.l 1  ; Stack
  620                                   
  621                                   Save_all:
  622  00000006 =00000010               	ds.b 16 ; MFP Interrupts
  623  00000016 =00000004               	ds.b 4	; Video : f8201.w -> f820d.w
  624                                   
  625                                   Save_rest:
  626  0000001A =00000001               	ds.l 1	; Autovector (HBL)
  627  0000001E =00000001               	ds.l 1	; Autovector (VBL)
  628  00000022 =00000001               	ds.l 1	; Timer D (USART timer)
  629  00000026 =00000001               	ds.l 1	; Timer C (200hz Clock)
  630  0000002A =00000001               	ds.l 1	; Keyboard/MIDI (ACIA) 
  631  0000002E =00000001               	ds.l 1	; Timer B (HBL)
  632  00000032 =00000001               	ds.l 1	; Timer A
  633  00000036 =00000001               	ds.l 1	; Output Bip Bop
  634                                   
  635                                   Palette:
  636  0000003A =00000010               	ds.w 16 ; Palette System
  637                                   
  638                                   Screen:     ; Screens from buffer
  639  0000005A =00000100               	ds.b 256
  640  0000015A =0000FA00               	ds.b SIZE_OF_SCREEN*(NB_OF_SCREEN+1)
  641                                   
  642                                   ***************************************************************
  643  0000FB5A                         	TEXT                                                   // *
  644                                   ***************************************************************
  645                                   
  646                                   .if (FADE_INTRO = 0)
  647                                 - ***************************************************************
  648                                 - *                                                             *
  649                                 - *                    FADING WHITE TO BLACK                    *
  650                                 - *                  (Don't use VBL with it !)                  *
  651                                 - *                                                             *
  652                                 - ***************************************************************
  653                                 - fadein:
  654                                 - 	move.l	#$777,d0
  655                                 - .deg:
  656                                 -  rept 3
  657                                 - 	bsr.s	wart
  658                                 -  endr
  659                                 - 	lea	$ffff8240.w,a0
  660                                 - 	moveq	#15,d1
  661                                 - .chg1:
  662                                 - 	move.w	d0,(a0)+
  663                                 - 	dbf	d1,.chg1
  664                                 - 	sub.w	#$111,d0
  665                                 - 	bne.s	.deg
  666                                 - 	bsr.s	black_out              ; All palette colors to zero
  667                                 - 	rts
  668                                 - 
  669                                 - black_out:                         ; Clear Palette colors
  670                                 - 	moveq  #0,d0
  671                                 - 	moveq  #0,d1
  672                                 - 	moveq  #0,d2


                                        Intro_46.S           Page 35      5:05:16 pm 9-May-2023        RMAC 2.2.07 (Win32)


  673                                 - 	moveq  #0,d3
  674                                 - 	moveq  #0,d4
  675                                 - 	moveq  #0,d5
  676                                 - 	moveq  #0,d6
  677                                 - 	moveq  #0,d7
  678                                 - 	movem.l d0-d7,$ffff8240.w
  679                                 - 	rts
  680                                 - 
  681                                 - wart:                              ; VSYNC()
  682                                 - 	move.l	d0,-(sp)
  683                                 - 	move.l	$466.w,d0
  684                                 - .att:	cmp.l	$466.w,d0
  685                                 - 	beq.s	.att
  686                                 - 	move.l	(sp)+,d0
  687                                 - 	rts
  688                                 - .endif
  689                                   
  690                                   .if (ERROR_SYS = 0)
  691                                 - ***************************************************************
  692                                 - *                                                             *
  693                                 - *               Error Routines (Dbug 2/Next)                  *
  694                                 - *          http://www.defence-force.org/index.htm             *
  695                                 - *                                                             *
  696                                 - ***************************************************************
  697                                 - INPUT_TRACE_ERROR:
  698                                 - 	lea $8.w,a0                       ; Adresse de base des vecteurs (Erreur de Bus)
  699                                 - 	lea liste_vecteurs,a1             ;
  700                                 - 	moveq #10-1,d0                    ; On d^^étourne toutes les erreur possibles...
  701                                 - .b_sauve_exceptions:
  702                                 - 	move.l (a1)+,d1                   ; Adresse de la nouvelle routine
  703                                 - 	move.l (a0)+,-4(a1)               ; Sauve l'ancienne
  704                                 - 	move.l d1,-4(a0)                  ; Installe la mienne
  705                                 - 	dbra d0,.b_sauve_exceptions
  706                                 - 	rts
  707                                 - 
  708                                 - OUTPUT_TRACE_ERROR:
  709                                 - 	lea $8.w,a0
  710                                 - 	lea liste_vecteurs,a1
  711                                 - 	moveq #10-1,d0
  712                                 - .restaure_illegal:
  713                                 - 	move.l (a1)+,(a0)+
  714                                 - 	dbra d0,.restaure_illegal
  715                                 - 	rts
  716                                 - 
  717                                 - routine_bus: ; BUS - GREEN
  718                                 - 	move.w #$070,d0
  719                                 - 	bra.s execute_detournement
  720                                 - routine_adresse:	;	ADDRESS - BLUE
  721                                 - 	move.w #$007,d0
  722                                 - 	bra.s execute_detournement
  723                                 - routine_illegal:	;	ILLEGAL - RED
  724                                 - 	move.w #$700,d0
  725                                 - 	bra.s execute_detournement
  726                                 - routine_div:	;	DIV ERROR - YELLOW
  727                                 - 	move.w #$770,d0
  728                                 - 	bra.s execute_detournement


                                        Intro_46.S           Page 36      5:05:16 pm 9-May-2023        RMAC 2.2.07 (Win32)


  729                                 - routine_chk:	;	CHECK - LIGHT BLUE
  730                                 - 	move.w #$077,d0
  731                                 - 	bra.s execute_detournement
  732                                 - routine_trapv:	;	TRAP ERROR - WHITE
  733                                 - 	move.w #$777,d0
  734                                 - 	bra.s execute_detournement
  735                                 - routine_viole:	;	VIOLATION ACCESS - PURPLE
  736                                 - 	move.w #$707,d0
  737                                 - 	bra.s execute_detournement
  738                                 - routine_trace:	;	TRACE ERROR - DARK BLACK
  739                                 - 	move.w #$333,d0
  740                                 - 	bra.s execute_detournement
  741                                 - routine_line_a:	;	LINE A ERROR - ORANGE
  742                                 - 	move.w #$740,d0
  743                                 - 	bra.s execute_detournement
  744                                 - routine_line_f:	;	LINE F ERROR - LIGHT GREEN
  745                                 - 	move.w #$474,d0
  746                                 - execute_detournement:
  747                                 - 	move.w #$2700,SR                  ; Deux erreurs ^^à suivre... non mais !
  748                                 - 
  749                                 - 	move.w	#$0FF,d1
  750                                 - .loop:
  751                                 - 	move.w d0,$ffff8240.w             ; Effet raster
  752                                 - 	move.w #0,$ffff8240.w
  753                                 - 	cmp.b #$3b,$fffffc02.w
  754                                 - 	dbra d1,.loop
  755                                 - 
  756                                 - 	pea ESCAPE_PRG                    ; Put the return adress
  757                                 - 	move.w #$2700,-(sp)               ; J'esp^^ère !!!...
  758                                 - 	addq.l #2,2(sp)                   ; 24/6
  759                                 - 	rte                               ; 20/5 => Total hors tempo = 78-> 80/20 nops
  760                                 - 
  761                                 - liste_vecteurs:
  762                                 - 	dc.l routine_bus	; Vert
  763                                 - 	dc.l routine_adresse	; Bleu
  764                                 - 	dc.l routine_illegal	; Rouge
  765                                 - 	dc.l routine_div	; Jaune
  766                                 - 	dc.l routine_chk	; Ciel
  767                                 - 	dc.l routine_trapv	; Blanc
  768                                 - 	dc.l routine_viole	; Violet
  769                                 - 	dc.l routine_trace	; Gris
  770                                 - 	dc.l routine_line_a	; Orange
  771                                 - 	dc.l routine_line_f	; Vert clair
  772                                 - 	even
  773                                 - .endif
  774                                   
  775                                   .if (STF_INITS = 0)
  776                                   ***************************************************************************
  777                                   *                                                                         *
  778                                   * Multi Atari Boot code.                                                  *
  779                                   * If you have done an ST demo, use that boot to run it on these machines: *
  780                                   * ST, STe, Mega-ST,TT,Falcon,CT60                                         *
  781                                   * More info:                                                              *
  782                                   * http://leonard.oxg.free.fr/articles/multi_atari/multi_atari.html        *
  783                                   *                                                                         *
  784                                   ***************************************************************************


                                        Intro_46.S           Page 37      5:05:16 pm 9-May-2023        RMAC 2.2.07 (Win32)


  785                                   Multi_boot:
  786  0000031C  51F801FE               	sf $1fe.w
  787  00000320  203805A0               	move.l $5a0.w,d0
  788  00000324  6700xxxx               	beq noCookie
  789  00000328  2040                   	move.l d0,a0
  790                                   .loop:
  791  0000032A  2018                   	move.l (a0)+,d0
  792  0000032C  6700xxxx               	beq noCookie
  793  00000330  B0BC5F4D4348           	cmp.l #'_MCH',d0
  794  00000336  67xx                   	beq.s .find
  795  00000338  B0BC43543630           	cmp.l #'CT60',d0
  796  0000033E  66xx                   	bne.s .skip
  797                                   
  798                                   ; CT60, switch off the cache
  799  00000340  4850                   	pea (a0)
  800                                   
  801  00000342  41FAxxxx               	lea bCT60(pc),a0
  802  00000346  50D0                   	st (a0)
  803                                   
  804  00000348  4267                   	clr.w -(a7) ; param = 0 ( switch off all caches )
  805  0000034A  3F3C0005               	move.w #5,-(a7) ; opcode
  806  0000034E  3F3C00A0               	move.w #160,-(a7)
  807  00000352  4E4E                   	trap #14
  808  00000354  5C4F                   	addq.w #6,a7
  809  00000356  205F                   	move.l (a7)+,a0
  810                                   .skip:
  811  00000358  5848                   	addq.w #4,a0
  812  0000035A  60CE                   	bra.s .loop
  813                                   
  814                                   .find:
  815  0000035C  3E18                   	move.w (a0)+,d7
  816  0000035E  6700xxxx               	beq noCookie ; STF
  817  00000362  11C701FE               	move.b d7,$1fe.w
  818                                   
  819  00000366  0C470001               	cmpi.w #1,d7
  820  0000036A  66xx                   	bne.s .noSTE
  821  0000036C  082800040001           	btst.b #4,1(a0)
  822  00000372  67xx                   	beq.s .noMegaSTE
  823  00000374  42388E21               	clr.b $ffff8e21.w ; 8Mhz MegaSTE
  824                                   
  825                                   .noMegaSTE:
  826  00000378  60xx                   	bra.s noCookie
  827                                   
  828                                   .noSTE:
  829                                   ; => here TT or FALCON
  830  0000037A  08B800058007           	bclr.b	#5,$FFFF8007.w ; Mode STE on Falcon
  831  00000380  08B800028007           	bclr.b	#2,$FFFF8007.w ; Blitter at 8Mhz
  832                                   
  833                                   ; Always switch off the cache on these machines.
  834  00000386  103Axxxx               	move.b bCT60(pc),d0
  835  0000038A  66xx                   	bne.s .noMovec
  836                                   
  837  0000038C  7000                   	moveq #0,d0
  838  0000038E  4E7B0002               	dc.l $4e7b0002 ; movec d0,cacr ; switch off cache
  839                                   .noMovec:
  840                                   


                                        Intro_46.S           Page 38      5:05:16 pm 9-May-2023        RMAC 2.2.07 (Win32)


  841  00000392  0C470003               	cmpi.w #3,d7
  842  00000396  66xx                   	bne.s noCookie
  843                                   
  844                                   ; Here FALCON
  845  00000398  3F3C0059               	move.w #$59,-(a7) ;check monitortype (falcon)
  846  0000039C  4E4E                   	trap #14
  847  0000039E  548F                   	addq.l #2,a7
  848  000003A0  41FAxxxx               	lea rgb50(pc),a0
  849  000003A4  5340                   	subq.w #1,d0
  850  000003A6  67xx                   	beq.s .setRegs
  851  000003A8  5540                   	subq.w #2,d0
  852  000003AA  67xx                   	beq.s .setRegs
  853  000003AC  41FAxxxx               	lea vga50(pc),a0
  854                                   
  855                                   .setRegs:
  856  000003B0  21D88282               	move.l (a0)+,$ffff8282.w
  857  000003B4  21D88286               	move.l (a0)+,$ffff8286.w
  858  000003B8  21D8828A               	move.l (a0)+,$ffff828a.w
  859  000003BC  21D882A2               	move.l (a0)+,$ffff82a2.w
  860  000003C0  21D882A6               	move.l (a0)+,$ffff82a6.w
  861  000003C4  21D882AA               	move.l (a0)+,$ffff82aa.w
  862  000003C8  31D8820A               	move.w (a0)+,$ffff820a.w
  863  000003CC  31D882C0               	move.w (a0)+,$ffff82c0.w
  864  000003D0  31D88266               	move.w (a0)+,$ffff8266.w
  865  000003D4  42388260               	clr.b $ffff8260.w
  866  000003D8  31D882C2               	move.w (a0)+,$ffff82c2.w
  867  000003DC  31D88210               	move.w (a0)+,$ffff8210.w
  868                                   
  869                                   noCookie:
  870                                   
  871                                   ; Set res for all machines exept falcon or ct60
  872  000003E0  0C38000301FE           	cmpi.b #3,$1fe.w
  873  000003E6  67xx                   	beq.s letsGo
  874                                   
  875  000003E8  4267                   	clr.w -(a7) ;set stlow (st/tt)
  876  000003EA  70FF                   	moveq #-1,d0
  877  000003EC  2F00                   	move.l d0,-(a7)
  878  000003EE  2F00                   	move.l d0,-(a7)
  879  000003F0  3F3C0005               	move.w #5,-(a7)
  880  000003F4  4E4E                   	trap #14
  881  000003F6  4FEF000C               	lea 12(a7),a7
  882                                   
  883  000003FA  0C38000201FE           	cmpi.b #2,$1fe.w ; enough in case of TT
  884  00000400  67xx                   	beq.s letsGo
  885                                   
  886  00000402  30380468               	move.w $468.w,d0
  887                                   .vsync:
  888  00000406  B0780468               	cmp.w $468.w,d0
  889  0000040A  67FA                   	beq.s .vsync
  890                                   
  891  0000040C  11FC0002820A           	move.b #2,$ffff820a.w
  892  00000412  42388260               	clr.b $ffff8260.w
  893                                   
  894                                   letsGo:
  895  00000416  4E75                   	rts
  896                                   


                                        Intro_46.S           Page 39      5:05:16 pm 9-May-2023        RMAC 2.2.07 (Win32)


  897                                   vga50:
  898  00000418  00170011               	dc.l $170011
  899  0000041C  0002020E               	dc.l $2020E
  900  00000420  000D0012               	dc.l $D0012
  901  00000424  04EB04D1               	dc.l $4EB04D1
  902  00000428  003F00F5               	dc.l $3F00F5
  903  0000042C  041504E7               	dc.l $41504E7
  904  00000430  0200                   	dc.w $0200
  905  00000432  0186                   	dc.w $186
  906  00000434  0000                   	dc.w $0
  907  00000436  0005                   	dc.w $5
  908  00000438  0050                   	dc.w $50
  909                                   
  910                                   rgb50:
  911  0000043A  00300027               	dc.l $300027
  912  0000043E  00070229               	dc.l $70229
  913  00000442  001E002A               	dc.l $1e002a
  914  00000446  02710265               	dc.l $2710265
  915  0000044A  002F0081               	dc.l $2f0081
  916  0000044E  0211026B               	dc.l $211026b
  917  00000452  0200                   	dc.w $0200
  918  00000454  0185                   	dc.w $185
  919  00000456  0000                   	dc.w $0
  920  00000458  0000                   	dc.w $0
  921  0000045A  0050                   	dc.w $50
  922                                   
  923                                   bCT60:
  924  0000045C  00                     	dc.b 0
  925  0000045D  00                     	even
  926                                   .endif
  927                                   
  928                                   ******************************************************************
  929                                   	END                                                       // *


                                        Intro_46.S           Page 40      5:05:16 pm 9-May-2023        RMAC 2.2.07 (Win32)
Symbol Table

             .find 000000000000035C  t 
            .flush 0000000000000310  t 
             .loop 0000000000000146  t 
             .loop 000000000000032A  t 
         .next_key 000000000000008A  t 
        .noMegaSTE 0000000000000378  t 
          .noMovec 0000000000000392  t 
            .noSTE 000000000000037A  t 
          .setRegs 00000000000003B0  t 
             .skip 0000000000000358  t 
            .vsync 0000000000000406  t 
             .wait 00000000000002FE  t 
           BLITTER 0000000000000001  a 
     BOTTOM_BORDER 0000000000000001  a 
             Begin 0000000000000000  t 
   Default_palette 0000000000000000  d 
         ERROR_SYS 0000000000000001  a 
        ESCAPE_PRG 0000000000000092  t 
          EXIT_PRG 0000000000000096  t 
        FADE_INTRO 0000000000000001  a 
      Init_screens 00000000000000D4  t 
             Inits 00000000000000A8  t 
             MUSIC 0000000000000020  d 
        Multi_boot 000000000000031C  t 
      NB_OF_SCREEN 0000000000000001  a 
         NO_BORDER 0000000000000000  a 
        ONE_SCREEN 0000000000000000  a 
         Old_Resol 00000000000002DE  t 
        Old_Screen 00000000000002E2  t 
           PATTERN 0000000000010001  a 
           Palette 000000000000003A  b 
        Restore_st 000000000000021E  t 
          SEEMYVBL 0000000000000000  a 
    SIZE_OF_SCREEN 0000000000007D00  a 
         STF_INITS 0000000000000000  a 
          Save_all 0000000000000006  b 
  Save_and_init_st 000000000000014E  t 
         Save_rest 000000000000001A  b 
        Save_stack 0000000000000002  b 
            Screen 000000000000005A  b 
          TEST_STE 0000000000000001  a 
  TOPBOTTOM_BORDER 0000000000000001  a 
       TWO_SCREENS 0000000000000001  a 
               Vbl 0000000000000126  t 
             Vsync 0000000000000000  b 
          Wait_vbl 000000000000013C  t 
             bCT60 000000000000045C  t 
      default_loop 0000000000000058  t 
             flush 000000000000030C  t 
            letsGo 0000000000000416  t 
          noCookie 00000000000003E0  t 
          physique 000000000000011E  t 
             rgb50 000000000000043A  t 
    sendToKeyboard 00000000000002FE  t 
             vga50 0000000000000418  t 

