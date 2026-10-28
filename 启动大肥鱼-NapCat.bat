@echo off
chcp 65001 >nul
cd /d "%~dp0"

net session >nul 2>&1
if errorlevel 1 (
    echo ============================================
    echo   正在申请管理员权限，请在 UAC 窗口点"是"
    echo ============================================
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

echo 已获得管理员权限。
echo 关闭 QQ 自动更新（阻止 QQ 写入版本目录）...
icacls "C:\Program Files\Tencent\QQNT\versions" /deny "Users:(OI)(CI)(W)" >nul 2>&1

echo.
echo 启动守护脚本：每 20 分钟检查一次，掉线自动重连
echo 需要停止守护时，直接关闭本窗口即可。
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0napcat-watchdog.ps1"
pause
