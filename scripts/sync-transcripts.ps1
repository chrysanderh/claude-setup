# Sync Claude Code transcripts to Google Drive
$source = "$HOME\.claude\projects"
$dest = "$env:AGENT_OUTPUT_DIR\transcripts"

if (-not (Test-Path $dest)) {
    New-Item -ItemType Directory -Path $dest -Force | Out-Null
}

Get-ChildItem -Path $source -Recurse -Filter "*.jsonl" | ForEach-Object {
    $timestamp = $_.LastWriteTime.ToString("yyyyMMdd_HHmmss")
    $newName = "${timestamp}_$($_.BaseName).jsonl"
    $target = Join-Path $dest $newName

    if (-not (Test-Path $target)) {
        Copy-Item $_.FullName $target
        Write-Host "Synced: $newName"
    }
}

Write-Host "Transcript sync complete."