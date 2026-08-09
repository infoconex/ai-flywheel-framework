#Requires -Version 5.1

<#
.SYNOPSIS
Validates AI Flywheel framework PowerShell scripts.

.DESCRIPTION
Runs the built-in PowerShell parser, PSScriptAnalyzer with the repository-owned
settings, and comment-based-help validation. The command fails on parse errors,
Error/Warning analyzer diagnostics, missing PSScriptAnalyzer, or missing help.

.PARAMETER ScriptPath
Path to the PowerShell script to validate. Defaults to the root framework installer.

.PARAMETER SettingsPath
Path to the PSScriptAnalyzer settings file. Defaults to the repository policy.
#>

[CmdletBinding()]
param(
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$ScriptPath,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$SettingsPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repositoryRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
if ([string]::IsNullOrWhiteSpace($ScriptPath)) {
    $ScriptPath = Join-Path $repositoryRoot 'install.ps1'
}
if ([string]::IsNullOrWhiteSpace($SettingsPath)) {
    $SettingsPath = Join-Path $repositoryRoot 'PSScriptAnalyzerSettings.psd1'
}

$resolvedScriptPath = (Resolve-Path -LiteralPath $ScriptPath).Path
$resolvedSettingsPath = (Resolve-Path -LiteralPath $SettingsPath).Path

$tokens = $null
$parseErrors = $null
[System.Management.Automation.Language.Parser]::ParseFile(
    $resolvedScriptPath,
    [ref]$tokens,
    [ref]$parseErrors
) | Out-Null

if ($parseErrors.Count -gt 0) {
    $parseErrors | Format-Table -AutoSize
    throw "PowerShell parser reported $($parseErrors.Count) error(s)."
}

$analyzer = Get-Module -ListAvailable -Name PSScriptAnalyzer |
    Sort-Object Version -Descending |
    Select-Object -First 1
if (-not $analyzer) {
    throw 'PSScriptAnalyzer is required. Install with: Install-Module PSScriptAnalyzer -Scope CurrentUser'
}

Import-Module -Name $analyzer.Path -Force
$diagnostics = @(Invoke-ScriptAnalyzer -Path $resolvedScriptPath -Settings $resolvedSettingsPath)
if ($diagnostics.Count -gt 0) {
    $diagnostics | Format-Table RuleName, Severity, Line, Message -AutoSize -Wrap
    throw "PSScriptAnalyzer reported $($diagnostics.Count) error/warning diagnostic(s)."
}

$help = Get-Help -Name $resolvedScriptPath -Full
if ([string]::IsNullOrWhiteSpace($help.Synopsis) -or $help.Synopsis -eq $resolvedScriptPath) {
    throw 'Comment-based help is missing or invalid.'
}

Write-Output 'PowerShell validation passed.'
