#Requires -Version 5.1

<#
.SYNOPSIS
Runs a local end-to-end regression test for the standalone framework installer.

.DESCRIPTION
Packages the repository's real `.flywheel`, initializes a temporary Git repository,
installs the package with the framework installer, verifies the expected installed
files and provenance, verifies no application files were introduced, and confirms
a second install is refused instead of overwriting an existing Flywheel.
#>

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repositoryRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$installerPath = Join-Path $repositoryRoot 'install.ps1'
$packagerPath = Join-Path $repositoryRoot 'tools\package-framework.ps1'
$testRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('AIFW-FRAMEWORK-TEST-' + [guid]::NewGuid().ToString('N').Substring(0, 8))
$packageOutput = Join-Path $testRoot 'dist'
$targetRepository = Join-Path $testRoot 'target'

function Assert-Test {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][bool]$Condition,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$Message
    )

    if (-not $Condition) { throw $Message }
}

try {
    New-Item -ItemType Directory -Path $packageOutput -Force | Out-Null
    New-Item -ItemType Directory -Path $targetRepository -Force | Out-Null

    & $packagerPath -OutputDirectory $packageOutput -Confirm:$false
    $packagePath = Join-Path $packageOutput 'ai-flywheel-framework-2026.08.08.zip'
    Assert-Test -Condition (Test-Path -LiteralPath $packagePath -PathType Leaf) -Message 'Framework package was not created.'
    Assert-Test -Condition (Test-Path -LiteralPath "$packagePath.sha256" -PathType Leaf) -Message 'Framework checksum sidecar was not created.'

    $git = Get-Command git -ErrorAction Stop
    & $git.Source -C $targetRepository init --quiet
    if ($LASTEXITCODE -ne 0) { throw 'Unable to initialize temporary Git repository.' }

    & $installerPath -Repository $targetRepository -PackagePath $packagePath -NonInteractive -Apply -Confirm:$false

    $installedFlywheel = Join-Path $targetRepository '.flywheel'
    Assert-Test -Condition (Test-Path -LiteralPath $installedFlywheel -PathType Container) -Message '.flywheel was not installed.'
    Assert-Test -Condition (Test-Path -LiteralPath (Join-Path $installedFlywheel 'manifest.yaml') -PathType Leaf) -Message 'Installed manifest is missing.'
    Assert-Test -Condition (Test-Path -LiteralPath (Join-Path $installedFlywheel 'installation.yaml') -PathType Leaf) -Message 'Installation provenance is missing.'

    $manifest = Get-Content -LiteralPath (Join-Path $installedFlywheel 'manifest.yaml') -Raw
    Assert-Test -Condition ($manifest -match '(?m)^\s*version:\s*2026\.08\.08\s*$') -Message 'Installed framework version is incorrect.'

    $topLevel = @(Get-ChildItem -LiteralPath $targetRepository -Force | Where-Object { $_.Name -notin @('.git', '.flywheel') })
    Assert-Test -Condition ($topLevel.Count -eq 0) -Message 'Installer introduced content outside .flywheel.'

    $markerPath = Join-Path $installedFlywheel 'installer-regression-marker.txt'
    Set-Content -LiteralPath $markerPath -Value 'preserve-me' -Encoding ASCII
    $secondInstallFailed = $false
    try {
        & $installerPath -Repository $targetRepository -PackagePath $packagePath -NonInteractive -Apply -Confirm:$false
    }
    catch {
        $secondInstallFailed = $true
    }

    Assert-Test -Condition $secondInstallFailed -Message 'Installer did not refuse an existing .flywheel installation.'
    Assert-Test -Condition (Test-Path -LiteralPath $markerPath -PathType Leaf) -Message 'Existing Flywheel content was modified during refused reinstall.'

    $installerText = Get-Content -LiteralPath $installerPath -Raw
    Assert-Test -Condition ($installerText -notmatch '(?im)Get-Command\s+(python|py)\b') -Message 'Framework installer must not discover Python.'
    Assert-Test -Condition ($installerText -notmatch '(?i)ai-flywheel-cli-python') -Message 'Framework installer must not depend on the Python CLI repository.'
    Assert-Test -Condition ($installerText -notmatch '(?i)start-execution|advance-lifecycle|complete-execution') -Message 'Framework installer must not perform lifecycle operations.'

    Write-Output 'Framework installer regression tests passed.'
}
finally {
    if (Test-Path -LiteralPath $testRoot) {
        Remove-Item -LiteralPath $testRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}
