REM - NOEXTRA ASSEMBLER PROGRAM COMPILATION KIT -
@CLS
@ECHO OFF

SET NAMEASMFILE=Intro_46.S
SET NAMEPRGFILE=Intro_46.PRG
SET NAMEERRFILE=Intro_46.ERR
SET NAMETXTFILE=Intro_46.ASM

del %NAMEPRGFILE% 2>NUL
del %NAMETXTFILE% 2>NUL
del %NAMEERRFILE% 2>NUL

SET RMAC=rmac-2.2.7-win64.exe
SET OPTIONS=-px -v -s -m68000 -l%NAMETXTFILE% -e%NAMEERRFILE%

::
:: http://rmac.is-slick.com/manual/rmac.html#the-command-line
::
:: -px  -> Generate executable with extended debug symbols
:: -v   -> Exports the list of all the sections
:: -s   -> Warns about non optimized jumps
:: -m   -> Switch CPU type
::

ECHO ----------------------- ASSEMBLE ----------------------
%RMAC% %OPTIONS% %NAMEASMFILE%
IF ERRORLEVEL 1 GOTO :Error_label
ECHO ------------------------- DONE! -----------------------
PAUSE
GOTO :End_label

:Error_label
ECHO ------------------------ ERROR!?!----------------------
TYPE %NAMEERRFILE%
PAUSE
GOTO :End_label


:End_label
@CLS
@ECHO ON

