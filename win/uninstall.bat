 @echo off 

 REM All praise BAT files
 REM 
 REM Kalabox Uninstaller Script.
 REM 
 REM Copyright (C) 2014 Kalamuna LLC
 REM 
 REM This file also contains a modified VirtualBox uninstallers.
 REM 
 REM 

 REM Powershell.exe -executionpolicy remotesigned -noprofile -command "&{Start-Process powershell -ArgumentList ' -noprofile -file \"%~dp0uninstall.ps1\"' -verb RunAs}"
 PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '%~dp0uninstall.ps1'";

 PAUSE
