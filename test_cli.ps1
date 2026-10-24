# PowerShell CLI with 5-Second Countdown and Double-Beep (BEEP-BEEP)
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  SMART ITEM FINDER - CLI (5S DELAY + 2x BEEPS)   " -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan

$comPort = Read-Host "Enter ESP32 COM Port (e.g. COM3)"
if ([string]::IsNullOrWhiteSpace($comPort)) {
    $comPort = "COM3"
}

try {
    $port = New-Object System.IO.Ports.SerialPort $comPort, 115200, None, 8, one
    $port.Open()
    Write-Host "`n[✓] Connected to $comPort at 115200 baud!" -ForegroundColor Green
    Write-Host "Press [ENTER] for 5s countdown and 2x Beeps. Type 'q' to quit.`n" -ForegroundColor Yellow

    while ($true) {
        $key = Read-Host "Command [Press ENTER for 2x BEEPS]"
        if ($key -eq "q" -or $key -eq "quit") {
            break
        }
        
        Write-Host "`n⏳ [PREPARE HANDS] Triggering in 5 seconds... Hold your probe wires in place!" -ForegroundColor Yellow
        for ($i = 5; $i -gt 0; $i--) {
            Write-Host "   ⏱️  $i..." -NoNewline -ForegroundColor Cyan
            Start-Sleep -Seconds 1
        }
        Write-Host " 💥 >>> STARTING DOUBLE-BEEP SEQUENCE! <<<`n" -ForegroundColor Magenta

        # Pulse 1: Beep 1
        Write-Host " 🔊 [PULSE 1] >>> BEEP #1..." -ForegroundColor Green
        $port.WriteLine("find`n")
        Start-Sleep -Milliseconds 1300

        # Pause
        Write-Host " ⏸️ [PAUSE]   >>> SILENCE (0.5s)..." -ForegroundColor DarkGray
        $port.WriteLine("stop`n")
        Start-Sleep -Milliseconds 500

        # Pulse 2: Beep 2
        Write-Host " 🔊 [PULSE 2] >>> BEEP #2..." -ForegroundColor Green
        $port.WriteLine("find`n")
        Start-Sleep -Milliseconds 1300

        # Stop
        Write-Host " 🛑 [STOP]    >>> Finished!`n" -ForegroundColor Yellow
        $port.WriteLine("stop`n")

        Start-Sleep -Milliseconds 300
        while ($port.BytesToRead -gt 0) {
            $msg = $port.ReadLine()
            Write-Host " [ESP32] $msg" -ForegroundColor Gray
        }
        Write-Host ""
    }
    $port.Close()
} catch {
    Write-Host "`n[!] Error connecting to $comPort : $_" -ForegroundColor Red
}
