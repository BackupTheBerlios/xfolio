@echo off
rem this script start the xfolio-ant with src (the webfolder) as first argument
rem good idea is to use it as a shorcut where you are working, and drag and drop
rem your webfolder on it to make it transformed

rem ----- Ignore system CLASSPATH variable
set OLD_CLASSPATH=%CLASSPATH%
set CLASSPATH=

rem ----- Use Ant shipped with Cocoon. Ignore installed in the system Ant
set OLD_ANT_HOME=%ANT_HOME%
set ANT_HOME=.

rem ----- process first argument as webfolder or default
set WEBFOLDER=../docs
if ""%1""=="""" goto doneWebfolder

:: first argument exist as a folder, may be used as a source for transfolio
if exist "%1" goto setWebfolder
:: bad argument as a path, maybe a target
goto doneWebfolder

:setWebfolder
set WEBFOLDER=%1
:: don't forget to suppress this comand line argument, to not pass it to ant shell
shift


:doneWebfolder
echo webfolder=%WEBFOLDER%


set CMD=%ANT_HOME%\bin\ant.bat -Dwebfolder=%WEBFOLDER% %1 %2 %3 %4 %5 %6 %7 %8 %9
echo %CMD%
:: execute
%CMD%
pause

rem ----- Restore ANT_HOME and ANT_OPTS
set ANT_HOME=%OLD_ANT_HOME%
set OLD_ANT_HOME=

rem ----- Restore CLASSPATH and used avriables
set CLASSPATH=%OLD_CLASSPATH%
set OLD_CLASSPATH=
set WEBFOLDER=
set CMD=

