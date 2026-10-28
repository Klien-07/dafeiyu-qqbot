# 大肥鱼 NapCat 守护脚本
# 每 20 分钟检查一次：QQ 进程是否存活、NapCat 是否已连上 AstrBot(6199)
# 异常时自动杀掉残留 QQ 并以快速登录方式重新注入启动 NapCat

$ErrorActionPreference = 'SilentlyContinue'

# 登录 QQ 号从本地文件读取（不进版本库）：同目录新建 watchdog-account.local.txt，内容为一行 QQ 号
$account    = (Get-Content (Join-Path $PSScriptRoot 'watchdog-account.local.txt') -Raw).Trim()
$root       = $PSScriptRoot
$napcatDir  = Join-Path $root 'napcat'
$logFile    = Join-Path $root 'watchdog.log'
$intervalSec = 1200   # 20 分钟

function Write-Log([string]$msg) {
    "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  $msg" | Add-Content -Path $logFile -Encoding UTF8
}

# 单实例保护：避免计划任务和手动启动同时跑两份守护
$mutex = New-Object System.Threading.Mutex($false, 'NapCatWatcher_Dafeiyu')
if (-not $mutex.WaitOne(0)) {
    Write-Host "已有守护实例在运行，本次退出"
    exit
}

function Test-OneBotConnected {
    $lines = netstat -ano | Select-String ':6199'
    foreach ($l in $lines) {
        if ($l -match 'ESTABLISHED') { return $true }
    }
    return $false
}

Write-Log "守护脚本启动（间隔 ${intervalSec}s，账号 $account）"

while ($true) {
    $qq   = Get-Process -Name 'QQ' -ErrorAction SilentlyContinue
    $conn = Test-OneBotConnected

    if (-not $qq -or -not $conn) {
        # AstrBot 没开着就别动 QQ，否则会把好好的登录态杀掉
        if (-not (netstat -ano | Select-String ':6199.*LISTENING')) {
            Write-Log "AstrBot(6199) 未监听，跳过本次检查（先启动 AstrBot）"
            Start-Sleep -Seconds $intervalSec
            continue
        }
        Write-Log "异常：QQ进程=$([bool]$qq)，OneBot连接=$conn -> 开始重启 NapCat"

        taskkill /F /IM QQ.exe /T | Out-Null
        taskkill /F /IM NapCatWinBootMain.exe | Out-Null
        Start-Sleep -Seconds 5

        Start-Process -FilePath (Join-Path $napcatDir 'launcher.bat') `
                      -ArgumentList $account `
                      -WorkingDirectory $napcatDir `
                      -WindowStyle Minimized

        Write-Log "已触发 launcher.bat $account，等待 90 秒后复查"
        Start-Sleep -Seconds 90

        if (Test-OneBotConnected) {
            Write-Log "恢复成功：6199 已 ESTABLISHED"
        } else {
            Write-Log "恢复未成功：可能需要手动扫码登录"
        }
    }
    else {
        Write-Log "正常"
    }

    Start-Sleep -Seconds $intervalSec
}
