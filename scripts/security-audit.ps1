# Security audit — 0E3 repos
# Usage: .\scripts\security-audit.ps1 [repo-path]
param(
  [string]$RepoPath = "."
)

$ErrorActionPreference = "Continue"
Push-Location $RepoPath

Write-Host "=== 0E3 Security Audit ===" -ForegroundColor Cyan
Write-Host "Repo: $(Get-Location)" -ForegroundColor Gray
Write-Host ""

$patterns = @(
  '\.env$',
  'google-services\.json$',
  'serviceAccount',
  '\.pem$',
  '\.key$',
  'sk_live',
  'sk_test',
  'APP_USR-',
  'TEST-[a-f0-9]{20,}'
)

$tracked = git ls-files 2>$null
if (-not $tracked) {
  Write-Host "Not a git repository or no tracked files." -ForegroundColor Yellow
  Pop-Location
  exit 1
}

$issues = @()
foreach ($p in $patterns) {
  $matches = $tracked | Select-String -Pattern $p
  if ($matches) {
    $issues += $matches
  }
}

if ($issues.Count -eq 0) {
  Write-Host "[OK] No sensitive patterns in tracked files." -ForegroundColor Green
} else {
  Write-Host "[FAIL] Sensitive patterns in tracked files:" -ForegroundColor Red
  $issues | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
}

$staged = git diff --cached 2>$null
if ($staged) {
  $diffHits = $staged | Select-String -Pattern 'APP_USR-|sk_live|sk_test|BEGIN (RSA )?PRIVATE KEY'
  if ($diffHits) {
    Write-Host "[FAIL] Secrets in staged diff:" -ForegroundColor Red
    $diffHits | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
  } else {
    Write-Host "[OK] No secrets in staged diff." -ForegroundColor Green
  }
} else {
  Write-Host "[OK] No staged changes." -ForegroundColor Green
}

Pop-Location
exit $(if ($issues.Count -gt 0) { 1 } else { 0 })
