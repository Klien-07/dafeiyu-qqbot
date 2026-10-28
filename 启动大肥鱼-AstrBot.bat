@echo off
cd /d "%~dp0astrbot"
set PYTHONUTF8=1
set PYTHONIOENCODING=utf-8
set TMP=%~dp0tmp
set TEMP=%~dp0tmp

echo ============================================
echo   AstrBot starting
echo   WebUI : http://127.0.0.1:6185
echo   QQ WS : ws://127.0.0.1:6199/ws
echo   Close this window to stop AstrBot
echo ============================================
echo.

"%~dp0venv\Scripts\astrbot.exe" run
pause
