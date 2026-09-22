# vim: set autoindent smartindent ts=4 sw=4 sts=4 noet filetype=ps1:

# Thin dispatcher: locates Git for Windows' bash.exe and hands off to the
# real refresh-dotfiles function in ~/.bashrc.d/refresh-dotfiles, the same
# one used from Git Bash/MSYS2. No refresh logic lives here.

function refresh-dotfiles {
    $bash = $null

    $gitCmd = Get-Command git.exe -ErrorAction SilentlyContinue
    if ($gitCmd) {
        $gitRoot = Split-Path -Parent (Split-Path -Parent $gitCmd.Source)
        $candidate = Join-Path $gitRoot 'bin\bash.exe'
        if (Test-Path -LiteralPath $candidate) {
            $bash = $candidate
        }
    }

    if (-not $bash) {
        $fallback = Get-Command bash.exe -ErrorAction SilentlyContinue |
            Where-Object { $_.Source -notmatch '\\System32\\' } |
            Select-Object -First 1
        if ($fallback) {
            $bash = $fallback.Source
        }
    }

    if (-not $bash) {
        Write-Error "refresh-dotfiles: Git for Windows not found (no git.exe on PATH, no usable bash.exe). Install Git for Windows and try again."
        return
    }

    & $bash -lc 'source ~/.bashrc.d/refresh-dotfiles && refresh-dotfiles "$@"' 'refresh-dotfiles' $args
}
