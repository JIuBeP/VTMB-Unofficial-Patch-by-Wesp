@echo off
setlocal ENABLEEXTENSIONS

pushd "%~dp0.."
del /f /s /q /a *.rf
del /f /s /q /a *.vdf
del /f /s /q /a *.err
del /f /s /q /a *.log
del /f /a /q ..\*.log
del /f /s /q GameCfg.ini
del /f /q "tools\Dupe Finder\*.lst"
del /f /q "tools\Crowbar\Proj*.ini"
if not exist ..\Vampire.exe rd /s /q ..\Vampire

pushd "%~dp0"
copy /y cmdseq.init ..\cmdseq.wc
rd /s /q materials models sound

exit /b