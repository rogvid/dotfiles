# Attach the YubiKey (1050:0407) to WSL with usbipd-win. Run from Windows.
# Once per machine, from an admin prompt, share it first: usbipd bind --busid <busid>
$line = usbipd list | Select-String "1050:0407" | Select-Object -First 1

if (-not $line) {
    Write-Host "YubiKey not found."
    exit 1
}

$yubiKeyBusId = $line.Line.Split()[0]

if ($line.Line -match "Attached") {
    Write-Host "YubiKey is already attached to WSL with busid $yubiKeyBusId."
    exit 0
}

if ($line.Line -notmatch "Shared") {
    Write-Host "YubiKey is not shared yet. From an admin prompt run: usbipd bind --busid $yubiKeyBusId"
    exit 1
}

usbipd attach --wsl --busid $yubiKeyBusId
if ($LASTEXITCODE -ne 0) {
    Write-Host "Attaching the YubiKey with busid $yubiKeyBusId failed, see usbipd's error above."
    exit $LASTEXITCODE
}

Write-Host "YubiKey attached to WSL with busid $yubiKeyBusId."
