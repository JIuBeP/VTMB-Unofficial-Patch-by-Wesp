@echo off
title Java Tools Launcher
setlocal ENABLEEXTENSIONS
if "%~2"=="" exit

:vars
pushd "%~dp0..\.."
set MsgBox="%cd%\assets\msgbox.exe"
set JarFile="%~dp0%~2"

:checkfiles
for %%m in (%JarFile% %MsgBox%) do (
if not exist "%%~m" (
	echo>>"..\sdk_errors.log" [%date% %time%] Java_Run error: Missing "%%~m" file.
	exit
))

:changeworkdir
if exist "GameCfg.ini" (
	for /f "usebackq delims== tokens=1,*" %%a in ("GameCfg.ini") do (
	if /i "%%~a"=="ModDir" (
		if exist "%%~b\maps\" (pushd "%%~b\maps\") else (
		if exist "%%~b\" (pushd "%%~b\") )
	))
) else (
	if exist "..\Vampire\maps\" (
	pushd "..\Vampire\maps\") else (pushd "..\")
)

:checkjava
if not defined JAVA_HOME (
	set JAVA_HOME=null
)
for %%r in (
	"%SystemRoot%\system32"
	"%SystemRoot%\syswow64"
	"%SystemRoot%\sysnative"
) do (
	if exist "%%~r\javaw.exe" (
		start /b "java" "%%~r\javaw.exe" %1 %JarFile% %3 %4 %5 %6 %7 %8 %9
		exit
	)
)
for /d %%p in (
	"%JAVA_HOME%"
	"%ProgramFiles%\Java\jre*"
	"%ProgramW6432%\Java\jre*"
) do (
	if exist "%%~p\bin\javaw.exe" (
		start /b "java" "%%~p\bin\javaw.exe" %1 %JarFile% %3 %4 %5 %6 %7 %8 %9
		exit
	)
)

:ifnotfound
%MsgBox% Java Runtime Environment must be installed on your system to run this program. Would you like to download and install it now? /c:Error /t:MB_ICONSTOP,MB_YESNO

if "%ErrorLevel%"=="6" (start "url" "http://www.java.com/download")
exit
