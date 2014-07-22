 @echo off 

 REM All praise BAT files
 REM
 REM Kalabox Server Install Script.
 REM
 REM Copyright (C) 2014 Kalamuna LLC
 REM
 REM This file is basically just a wrapper around a powershell script that will 
 REM install the underlying dependencies required to run kalastack-docker.
 REM

 REM PowerShell -ExecutionPolicy Bypass -NoProfile -Command "&{Start-Process PowerShell -Verb RunAs -WindowStyle Hidden -ArgumentList '-noprofile -noexit -elevated -file \"%~dp0setup.ps1\"'}"
 PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '%~dp0setup.ps1'";

 PAUSE
