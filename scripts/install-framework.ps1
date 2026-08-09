#Requires -Version 5.1

<#
.SYNOPSIS
Installs AI Flywheel Framework 2026.08.08 into a Git repository.

.DESCRIPTION
Installs the framework without installing or invoking any language-specific AI
Flywheel implementation. Published installs verify the release checksum. All
installs reject unsafe archive paths, stage only `.flywheel`, verify staged and
installed file hashes, record provenance, and refuse to overwrite an existing
Flywheel. This installer does not start onboarding or lifecycle execution.

The installer version is the framework release version: 2026.08.08.

.PARAMETER Repository
Path within the target Git repository. Defaults to the current directory.

.PARAMETER PackagePath
Optional local install-ready ZIP used to test a release candidate before publication.

.PARAMETER NonInteractive
Disables prompts. Installation additionally requires -Apply.

.PARAMETER Apply
Authorizes installation when -NonInteractive is used.
#>

[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
param(
    [Parameter()][ValidateNotNullOrEmpty()][string]$Repository = '.',
    [Parameter()][ValidateNotNullOrEmpty()][string]$PackagePath,
    [Parameter()][switch]$NonInteractive,
    [Parameter()][switch]$Apply
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$script:FrameworkVersion = '2026.08.08'
$script:FrameworkRepository = 'Infoconex/ai-flywheel-framework'
$script:PackageName = "ai-flywheel-framework-$($script:FrameworkVersion).zip"
$script:ReleaseTag = "v$($script:FrameworkVersion)"
$script:RunId = [guid]::NewGuid().ToString('N').Substring(0, 8)

function Write-Section {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Title)
    Write-Host ''
    Write-Host "## $Title" -ForegroundColor Cyan
    Write-Host ''
}

function Write-Ok {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Message)
    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Get-GitRepositoryRoot {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Path)

    $resolved = (Resolve-Path -LiteralPath $Path -ErrorAction Stop).Path
    $git = Get-Command git -ErrorAction SilentlyContinue
    if (-not $git) { throw 'Git is required to install the AI Flywheel framework.' }

    $root = (& $git.Source -C $resolved rev-parse --show-toplevel 2>$null | Select-Object -First 1)
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($root)) {
        throw "The target path is not inside a Git repository: $resolved"
    }
    return [System.IO.Path]::GetFullPath($root.Trim())
}

function Get-FrameworkPackage {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$WorkingDirectory)

    if ($PackagePath) {
        $resolved = (Resolve-Path -LiteralPath $PackagePath -ErrorAction Stop).Path
        if ([System.IO.Path]::GetExtension($resolved) -ne '.zip') { throw 'PackagePath must reference a ZIP archive.' }
        Write-Host '[WARN] Using a local release-candidate package; published checksum verification is not available.' -ForegroundColor Yellow
        return [pscustomobject]@{ Path = $resolved; Source = 'local-package'; ExpectedSha256 = $null }
    }

    $baseUri = "https://github.com/$($script:FrameworkRepository)/releases/download/$($script:ReleaseTag)"
    $packageUri = "$baseUri/$($script:PackageName)"
    $checksumUri = "$packageUri.sha256"
    $downloadedPackage = Join-Path $WorkingDirectory $script:PackageName
    $downloadedChecksum = "$downloadedPackage.sha256"
    $request = @{ Headers = @{ 'User-Agent' = 'ai-flywheel-framework-installer' }; ErrorAction = 'Stop' }

    if ($PSVersionTable.PSEdition -eq 'Desktop') {
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
        $request['UseBasicParsing'] = $true
    }

    Invoke-WebRequest -Uri $packageUri -OutFile $downloadedPackage @request
    Invoke-WebRequest -Uri $checksumUri -OutFile $downloadedChecksum @request
    $checksumText = Get-Content -LiteralPath $downloadedChecksum -Raw -ErrorAction Stop
    $match = [regex]::Match($checksumText, '(?i)\b[0-9a-f]{64}\b')
    if (-not $match.Success) { throw 'Published checksum file does not contain a SHA-256 value.' }

    return [pscustomobject]@{
        Path = $downloadedPackage
        Source = "github-release:$($script:ReleaseTag)"
        ExpectedSha256 = $match.Value.ToLowerInvariant()
    }
}

