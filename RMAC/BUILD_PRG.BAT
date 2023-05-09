@ECHO OFF
@CLS
REM ---------------------------------------
REM -*- NOEXTRA PROGRAM COMPRESSION KIT -*-
REM ---------------------------------------

SET NAME=Intro_46
SET NAMEASMFILE=%NAME%.S
SET NAMEPRGFILE=%NAME%.PRG
SET NAMETOSFILE=%NAME%.TOS
SET NAMEERRFILE=%NAME%.ERR
SET NAMETXTFILE=%NAME%.ASM

del %NAMETOSFILE% 2>NUL
del %NAMETXTFILE% 2>NUL
del %NAMEERRFILE% 2>NUL

SET FOLDER-BIN=.\_bin\

SET RMAC=%FOLDER-BIN%rmac-2.2.7-win64.exe
SET OPTIONS=-px -v -s -m68000 -l%NAMETXTFILE% -e%NAMEERRFILE%

::
:: http://rmac.is-slick.com/manual/rmac.html#the-command-line
::
:: -px  -> Generate executable with extended debug symbols
:: -v   -> Exports the list of all the sections
:: -s   -> Warns about non optimized jumps
:: -m   -> Switch CPU type
::

ECHO -*- NOEXTRA ASSEMBLER PROGRAM COMPILATION KIT -*-
ECHO -------------------------------- ASSEMBLE -------------------------------
ECHO %RMAC% %OPTIONS% %NAMEASMFILE%
ECHO -------------------------------------------------------------------------
%RMAC% %OPTIONS% %NAMEASMFILE%
IF ERRORLEVEL 1 GOTO :Error_label
ECHO ------------------------------ TEST ISSUES ------------------------------
IF EXIST %NAMEERRFILE% GOTO :Error_label
ECHO --------------------------------- DONE! ---------------------------------
GOTO :End_label

:Error_label
ECHO -------------------------------- ERROR(S) -------------------------------
TYPE %NAMEERRFILE%
PAUSE

:End_label
@ECHO ON