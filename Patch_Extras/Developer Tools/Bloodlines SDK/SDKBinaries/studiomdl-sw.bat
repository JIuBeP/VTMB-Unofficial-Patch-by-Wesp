@echo off
title StudioMDL compiler: Alien Swarm mode
rem CMD-wrapper for bugfixes and extra features!
setlocal ENABLEEXTENSIONS
set "PATH=%SystemRoot%\System32;%SystemRoot%;%SystemRoot%\System32\Wbem"
set "PATHEXT=.COM;.EXE;.BAT;.CMD;.VBS;.VBE;.JS;.JSE;.WSF;.WSH;.MSC"
chcp 850> nul
if "%~1"=="" (
	"%~dpn0.exe"
	pause> nul
	exit
)

:DefineVars
set "CwD=%Cd%"
pushd "%~dp0.."
if not defined ModDir (
set "ModDir=%Cd%\Vampire")
set "ModTmp=%~dp0assets"
set "SdkContent=%Cd%\SDKContent\VpkContent"
pushd "%~dp0"
set StudioMDL=studiomdl-sw.exe
set Formatter=studiovtmb49k.exe
set QCFile=
set ModelName=
set XModel=
set CmdLine=%*

:GetFixedQcPath
for %%m in (%*) do (
if /i "%%~xm"==".qc" (
	set "QCFile=%%~m"
	call :SetFixed QCPath "%%~dpm"
	if not exist "%%~m" (
	if exist "%CwD%\%%~nxm" (
		set "QCFile=%CwD%\%%~nxm"
		call :SetFixed QCPath "%CwD%"
	))
))
if not defined QCFile (
	echo Invalid commands: no QC file specified!
	goto Quit
) else if not exist "%QCFile%" (
	echo Wrong QC path specified: "%QCFile%"!
	goto Quit
)

:GetFixedModDir
if exist "GameCfg.ini" (
for /f "usebackq delims== tokens=1,*" %%a in ("GameCfg.ini") do (
	if /i "%%~a"=="ModDir" (if exist "%%~b\*" (set "%%~a=%%~b") )
))
if not exist "%ModDir%\" (
	if defined VProject (
	if exist "%VProject%\" (
		set "ModDir=%VProject%"
	))
)
if not exist "%ModDir%\" (
	echo Wrong mod directory specified: "%ModDir%"!
	goto Quit
)

:GetMdlFilePath
for /f "usebackq eol=/ tokens=1,*" %%a in ("%QCFile%") do (
if /i "%%~a"=="$ModelName" (if not "%%~b"=="" (
	if /i "%%~xb"==".mdl" call :SetFixed ModelName "models/%%~b!"
	if /i not "%%~xb"==".mdl" call :SetFixed ModelName "models/%%~b.mdl!"
)))
if not defined ModelName (
	echo Failed to get target MDL path from QC!
	goto Quit
) else set "ModelName=%ModelName:.mdl!=%"

:GetXModelFileName
rem TODO: Fix SMD names in QC to multi_word for crappy Formatter codding!
for /f "usebackq eol=/ tokens=1,2,*" %%a in ("%QCFile%") do (
	if /i "%%~a"=="studio" (if not "%%~b"=="" (
	for /f "delims=_{}" %%x in ("%%~nxb") do (
		if /i not "%%~x"=="%%~nxb" call :SetFixed XModel "%%~x"
	)))
	for %%m in ("$model" "$body") do (
	if /i "%%~a"=="%%~m" (if not "%%~c"=="" (
	for /f "delims=_{}" %%x in ("%%~nxc") do (
		if /i not "%%~x"=="%%~nxc" call :SetFixed XModel "%%~x"
	))))
)
if not defined XModel (
	echo Failed to get xModel chunk from QC. This is requirement!
	echo The reference SMD mesh must have 2+ chunks in name [1_2].
	goto Quit
)

:CreateMissingXModel
if not exist "%QCPath%\xmodel\" md "%QCPath%\xmodel"
for %%x in (mdl phy) do (if not exist "%QCPath%\xmodel\%XModel%.%%x" (
	if exist "%ModDir%\%ModelName%.%%x" copy /y "%ModDir%\%ModelName%.%%x" "%QCPath%\xmodel\%XModel%.%%x"> nul
	if exist "%SdkContent%\%ModelName%.%%x" copy /y "%SdkContent%\%ModelName%.%%x" "%QCPath%\xmodel\%XModel%.%%x"> nul
))
if not exist "%QCPath%\xmodel\%XModel%.mdl" (
	echo No skeleton model "%XModel%.mdl" specified inside of "%QCPath%\xmodel\"!
	echo Copy the skeleton MDL from the VtMB model here to be used in new model.
	goto Quit
)

:ParseCmdline
for %%l in (-game -mod -build) do (rem Strip mod lines:
if /i "%~1"=="%%~l" set CmdLine=%3 %4 %5 %6 %7 %8 %9)
for %%c in (%CmdLine%) do (rem Fix input QC file order:
if /i not "%%~xc"==".qc" call :FixCmdLine "%%~c")
if defined Params set CmdLine=%Params%
if not defined Params set CmdLine=
if not defined Params set Params=-None-

:ShowSummary
echo ---------------------
echo Project Dir: "%ModDir%"
echo Target MDL: "%ModelName%.mdl"
echo Skeleton Data: "xmodel\%XModel%.mdl"
echo Parameters: %Params%
echo ---------------------
for %%m in ("%ModTmp%" "%ModDir%") do (
del /f /q /a "%%~m\%ModelName%.*"> nul 2>&1)

:RunCompiler
echo Starting StudioMDL compiler...
echo ---------------------
call %StudioMDL% -game "%ModTmp%" -nop4 %CmdLine% "%QCFile%"
if not exist "%ModTmp%\%ModelName%.mdl" (goto CheckResults)
echo.

:ConvertModel
echo ---------------------
echo Starting MDL Formatter tool...
echo ---------------------
echo Converting model to VtMB format...
call %Formatter% dummy "%QCPath%/" "%ModDir%/" "%ModTmp%\%ModelName%.mdl"
if exist "%ModDir%\%ModelName%.mdl" (echo Converting success.)

:CheckResults
echo.
echo ---------------------
if exist "%ModDir%\%ModelName%.mdl" (
	echo Compiling model success.) else (
	echo An error occurred during compiling!
	echo See StudioMDL log above for details.
)
echo ---------------------

:Quit
echo.
if exist "%ModTmp%\models\" (
rd /s /q "%ModTmp%\models\" )
if /i "%~x1"==".qc" pause
exit



:FixCmdLine
if not defined Params (
set "Params=%~1") else (
set "Params=%Params% %~1")
exit /b

:SetFixed
set "FixVar=%~2"
:SetFixed_loop
	set "FixVar=%FixVar:/=\%"
	set "FixVar=%FixVar:\\=\%"
	if "%FixVar:~-1%"=="\" set "FixVar=%FixVar:~0,-1%"
	if "%FixVar:~0,1%"=="\" set "FixVar=%FixVar:~1%"
	if "%FixVar:~0,14%"=="models\models\" set "FixVar=%FixVar:~7%"
	if "%FixVar:~-1%"=="\" goto SetFixed_loop
	if "%FixVar:~0,1%"=="\" goto SetFixed_loop
	if not "%FixVar:\\=\%"=="%FixVar%" goto SetFixed_loop
set "%~1=%FixVar%"
exit /b