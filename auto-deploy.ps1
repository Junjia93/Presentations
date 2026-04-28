# Auto-deploy: watches presentations folder and pushes to GitHub automatically

$folder = "C:\Users\LowJunJia\presentations"
$logFile = "$folder\auto-deploy.log"

function Write-Log($msg) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $logFile -Value "$timestamp - $msg"
    Write-Host "$timestamp - $msg"
}

Write-Log "Auto-deploy started. Watching: $folder"

$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $folder
$watcher.Filter = "*.html"
$watcher.IncludeSubdirectories = $false
$watcher.EnableRaisingEvents = $true

$action = {
    $name = $Event.SourceEventArgs.Name
    $changeType = $Event.SourceEventArgs.ChangeType
    Start-Sleep -Seconds 2
    Set-Location $using:folder
    git add .
    git commit -m "Auto-deploy: $name ($changeType)"
    git push origin main
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $using:logFile -Value "$timestamp - Deployed: $name"
}

Register-ObjectEvent $watcher "Created" -Action $action | Out-Null
Register-ObjectEvent $watcher "Changed" -Action $action | Out-Null

Write-Log "Watching for HTML changes... (keep this window open)"

while ($true) { Start-Sleep -Seconds 10 }
