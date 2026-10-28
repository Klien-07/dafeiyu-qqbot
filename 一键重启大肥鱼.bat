@echo off
REM ============================================================
REM  DaFeiYu Full Restart (NapCat + AstrBot)
REM  Double-click to run. UAC will prompt - click Yes.
REM  Auto: clean leftovers, start NapCat, start AstrBot, verify.
REM ============================================================
echo.
echo   DaFeiYu Full Restart (NapCat + AstrBot)
echo   UAC will prompt - click Yes
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0restart-dafeiyu.ps1"
exit /b %ERRORLEVEL%
