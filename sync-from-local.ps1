# Nova dashboard sync -- pulls latest from origin, copies any new/changed
# Nova/Dashboard files into the clone, commits + pushes if anything changed.
#
# Designed to be safe on no-op (silent success), idempotent, and runnable
# from both the SessionEnd hook AND the daily scheduled task.
#
# Logs to ~/.claude/logs/nova-dashboard-sync.log

$ErrorActionPreference = "Continue"

$REPO   = "C:\Users\kimkl\Documents\Claude\nova-dashboard"
$SRCDIR = "C:\Users\kimkl\OneDrive\Documents\Claude\Nova\Dashboard"
$LOGDIR = "C:\Users\kimkl\.claude\logs"
$LOGFILE = "$LOGDIR\nova-dashboard-sync.log"

if (-not (Test-Path $LOGDIR)) { New-Item -ItemType Directory -Path $LOGDIR -Force | Out-Null }

function Write-SyncLog($msg) {
  $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
  "$ts $msg" | Out-File -FilePath $LOGFILE -Append -Encoding utf8
}

try {
  $caller = "manual"
  if ($args.Count -gt 0 -and $args[0]) { $caller = $args[0] }
  Write-SyncLog "=== sync start (caller=$caller) ==="

  if (-not (Test-Path $REPO))   { Write-SyncLog "ERROR: repo missing at $REPO"; exit 1 }
  if (-not (Test-Path $SRCDIR)) { Write-SyncLog "ERROR: source missing at $SRCDIR"; exit 1 }

  Set-Location $REPO

  # 1. Pull latest so we don't push on a stale base
  $pullOut = cmd /c "git pull --ff-only origin main 2>&1"
  Write-SyncLog "pull (exit=$LASTEXITCODE): $($pullOut -join ' | ')"
  if ($LASTEXITCODE -ne 0) { Write-SyncLog "pull failed -- aborting"; exit 1 }

  # 2. Copy every .html, .pdf, .png from local Nova/Dashboard into repo root.
  #    Mirror only -- don't delete repo files we didn't generate.
  $copied = 0
  $allowedExt = @(".html",".pdf",".png",".jpg",".jpeg",".svg",".css",".js")
  Get-ChildItem -Path $SRCDIR -File -Recurse | Where-Object {
    $allowedExt -contains $_.Extension.ToLower()
  } | ForEach-Object {
    $rel = $_.FullName.Substring($SRCDIR.Length).TrimStart('\','/')
    $dst = Join-Path $REPO $rel
    $dstDir = Split-Path $dst -Parent
    if (-not (Test-Path $dstDir)) { New-Item -ItemType Directory -Path $dstDir -Force | Out-Null }

    $needsCopy = $true
    if (Test-Path $dst) {
      $srcHash = (Get-FileHash $_.FullName -Algorithm SHA256).Hash
      $dstHash = (Get-FileHash $dst -Algorithm SHA256).Hash
      if ($srcHash -eq $dstHash) { $needsCopy = $false }
    }

    # GUARD: don't let a smaller local file clobber a larger published file.
    # Trips on the failure mode that wiped the rich-tiles index.html on first
    # sync (local was a 341-line stripped version, repo had 800-line tiles).
    # Threshold: 30% shrink or more is rejected; otherwise allowed.
    if ($needsCopy -and (Test-Path $dst)) {
      $srcLen = $_.Length
      $dstLen = (Get-Item $dst).Length
      if ($dstLen -gt 0 -and $srcLen -lt ($dstLen * 0.7)) {
        Write-SyncLog "  SKIP (shrink-guard): $rel local=$srcLen bytes vs repo=$dstLen bytes (<70%) -- not overwriting"
        $needsCopy = $false
      }
    }

    if ($needsCopy) {
      Copy-Item -Path $_.FullName -Destination $dst -Force
      $copied++
      Write-SyncLog "  copied: $rel"
    }
  }

  # 3. Stage + check for changes
  cmd /c "git add -A 2>&1" | Out-Null
  $diff = cmd /c "git diff --cached --shortstat 2>&1"
  if (-not $diff -or [string]::IsNullOrWhiteSpace(($diff -join ''))) {
    Write-SyncLog "no changes to commit (copied=$copied) -- sync end"
    exit 0
  }
  Write-SyncLog "diff: $($diff -join ' | ')"

  # 4. Commit + push
  $msg = "Nova sync $(Get-Date -Format 'yyyy-MM-dd HH:mm') AEST ($caller)"
  $commitOut = cmd /c "git -c user.email=nova@brisbanehifu.local -c user.name=Nova commit -m `"$msg`" 2>&1"
  Write-SyncLog "commit (exit=$LASTEXITCODE): $($commitOut -join ' | ')"
  if ($LASTEXITCODE -ne 0) { Write-SyncLog "commit failed -- aborting"; exit 1 }
  $pushOut = cmd /c "git push origin main 2>&1"
  Write-SyncLog "push (exit=$LASTEXITCODE): $($pushOut -join ' | ')"
  if ($LASTEXITCODE -ne 0) { Write-SyncLog "push failed"; exit 1 }

  Write-SyncLog "=== sync end OK ==="
  exit 0
}
catch {
  Write-SyncLog "ERROR: $($_.Exception.Message)"
  Write-SyncLog $_.ScriptStackTrace
  exit 1
}
