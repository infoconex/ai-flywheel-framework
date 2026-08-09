#Requires -Version 5.1

<#
.SYNOPSIS
Installs AI Flywheel Framework 2026.08.08 into a Git repository.

.DESCRIPTION
Installs the published AI Flywheel framework into the target repository without
installing or invoking any language-specific Flywheel implementation. The installer
verifies the published package checksum, rejects unsafe archive content, stages the
framework beside the target, verifies staged file hashes, atomically publishes the
`.flywheel` directory, records installation provenance, and verifies the installed
package files byte-for-byte.

The framework release and this installer share one release version: 2026.08.08.
The installer does not install Python, the AI Flywheel Python CLI, or any other
runtime implementation, and it does not start onboarding or lifecycle execution.

.PARAMETER Repository
Path within the target Git repository. Defaults to the current directory and is
resolved to the repository root.

.PARAMETER PackagePath
Optional local install-ready ZIP for release-candidate testing. When omitted, the
installer downloads the matching published release package and checksum.

.PARAMETER NonInteractive
Disables prompts. Repository mutation additionally requires -Apply.

.PARAMETER Apply
Explicitly authorizes installation when -NonInteractive is used.

.EXAMPLE
.\install.ps1

Installs AI Flywheel Framework 2026.08.08 from the published GitHub release.

.EXAMPLE
.\install.ps1 -Repository D:\code\my-project

Installs the framework into the resolved Git root for the supplied path.

.EXAMPLE
.\install.ps1 -PackagePath D:\releases\ai-flywheel-framework-2026.08.08.zip

Installs a locally built release-candidate package for validation before publication.
#>

