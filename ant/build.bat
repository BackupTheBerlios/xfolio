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
set WEBFOLDER=%1
:doneWebfolder
echo webfolder=%WEBFOLDER%


echo %ANT_HOME%
call %ANT_HOME%\bin\ant.bat -Dwebfolder=%WEBFOLDER%
pause

rem ----- Restore ANT_HOME and ANT_OPTS
set ANT_HOME=%OLD_ANT_HOME%
set OLD_ANT_HOME=

rem ----- Restore CLASSPATH and used avriables
set CLASSPATH=%OLD_CLASSPATH%
set OLD_CLASSPATH=
set WEBFOLDER=