function Expand-SafeFrameworkPackage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$ArchivePath,
        [Parameter(Mandatory)][string]$Destination
    )

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    New-Item -ItemType Directory -Path $Destination -Force | Out-Null
    $destinationPrefix = [System.IO.Path]::GetFullPath($Destination).TrimEnd([char[]]@('\', '/')) + [System.IO.Path]::DirectorySeparatorChar
    $archive = [System.IO.Compression.ZipFile]::OpenRead($ArchivePath)
    try {
        foreach ($entry in $archive.Entries) {
            $name = $entry.FullName.Replace('\', '/')
            if ([string]::IsNullOrWhiteSpace($name)) { continue }
            if ($name.StartsWith('/') -or $name -match '^[A-Za-z]:' -or $name -match '(^|/)\.\.(/|$)') {
                throw "Archive contains an unsafe path: $name"
            }
            if ($name -ne '.flywheel/' -and -not $name.StartsWith('.flywheel/')) {
                throw "Archive contains content outside .flywheel: $name"
            }
            if ($name -eq '.flywheel/installation.yaml') {
                throw 'Release package must not contain installer-owned .flywheel/installation.yaml.'
            }

            $relative = $name.Replace('/', [System.IO.Path]::DirectorySeparatorChar)
            $target = [System.IO.Path]::GetFullPath((Join-Path $Destination $relative))
            if (-not $target.StartsWith($destinationPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
                throw "Archive entry escapes the extraction root: $name"
            }

            if ($name.EndsWith('/')) {
                New-Item -ItemType Directory -Path $target -Force | Out-Null
                continue
            }

            $parent = Split-Path -Parent $target
            if (-not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
            $input = $entry.Open()
            $output = [System.IO.File]::Open($target, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::Write, [System.IO.FileShare]::None)
            try { $input.CopyTo($output) } finally { $output.Dispose(); $input.Dispose() }
        }
    }
    finally { $archive.Dispose() }

    $flywheel = Join-Path $Destination '.flywheel'
    if (-not (Test-Path -LiteralPath $flywheel -PathType Container)) { throw 'Release package does not contain .flywheel.' }
    return $flywheel
}

function Assert-PackageVersion {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$FlywheelPath)

    $manifestPath = Join-Path $FlywheelPath 'manifest.yaml'
    if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) { throw 'Release package is missing .flywheel/manifest.yaml.' }
    $manifest = Get-Content -LiteralPath $manifestPath -Raw -ErrorAction Stop
    $pattern = '(?m)^\s*version:\s*["'']?' + [regex]::Escape($script:FrameworkVersion) + '["'']?\s*$'
    if ($manifest -notmatch $pattern) { throw "Release package version does not match installer version $($script:FrameworkVersion)." }
}

function Get-FrameworkFileHashes {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Root)

    $prefix = [System.IO.Path]::GetFullPath($Root).TrimEnd([char[]]@('\', '/')) + [System.IO.Path]::DirectorySeparatorChar
    $result = @{}
    foreach ($file in Get-ChildItem -LiteralPath $Root -File -Recurse | Sort-Object FullName) {
        $relative = $file.FullName.Substring($prefix.Length).Replace('\', '/')
        if ($relative -eq 'installation.yaml') { continue }
        $result[$relative] = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
    }
    return $result
}

function Assert-HashesMatch {
    [CmdletBinding()]
    param([Parameter(Mandatory)][hashtable]$Expected, [Parameter(Mandatory)][hashtable]$Actual)

    if ($Expected.Count -ne $Actual.Count) { throw 'Installed framework file count does not match the release package.' }
    foreach ($path in $Expected.Keys) {
        if (-not $Actual.ContainsKey($path) -or $Expected[$path] -ne $Actual[$path]) {
            throw "Installed framework does not match package file: $path"
        }
    }
}

function Test-InstallApproved {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$RepositoryRoot)

    if ($NonInteractive) { return [bool]$Apply }
    $answer = Read-Host "Install AI Flywheel Framework $($script:FrameworkVersion) into ${RepositoryRoot}? [Y/n]"
    return [string]::IsNullOrWhiteSpace($answer) -or $answer.Trim().StartsWith('y', [System.StringComparison]::OrdinalIgnoreCase)
}

$workingRoot = Join-Path ([System.IO.Path]::GetTempPath()) "AIFW-FRAMEWORK-$($script:RunId)"
$repositoryRoot = $null
$targetFlywheel = $null
$stagedTarget = $null
$publishedTarget = $false
$installationComplete = $false

try {
    Write-Host ''
    Write-Host 'AI Flywheel Framework Setup' -ForegroundColor Cyan
    Write-Host "Installing framework $($script:FrameworkVersion)."

    Write-Section -Title 'Repository'
    $repositoryRoot = Get-GitRepositoryRoot -Path $Repository
    $targetFlywheel = Join-Path $repositoryRoot '.flywheel'
    Write-Ok -Message 'Git repository detected'
    Write-Host "Repository root: $repositoryRoot"
    if (Test-Path -LiteralPath $targetFlywheel) {
        throw 'A .flywheel directory already exists. Initial installation will not overwrite an existing Flywheel.'
    }

    New-Item -ItemType Directory -Path $workingRoot -Force | Out-Null
    Write-Section -Title 'Framework Package'
    $package = Get-FrameworkPackage -WorkingDirectory $workingRoot
    $packageSha256 = (Get-FileHash -LiteralPath $package.Path -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($package.ExpectedSha256 -and $packageSha256 -ne $package.ExpectedSha256) {
        throw "Framework package checksum mismatch. Expected $($package.ExpectedSha256), received $packageSha256."
    }
    Write-Ok -Message "Package SHA-256 verified: $packageSha256"

    $packageFlywheel = Expand-SafeFrameworkPackage -ArchivePath $package.Path -Destination (Join-Path $workingRoot 'extract')
    Assert-PackageVersion -FlywheelPath $packageFlywheel
    $expectedHashes = Get-FrameworkFileHashes -Root $packageFlywheel
    Write-Ok -Message "Package safety checks passed ($($expectedHashes.Count) framework files)"

    Write-Section -Title 'Installation Plan'
    Write-Host "Framework version: $($script:FrameworkVersion)"
    Write-Host "Files to add: $($expectedHashes.Count + 1)"
    Write-Host 'Files to replace: 0'
    Write-Host 'Files to remove: 0'
    Write-Host 'Application files modified: None'

    if (-not (Test-InstallApproved -RepositoryRoot $repositoryRoot)) {
        Write-Host '[WARN] Installation cancelled.' -ForegroundColor Yellow
        return
    }
    if (-not $PSCmdlet.ShouldProcess($targetFlywheel, "Install AI Flywheel Framework $($script:FrameworkVersion)")) { return }

    Write-Section -Title 'Installation'
    $stagedTarget = Join-Path $repositoryRoot ".flywheel.installing-$($script:RunId)"
    Copy-Item -LiteralPath $packageFlywheel -Destination $stagedTarget -Recurse -Force -ErrorAction Stop
    Assert-HashesMatch -Expected $expectedHashes -Actual (Get-FrameworkFileHashes -Root $stagedTarget)

    Move-Item -LiteralPath $stagedTarget -Destination $targetFlywheel -ErrorAction Stop
    $stagedTarget = $null
    $publishedTarget = $true

    $provenance = @(
        'schema_version: 1',
        "framework_version: \"$($script:FrameworkVersion)\"",
        "source: \"$($package.Source)\"",
        "package: \"$($script:PackageName)\"",
        "package_sha256: \"$packageSha256\"",
        "installed_at: \"$([DateTimeOffset]::UtcNow.ToString('o'))\"",
        'installer: framework-install.ps1'
    ) -join [Environment]::NewLine
    Set-Content -LiteralPath (Join-Path $targetFlywheel 'installation.yaml') -Value $provenance -Encoding UTF8 -ErrorAction Stop
    Assert-HashesMatch -Expected $expectedHashes -Actual (Get-FrameworkFileHashes -Root $targetFlywheel)

    $installationComplete = $true
    Write-Ok -Message 'Framework installed faithfully'
    Write-Section -Title 'AI Flywheel Framework Setup Complete'
    Write-Host "Repository: $repositoryRoot"
    Write-Host "Framework: $($script:FrameworkVersion)"
    Write-Host "Package SHA-256: $packageSha256"
    Write-Host 'Repository changes: .flywheel/ only'
    Write-Host 'Python required: No'
    Write-Host 'AI Flywheel CLI installed: No'
    Write-Host ''
    Write-Host 'Next: Begin AI Flywheel onboarding manually or install a compatible runtime implementation.'
}
catch {
    if ($publishedTarget -and -not $installationComplete -and $targetFlywheel -and (Test-Path -LiteralPath $targetFlywheel)) {
        Remove-Item -LiteralPath $targetFlywheel -Recurse -Force -ErrorAction SilentlyContinue
    }
    Write-Host ''
    Write-Host "[FAIL] $($_.Exception.Message)" -ForegroundColor Red
    throw
}
finally {
    if ($stagedTarget -and (Test-Path -LiteralPath $stagedTarget)) {
        Remove-Item -LiteralPath $stagedTarget -Recurse -Force -ErrorAction SilentlyContinue
    }
    if (Test-Path -LiteralPath $workingRoot) {
        Remove-Item -LiteralPath $workingRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}
