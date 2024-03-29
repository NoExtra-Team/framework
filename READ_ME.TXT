****************
* INFORMATIONS *
****************

The Framework has been tested on Atari STF / STE / MSTE.

The Framework is compatible building under 2.x & 3.x Devpack version.

1 / Parameters:
===============

1.1 Overscan usage :
--------------------
By default, the parameter is NO_BORDER. (That means no overscan of course)

a) Low Overscan :
-----------------
BOTTOM_BORDER    equ 0
TOPBOTTOM_BORDER equ 1
NO_BORDER        equ 1

b) Overscan High & Low :
------------------------
BOTTOM_BORDER    equ 1
TOPBOTTOM_BORDER equ 0
NO_BORDER        equ 1

c) No Overscan :
----------------
BOTTOM_BORDER    equ 1
TOPBOTTOM_BORDER equ 1
NO_BORDER        equ 0

Each part BOTTOM_BORDER, TOPBOTTOM_BORDER & NO_BORDER is initiate separately !

1.2 Use the following parameters :
----------------------------------

a) Pattern :
------------
It allows to fill the screens of the plan you want, for example:
PATTERN          equ $FFFF0000
Fills the bottom of the screen with the color of the palette number 6.

By default, it must be initialized as follows:
PATTERN          equ $0
For screens are properly cleared on 4 plans.

b) Screen used :
----------------
You can set parameter NB_OF_SCREEN to use one (option ONE_SCREEN activated) or two screens (option TWO_SCREENS activated) in your demo. Defaut set with physical and logical screens which avoids flickering effects between them.

c) Time Cpu :
-------------
It allows you to see the time taken (PURPLE color) and the remaining time left in BLACK color pressed by right ALTERNATE key.
SEEMYVBL         equ 0

It's advisable to set it to "1" when the program is over to release...

d) Errors systems :
-------------------
Used to retrieve the type of error and displayed it by a color code.
ERROR_SYS        equ 0
The program does not left right.

It's advisable to set it to "1" when the program is finished and ready to release...

Source code from Micka�l Pointier - http://www.defence-force.com

e) Fading :
-----------
Toggles the color white to black from the GEM desktop background color.
FADE_INTRO equ 1

f) Test the STE hardware :
--------------------------
Allows you to detect if you are on a SITE, otherwise you exit the program.
TEST_STE         equ 1

g) Top compatibility !
----------------------
I added the compatibility mode STF for STE-MSTE-TT-FALCON hardware.
STF_INITS         equ 0

Source code from Arnaud Carr� - http://leonard.oxg.free.fr/SainT/saint.html

h) BLITTER
----------
Launch the Blitter and permit to synchronize the Blitter with the VBL.
Add this macro SyncBlitterToRestart to your code after calling the Blitter.
Bonus: saves screen features following use of Blitter. (Shifting and Modulo)

i) Timer rules
--------------
If you want to use timers like A-B-C-D you can clear all timer at the beginning.
CLEAN_TIMERS     equ 1

Also allows you to synchronize effects in the main loop zone.

2 / Key Features :
==================
Assembler control options for compilating : 
- Case Sensitivity with upper or low character,
- No mode Debug activated,
- No Optimization code activated,
- No Warning display,
- No Extend Debug mode activated in the final program.
Memory allocation for the program.
Performance :
* Management of the keyboard buffer,
* Management multiboot for compatibility between the range computers : ST / STF / STD / MSTF / STE / MSTE / TT / Falcon,
* The overscans are stable across all machines and monitor according to the type of music used like MaxYMiser. (There is no crash but a stabilization problem !)
Safety :
* Clears the BSS part before initialize
* Backup / Restore all system data,
* Management of screens :
 - Established in BSS at the end of the program,
 - Full compliance on STE / MSTE
 - 2 screens : logical & physical
 - Sizing screen for the type of overscan used
 - Autofill at the creation of screen
* Hijack of Exceptions,
* Return the status of the stack at the end.

3 / How do I add the code ?
===========================
To implement the code inside the template:
a) You must select the type of OVERSCAN used, we use the default parameter NO_BORDER,
b) Implement the code called in the main loop, starting at line 118,
c) Added your routines from line 619,
d) Added data in the DATA section from line 631,
e) Added bootable data in the BSS section from line 646.
Timer option :
--------------
a) Add a routine HBL with the VBL: we must add the initialization Timers and calls the HBL between lines 471,
b) You can add code to the VBL from line 290,
c) Declare the routine code from HBL line 318.

4 / Examples :
==============

4.1 example.LZ7 :
-----------------
Use the compactor LZ7 version 1.3 in the program and data usage bootable. (BSS part)

4.2 example.SPU :
-----------------
Image display Spectrum 512/4096 colors.

4.3 example.STE :
-----------------
Using the blitter (STE test) and display more digits using the overscan down.

4.4 example.STF :
-----------------
Using a Timer to display rasters with a scrolling 8*8 1 plan.

5 / Finally:
===============
And attached files with :
- DEVPACK 2.25fr to compile the ASM code + Monst for debugging
- NEOCHROME 2.24 for cutting image and use of the pallet,
- LZ77-13.TTP when using file LZ7.

Voila ! Voila!

Fr�d�ric Sagez aka Zorro 2^NoExtra.

Update the 20/01/2024.
