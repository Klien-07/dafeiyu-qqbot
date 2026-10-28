# 一键重启大肥鱼
# 用法：双击「一键重启大肥鱼.bat」即可（会自动申请管理员权限）
# 流程：清残留进程 → 删锁文件 → 启动 NapCat → 启动 AstrBot → 自检连接

$ErrorActionPreference = 'Continue'

# ===== 路径配置 =====
$root        = $PSScriptRoot
# 机器人 QQ 号从本地文件读取（不进版本库）：同目录新建 dafeiyu-account.local.txt，内容为一行 QQ 号
$account     = (Get-Content (Join-Path $PSScriptRoot 'dafeiyu-account.local.txt') -Raw).Trim()
$napcatDir   = Join-Path $root 'napcat'
$astrbotDir  = Join-Path $root 'astrbot'
$astrbotBat  = Join-Path $root '启动大肥鱼-AstrBot.bat'
$lockFile    = Join-Path $astrbotDir 'astrbot.lock'

# ===== 日志函数 =====
function Write-Step([string]$msg) { Write-Host "[步骤] $msg" -ForegroundColor Cyan }
function Write-OK([string]$msg)   { Write-Host "[ OK ] $msg" -ForegroundColor Green }
function Write-Warn2([string]$msg){ Write-Host "[警告] $msg" -ForegroundColor Yellow }
function Write-Err([string]$msg)  { Write-Host "[错误] $msg" -ForegroundColor Red }

# ===== 1. 管理员权限检查与提权 =====
Write-Step "检查管理员权限..."
$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Warn2 "未以管理员身份运行，正在提权（请在 UAC 窗口点\"是\"）..."
    Start-Process -FilePath "powershell.exe" -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}
Write-OK "已是管理员"

# ===== 2. 清理残留进程 =====
Write-Step "清理残留进程（astrbot / QQ / NapCatWinBootMain）..."
$killNames = @('astrbot','QQ','NapCatWinBootMain')
foreach ($n in $killNames) {
    Get-Process -Name $n -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Host "  终止 $($_.ProcessName) PID=$($_.Id)"
        Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
    }
}

# 只杀与大肥鱼相关的 python / node，避免误伤其他程序
Get-Process python -ErrorAction SilentlyContinue | Where-Object {
    $_.Path -and ($_.Path -like "*deepseek-harness*venv*")
} | ForEach-Object {
    Write-Host "  终止 python(大肥鱼) PID=$($_.Id)"
    Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
}

Get-Process node -ErrorAction SilentlyContinue | Where-Object {
    $_.Path -and ($_.Path -like "*napcat*")
} | ForEach-Object {
    Write-Host "  终止 node(NapCat) PID=$($_.Id)"
    Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
}

Start-Sleep -Seconds 3
Write-OK "进程清理完成"

# ===== 3. 删除 AstrBot 锁文件 =====
Write-Step "清理 AstrBot 锁文件..."
if (Test-Path $lockFile) {
    Remove-Item $lockFile -Force -ErrorAction SilentlyContinue
    if (-not (Test-Path $lockFile)) { Write-OK "锁文件已删除" }
    else { Write-Warn2 "锁文件仍在，可能被占用，请手动结束 astrbot 进程后再试" }
} else {
    Write-OK "无锁文件残留"
}

# ===== 4. 启动 NapCat（绕过 wt.exe 提权链，直接调 launcher.bat） =====
Write-Step "启动 NapCat（账号 $account）..."
$launcher = Join-Path $napcatDir 'launcher.bat'
if (-not (Test-Path $launcher)) {
    Write-Err "找不到 launcher.bat：$launcher"
    Read-Host "按回车退出"
    exit 1
}
Start-Process -FilePath "cmd.exe" `
              -ArgumentList "/c", "`"$launcher`" $account" `
              -WorkingDirectory $napcatDir
Write-OK "NapCat 启动命令已发出，等待 20 秒让 QQ 加载 DLL..."
Start-Sleep -Seconds 20

# ===== 5. 启动 AstrBot =====
Write-Step "启动 AstrBot..."
if (-not (Test-Path $astrbotBat)) {
    Write-Err "找不到启动脚本：$astrbotBat"
    Read-Host "按回车退出"
    exit 1
}
Start-Process -FilePath "cmd.exe" `
              -ArgumentList "/c", "`"$astrbotBat`"" `
              -WorkingDirectory $root
Write-OK "AstrBot 启动命令已发出，等待 15 秒..."
Start-Sleep -Seconds 15

# ===== 6. 自检连接状态 =====
Write-Step "自检连接状态..."
$astrbot = Get-Process astrbot -ErrorAction SilentlyContinue
$qq      = Get-Process QQ -ErrorAction SilentlyContinue
$established = netstat -ano | Select-String -Pattern '127\.0\.0\.1:\d+\s+127\.0\.0\.1:6199\s+ESTABLISHED'

Write-Host ""
if ($astrbot -and $qq -and $established) {
    Write-OK "🎉 大肥鱼满血复活！全链路正常"
    Write-Host "  AstrBot PID : $($astrbot.Id -join ',')" -ForegroundColor Gray
    Write-Host "  QQ 进程数   : $($qq.Count)" -ForegroundColor Gray
    Write-Host "  WebSocket   : 已 ESTABLISHED" -ForegroundColor Gray
    Write-Host "  AstrBot WebUI : http://127.0.0.1:6185" -ForegroundColor Gray
    Write-Host "  NapCat WebUI  : http://127.0.0.1:6099" -ForegroundColor Gray
} else {
    Write-Err "自检未通过，请查看上方日志："
    if (-not $astrbot) { Write-Host "  ❌ AstrBot 没起来" -ForegroundColor Red }
    if (-not $qq)      { Write-Host "  ❌ QQ 没起来" -ForegroundColor Red }
    if (-not $established) { Write-Host "  ❌ NapCat 没连上 AstrBot（6199 无 ESTABLISHED）" -ForegroundColor Red }
    Write-Warn2 "建议：去 NapCat WebUI（6099）扫码登录 QQ，或检查 launcher.bat 是否报错"
}
Write-Host ""
Read-Host "按回车关闭本窗口"
