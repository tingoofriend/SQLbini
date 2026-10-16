# Start a fresh Claude Code session with a prepared session prompt as its first message.
#
# Usage:  .\tools\session\start-session.ps1 <id>          e.g. 10b, 11
#         .\tools\session\start-session.ps1 -List
#         .\tools\session\start-session.ps1 <id> -Print   (show the prompt, do not start)
#         .\tools\session\start-session.ps1 <id> -NewWindow  (open the session in a new
#                                    pwsh window; usable from inside Claude Code)
#
# Reads production/session-prompts/session-<id>-*.md and sends the content of its
# FIRST ``` code block. Always starts from the project root, so the project's
# hooks, deny rules and ask-first mode load (CLAUDE.md).
param(
    [Parameter(Position = 0)] [string] $Id,
    [switch] $List,
    [switch] $Print,
    [switch] $NewWindow
)
$ErrorActionPreference = 'Stop'
# The prompt contains double quotes and newlines; Windows PowerShell 5.1 mangles
# such arguments to native programs. PowerShell 7.3+ passes them intact.
if ($PSVersionTable.PSVersion -lt [Version]'7.3') {
    Write-Error "PowerShell 7.3+ required (run with 'pwsh'); found $($PSVersionTable.PSVersion)"
    exit 1
}
$PSNativeCommandArgumentPassing = 'Standard'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location $root
$dir = Join-Path $root 'production\session-prompts'

if ($List) {
    Get-ChildItem $dir -Filter 'session-*.md' | ForEach-Object { $_.Name }
    exit 0
}
if (-not $Id) {
    Write-Error 'usage: start-session.ps1 <id> [-Print] | -List'
    exit 2
}

$found = @(Get-ChildItem $dir -Filter "session-$Id-*.md")
if ($found.Count -ne 1) {
    Write-Error "expected exactly one file for id '$Id', found $($found.Count)"
    exit 1
}
$file = $found[0].FullName

$lines = Get-Content -LiteralPath $file -Encoding UTF8
$fence = 0
$body = foreach ($line in $lines) {
    if ($line -match '^```') { $fence++; continue }
    if ($fence -eq 1) { $line }
}
$prompt = ($body -join "`n")
if ([string]::IsNullOrWhiteSpace($prompt)) {
    Write-Error "no ``` code block found in $file"
    exit 1
}

if ($Print) {
    $prompt
    exit 0
}

if ($NewWindow) {
    $self = Join-Path $root 'tools\session\start-session.ps1'
    Start-Process pwsh -WorkingDirectory $root -ArgumentList @('-NoExit', '-File', $self, $Id)
    Write-Host "Opened a new pwsh window for: $file"
    exit 0
}

Write-Host "Starting a new Claude Code session with: $file"
& claude $prompt
