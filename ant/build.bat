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
echo webfolder=%1
echo %ANT_HOME%
call %ANT_HOME%\bin\ant.bat -Dwebfolder=%1
pause

rem ----- Restore ANT_HOME and ANT_OPTS
set ANT_HOME=%OLD_ANT_HOME%
set OLD_ANT_HOME=

rem ----- Restore CLASSPATH
set CLASSPATH=%OLD_CLASSPATH%
set OLD_CLASSPATH=

