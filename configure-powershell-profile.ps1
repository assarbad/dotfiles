# vim: set autoindent smartindent ts=4 sw=4 sts=4 noet filetype=ps1:

# This script drives the 'profile.link' goal for the GNUmakefile (Windows branch).
# Idempotently ensures $PROFILE dot-sources the installed refresh-dotfiles
# wrapper, without touching any other content already in the user's profile.

$snippetTarget = Join-Path $HOME '.config\powershell\refresh-dotfiles.ps1'
$sourceLine = ". `"$snippetTarget`""

$profileDir = Split-Path -Parent $PROFILE
if (-not (Test-Path -LiteralPath $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}
if (-not (Test-Path -LiteralPath $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
}

$existing = Get-Content -LiteralPath $PROFILE -ErrorAction SilentlyContinue
$alreadyLinked = $existing | Where-Object { $_ -like "*$snippetTarget*" }

if (-not $alreadyLinked) {
    Add-Content -LiteralPath $PROFILE -Value $sourceLine
    Write-Host "[INFO] Added refresh-dotfiles dot-source to $PROFILE"
} else {
    Write-Host "[INFO] $PROFILE already sources refresh-dotfiles"
}
