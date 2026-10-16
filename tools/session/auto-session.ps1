# Run Claude Code sessions back to back, each a fresh session, until the handoff says stop.
#
# Usage:  pwsh tools\session\auto-session.ps1           loop: start the next session, and when
#                                                     you leave it (/exit) start the one after
#         pwsh tools\session\auto-session.ps1 -Once     start one session and stop
#         pwsh tools\session\auto-session.ps1 -DryRun   show what would start, start nothing
#
# Same rules as auto-session.sh: reads production/session-handoff.md (Next prompt,
# Next machine, Auto-continue, Updated) and sends the first ``` block of
# production/session-prompts/session-<id>-*.md. Stops on Auto-continue "no", on the
# wrong machine, or when a session ends without updating the handoff.
param(
    [switch] $Once,
    [switch] $DryRun
)
$ErrorActionPreference = 'Stop'
if ($PSVersionTable.PSVersion -lt [Version]'7.3') {
    Write-Error "PowerShell 7.3+ required (run with 'pwsh'); found $($PSVersionTable.PSVersion)"
    exit 1
}
$PSNativeCommandArgumentPassing = 'Standard'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location $root
$handoff = Join-Path $root 'production\session-handoff.md'
$prompts = Join-Path $root 'production\session-prompts'
$thisMachine = if ($IsWindows) { 'windows' } else { 'linux' }

function Get-Field([string] $Name) {
    foreach ($line in Get-Content -LiteralPath $handoff -Encoding UTF8) {
        if ($line -match "^- \*\*$([regex]::Escape($Name)):\*\* *(.*)$") { return $Matches[1].Trim() }
    }
    return ''
}
function First-Word([string] $s) { ($s -split '\s+')[0] }

while ($true) {
    if (-not (Test-Path $handoff)) { Write-Error "$handoff not found"; exit 1 }
    $next = First-Word (Get-Field 'Next prompt')
    $machine = First-Word (Get-Field 'Next machine')
    $auto = First-Word (Get-Field 'Auto-continue')
    $updated = Get-Field 'Updated'

    if ($auto -ne 'yes') { Write-Host "Handoff says Auto-continue: $auto — stopping."; exit 0 }
    if ($machine -ne 'any' -and $machine -ne $thisMachine) {
        Write-Host "Next session ($next) needs a $machine machine; this is $thisMachine."
        Write-Host 'Commit and push here, then on that machine: git pull and run the auto-session script.'
        exit 0
    }

    $found = @(Get-ChildItem $prompts -Filter "session-$next-*.md")
    if ($found.Count -ne 1) { Write-Error "Next prompt '$next' must match exactly one session-$next-*.md (found $($found.Count))"; exit 1 }
    $file = $found[0].FullName
    $fence = 0
    $body = foreach ($line in Get-Content -LiteralPath $file -Encoding UTF8) {
        if ($line -match '^```') { $fence++; continue }
        if ($fence -eq 1) { $line }
    }
    $prompt = ($body -join "`n")
    if ([string]::IsNullOrWhiteSpace($prompt)) { Write-Error "no ``` block in $file"; exit 1 }

    Write-Host "=== Next session: $file (handoff updated: $updated)"
    if ($DryRun) { $prompt; exit 0 }

    & claude $prompt

    if ((Get-Field 'Updated') -eq $updated) {
        Write-Host "The session ended without updating the handoff — stopping so nothing repeats."
        exit 0
    }
    if ($Once) { exit 0 }

    Write-Host ''
    Write-Host 'Handoff updated. Next session starts in 10 s — press q to stop.'
    $deadline = (Get-Date).AddSeconds(10)
    while ((Get-Date) -lt $deadline) {
        if ([Console]::KeyAvailable -and [Console]::ReadKey($true).KeyChar -eq 'q') { Write-Host 'Stopped.'; exit 0 }
        Start-Sleep -Milliseconds 200
    }
}
