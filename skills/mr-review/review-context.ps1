# Gathers everything needed to review the last N commits in the current worktree.
# Output is injected into the skill prompt before Claude sees it.

# Native commands must not throw on non-zero exit; we check $LASTEXITCODE ourselves.
if (Get-Variable -Name PSNativeCommandUseErrorActionPreference -ErrorAction SilentlyContinue) {
    $PSNativeCommandUseErrorActionPreference = $false
}
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}

# Accept "3", "last 3 commits", or nothing (defaults to 5).
$N = 5
$match = [regex]::Match(($args -join ' '), '\d+')
if ($match.Success) { $N = [int]$match.Value }

$root   = git rev-parse --show-toplevel
$branch = git rev-parse --abbrev-ref HEAD

$base = git rev-parse --verify --quiet "HEAD~$N"
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($base)) {
    $base = git rev-list --max-parents=0 HEAD | Select-Object -Last 1
    "NOTE: branch has fewer than $N commits; reviewing from the root commit."
}

"Worktree:  $root"
"Branch:    $branch"
"Range:     $base..HEAD (last $N commits)"
""

"=== Commits ==="
git log --no-merges --format='%h  %ad  %an  %s' --date=short "$base..HEAD"
""

"=== Files changed ==="
git diff --stat "$base..HEAD"
""

# Guard against dumping a 20k-line diff into context.
$changed = 0
foreach ($line in (git diff --numstat "$base..HEAD")) {
    $parts = $line -split "`t"
    if ($parts.Count -ge 2) {
        $added = 0; $removed = 0
        [void][int]::TryParse($parts[0], [ref]$added)
        [void][int]::TryParse($parts[1], [ref]$removed)
        $changed += $added + $removed
    }
}

if ($changed -gt 4000) {
    "NOTE: diff is $changed changed lines. Only the stat is shown above."
    "Run targeted 'git diff $base..HEAD -- <path>' on the files that matter."
} else {
    "=== Diff ($base..HEAD) ==="
    git diff --unified=5 "$base..HEAD"
}
""

"=== Merge request ==="
if (Get-Command glab -ErrorAction SilentlyContinue) {
    $mr = glab mr view 2>$null
    if ($LASTEXITCODE -eq 0 -and $mr) { $mr } else { "No MR found for branch $branch." }
} else {
    "glab CLI not installed."
}