[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
param(
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$Repository = '.',

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$PackagePath,

    [Parameter()]
    [switch]$NonInteractive,

    [Parameter()]
    [switch]$Apply
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$script:FrameworkVersion = '2026.08.08'
$script:FrameworkRepository = 'Infoconex/ai-flywheel-framework'
$script:PackageName = "ai-flywheel-framework-$($script:FrameworkVersion).zip"
$script:ReleaseTag = "v$($script:FrameworkVersion)"
$script:RunId = [guid]::NewGuid().ToString('N').Substring(0, 8)

function Write-InstallerSection {
    [CmdletBinding()]
    param([Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$Title)

    Write-Host ''
    Write-Host "## $Title" -ForegroundColor Cyan
    Write-Host ''
}

function Write-InstallerSuccess {
    [CmdletBinding()]
    param([Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$Message)

    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Write-InstallerWarning {
    [CmdletBinding()]
    param([Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$Message)

    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Get-RepositoryRoot {
    [CmdletBinding()]
    param([Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$Path)

    $resolved = (Resolve-Path -LiteralPath $Path -ErrorAction Stop).Path
    $git = Get-Command git -ErrorAction SilentlyContinue
    if (-not $git) {
        throw 'Git is required to identify the target repository.'
    }

    $root = (& $git.Source -C $resolved rev-parse --show-toplevel 2>$null | Select-Object -First 1)
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($root)) {
        throw "The target path is not inside a Git repository: $resolved"
    }

    return ([System.IO.Path]::GetFullPath($root.Trim()))
}

function Get-ReleasePackage {
    [CmdletBinding()]
    param([Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$WorkingDirectory)

    if ($PackagePath) {
        $resolvedPackage = (Resolve-Path -LiteralPath $PackagePath -ErrorAction Stop).Path
        if ([System.IO.Path]::GetExtension($resolvedPackage) -ne '.zip') {
            throw 'PackagePath must reference an install-ready ZIP archive.'
        }
        Write-InstallerWarning -Message 'Using a local release-candidate package; no published checksum is available.'
        return [pscustomobject]@{
            Path = $resolvedPackage
            Source = 'local-package'
            ExpectedSha256 = $null
        }
    }

    $releaseBase = "https://github.com/$($script:FrameworkRepository)/releases/download/$($script:ReleaseTag)"
    $packageUri = "$releaseBase/$($script:PackageName)"
    $checksumUri = "$packageUri.sha256"
    $downloadedPackage = Join-Path $WorkingDirectory $script:PackageName
    $downloadedChecksum = "$downloadedPackage.sha256"

    $request = @{
        Headers = @{ 'User-Agent' = 'ai-flywheel-framework-installer' }
        ErrorAction = 'Stop'
    }
    if ($PSVersionTable.PSEdition -eq 'Desktop') {
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
        $request['UseBasicParsing'] = $true
    }

    Invoke-WebRequest -Uri $packageUri -OutFile $downloadedPackage @request
    Invoke-WebRequest -Uri $checksumUri -OutFile $downloadedChecksum @request

    $checksumText = Get-Content -LiteralPath $downloadedChecksum -Raw -ErrorAction Stop
    $match = [regex]::Match($checksumText, '(?i)\b[0-9a-f]{64}\b')
    if (-not $match.Success) {
        throw 'Published checksum file does not contain a SHA-256 value.'
    }

    return [pscustomobject]@{
        Path = $downloadedPackage
        Source = "github-release:$($script:ReleaseTag)"
        ExpectedSha256 = $match.Value.ToLowerInvariant()
    }
}

function Expand-FrameworkPackage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$ArchivePath,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$Destination
    )

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    New-Item -ItemType Directory -Path $Destination -Force | Out-Null
    $destinationRoot = [System.IO.Path]::GetFullPath($Destination).TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
    $archive = [System.IO.Compression.ZipFile]::OpenRead($ArchivePath)

    try {
        foreach ($entry in $archive.Entries) {
            $entryName = $entry.FullName.Replace('\', '/')
            if ([string]::IsNullOrWhiteSpace($entryName)) { continue }
            if ($entryName.StartsWith('/') -or $entryName -match '^[A-Za-z]:' -or $entryName -match '(^|/)\.\.(/|$)') {
                throw "Archive contains an unsafe path: $entryName"
            }
            if ($entryName -ne '.flywheel/' -and -not $entryName.StartsWith('.flywheel/')) {
                throw "Archive contains content outside .flywheel: $entryName"
            }
            if ($entryName -eq '.flywheel/installation.yaml') {
                throw 'The release package must not contain installer-owned .flywheel/installation.yaml.'
            }

            $relativePath = $entryName.Replace('/', [System.IO.Path]::DirectorySeparatorChar)
            $targetPath = [System.IO.Path]::GetFullPath((Join-Path $Destination $relativePath))
            if (-not $targetPath.StartsWith($destinationRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
                throw "Archive entry escapes the extraction root: $entryName"
            }

            if ($entryName.EndsWith('/')) {
                New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
                continue
            }

            $parent = Split-Path -Parent $targetPath
            if (-not (Test-Path -LiteralPath $parent)) {
                New-Item -ItemType Directory -Path $parent -Force | Out-Null
            }

            $input = $entry.Open()
            $output = [System.IO.File]::Open($targetPath, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::Write, [System.IO.FileShare]::None)
            try { $input.CopyTo($output) }
            finally {
                $output.Dispose()
                $input.Dispose()
            }
        }
    }
    finally {
        $archive.Dispose()
    }

    $flywheelPath = Join-Path $Destination '.flywheel'
    if (-not (Test-Path -LiteralPath $flywheelPath -PathType Container)) {
        throw 'Release package does not contain a .flywheel directory.'
    }

    return $flywheelPath
}

function Assert-FrameworkPackageIdentity {
    [CmdletBinding()]
    param([Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$FlywheelPath)

    $manifestPath = Join-Path $FlywheelPath 'manifest.yaml'
    if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) {
        throw 'Release package is missing .flywheel/manifest.yaml.'
    }

    $manifest = Get-Content -LiteralPath $manifestPath -Raw -ErrorAction Stop
    $expected = '(?m)^\s*version:\s*["'']?' + [regex]::Escape($script:FrameworkVersion) + '["'']?\s*$'
    if ($manifest -notmatch $expected) {
        throw "Release package manifest does not identify framework version $($script:FrameworkVersion)."
    }
}

function Get-RelativeFileHashes {
    [CmdletBinding()]
    param([Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$Root)

    $rootPath = [System.IO.Path]::GetFullPath($Root).TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
    $hashes = @{}
    foreach ($file in Get-ChildItem -LiteralPath $Root -File -Recurse | Sort-Object FullName) {
        $relative = $file.FullName.Substring($rootPath.Length).Replace('\', '/')
        if ($relative -eq 'installation.yaml') { continue }
        $hashes[$relative] = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
    }
    return $hashes
}

function Assert-FileSetsMatch {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][hashtable]$Expected,
        [Parameter(Mandatory)][hashtable]$Actual
    )

    if ($Expected.Count -ne $Actual.Count) {
        throw "Installed framework file count mismatch. Expected $($Expected.Count), found $($Actual.Count)."
    }

    foreach ($path in $Expected.Keys) {
        if (-not $Actual.ContainsKey($path)) {
            throw "Installed framework is missing package file: $path"
        }
        if ($Expected[$path] -ne $Actual[$path]) {
            throw "Installed framework file hash mismatch: $path"
        }
    }
}

function Confirm-Install {
    [CmdletBinding()]
    param([Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$RepositoryRoot)

    if ($NonInteractive) { return [bool]$Apply }
    $answer = Read-Host "Install AI Flywheel Framework $($script:FrameworkVersion) into ${RepositoryRoot}? [Y/n]"
    return [string]::IsNullOrWhiteSpace($answer) -or $answer.Trim().StartsWith('y', [System.StringComparison]::OrdinalIgnoreCase)
}

$workingRoot = Join-Path ([System.IO.Path]::GetTempPath()) "AIFW-FRAMEWORK-$($script:RunId)"
$stagedTarget = $null
$installed = $false

try {
    Write-Host ''
    Write-Host 'AI Flywheel Framework Setup' -ForegroundColor Cyan
    Write-Host "Installing framework $($script:FrameworkVersion)."

    Write-InstallerSection -Title 'Repository'
    $repositoryRoot = Get-RepositoryRoot -Path $Repository
    Write-InstallerSuccess -Message 'Git repository detected'
    Write-Host "Repository root: $repositoryRoot"

    $targetFlywheel = Join-Path $repositoryRoot '.flywheel'
    if (Test-Path -LiteralPath $targetFlywheel) {
        throw 'A .flywheel directory already exists. This installer performs initial framework installation only and will not overwrite an existing Flywheel.'
    }

    New-Item -ItemType Directory -Path $workingRoot -Force | Out-Null

    Write-InstallerSection -Title 'Framework Package'
    $package = Get-ReleasePackage -WorkingDirectory $workingRoot
    $actualSha256 = (Get-FileHash -LiteralPath $package.Path -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($package.ExpectedSha256 -and $actualSha256 -ne $package.ExpectedSha256) {
        throw "Framework package checksum mismatch. Expected $($package.ExpectedSha256), received $actualSha256."
    }
    Write-InstallerSuccess -Message "Package SHA-256 verified: $actualSha256"

    $extractRoot = Join-Path $workingRoot 'extract'
    $packageFlywheel = Expand-FrameworkPackage -ArchivePath $package.Path -Destination $extractRoot
    Assert-FrameworkPackageIdentity -FlywheelPath $packageFlywheel
    $expectedHashes = Get-RelativeFileHashes -Root $packageFlywheel
    Write-InstallerSuccess -Message "Package safety checks passed ($($expectedHashes.Count) files)"

    Write-InstallerSection -Title 'Installation Plan'
    Write-Host "Framework version: $($script:FrameworkVersion)"
    Write-Host "Files to add: $($expectedHashes.Count + 1)"
    Write-Host 'Files to replace: 0'
    Write-Host 'Files to remove: 0'
    Write-Host 'Application files modified: None'

    if (-not (Confirm-Install -RepositoryRoot $repositoryRoot)) {
        Write-InstallerWarning -Message 'Installation cancelled.'
        return
    }

    Write-InstallerSection -Title 'Installation'
    if (-not $PSCmdlet.ShouldProcess($targetFlywheel, "Install AI Flywheel Framework $($script:FrameworkVersion)")) {
        return
    }

    $stagedTarget = Join-Path $repositoryRoot ".flywheel.installing-$($script:RunId)"
    Copy-Item -LiteralPath $packageFlywheel -Destination $stagedTarget -Recurse -Force -ErrorAction Stop
    $stagedHashes = Get-RelativeFileHashes -Root $stagedTarget
    Assert-FileSetsMatch -Expected $expectedHashes -Actual $stagedHashes

    Move-Item -LiteralPath $stagedTarget -Destination $targetFlywheel -ErrorAction Stop
    $stagedTarget = $null

    $provenance = @(
        'schema_version: 1',
        "framework_version: \"$($script:FrameworkVersion)\"",
        "source: \"$($package.Source)\"",
        "package: \"$($script:PackageName)\"",
        "package_sha256: \"$actualSha256\"",
        "installed_at: \"$([DateTimeOffset]::UtcNow.ToString('o'))\"",
        'installer: framework-install.ps1'
    ) -join [Environment]::NewLine
    Set-Content -LiteralPath (Join-Path $targetFlywheel 'installation.yaml') -Value $provenance -Encoding UTF8 -ErrorAction Stop

    $installedHashes = Get-RelativeFileHashes -Root $targetFlywheel
    Assert-FileSetsMatch -Expected $expectedHashes -Actual $installedHashes
    $installed = $true
    Write-InstallerSuccess -Message 'Framework installed faithfully'

    Write-InstallerSection -Title 'AI Flywheel Framework Setup Complete'
    Write-Host "Repository: $repositoryRoot"
    Write-Host "Framework: $($script:FrameworkVersion)"
    Write-Host "Package SHA-256: $actualSha256"
    Write-Host 'Repository changes: .flywheel/ only'
    Write-Host 'Python required: No'
    Write-Host 'AI Flywheel CLI installed: No'
    Write-Host ''
    Write-Host 'Next: Begin AI Flywheel onboarding manually or install a compatible runtime implementation.'
}
catch {
    if (-not $installed -and $targetFlywheel -and (Test-Path -LiteralPath $targetFlywheel)) {
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
