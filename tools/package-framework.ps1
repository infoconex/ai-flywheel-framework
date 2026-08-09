#Requires -Version 5.1

<#
.SYNOPSIS
Builds the installable AI Flywheel Framework 2026.08.08 release package.

.DESCRIPTION
Creates the canonical release ZIP containing only the repository's `.flywheel`
tree and writes a matching SHA-256 sidecar. The package version is intentionally
the same version as the framework manifest and installer.

.PARAMETER OutputDirectory
Directory where the ZIP and .sha256 sidecar are written. Defaults to `dist` at the
repository root.
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$OutputDirectory
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$frameworkVersion = '2026.08.08'
$repositoryRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$flywheelRoot = Join-Path $repositoryRoot '.flywheel'
if (-not $OutputDirectory) {
    $OutputDirectory = Join-Path $repositoryRoot 'dist'
}
$OutputDirectory = [System.IO.Path]::GetFullPath($OutputDirectory)

$manifestPath = Join-Path $flywheelRoot 'manifest.yaml'
if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) {
    throw 'Framework manifest was not found.'
}
$manifest = Get-Content -LiteralPath $manifestPath -Raw -ErrorAction Stop
$versionPattern = '(?m)^\s*version:\s*["'']?' + [regex]::Escape($frameworkVersion) + '["'']?\s*$'
if ($manifest -notmatch $versionPattern) {
    throw "Framework manifest version must be $frameworkVersion before packaging."
}

$packageName = "ai-flywheel-framework-$frameworkVersion.zip"
$packagePath = Join-Path $OutputDirectory $packageName
$checksumPath = "$packagePath.sha256"

if ($PSCmdlet.ShouldProcess($packagePath, "Build AI Flywheel Framework $frameworkVersion package")) {
    New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
    Remove-Item -LiteralPath $packagePath -Force -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $checksumPath -Force -ErrorAction SilentlyContinue

    Add-Type -AssemblyName System.IO.Compression
    Add-Type -AssemblyName System.IO.Compression.FileSystem

    $fileStream = [System.IO.File]::Open(
        $packagePath,
        [System.IO.FileMode]::CreateNew,
        [System.IO.FileAccess]::ReadWrite,
        [System.IO.FileShare]::None
    )
    $archive = [System.IO.Compression.ZipArchive]::new(
        $fileStream,
        [System.IO.Compression.ZipArchiveMode]::Create,
        $false
    )
    $fixedTimestamp = [DateTimeOffset]::new(1980, 1, 1, 0, 0, 0, [TimeSpan]::Zero)
    $repositoryPrefixLength = $repositoryRoot.TrimEnd([char[]]@('\', '/')).Length + 1

    try {
        $directories = @(Get-ChildItem -LiteralPath $flywheelRoot -Directory -Recurse | Sort-Object FullName)
        foreach ($directory in $directories) {
            $relative = $directory.FullName.Substring($repositoryPrefixLength).Replace('\', '/') + '/'
            $entry = $archive.CreateEntry($relative, [System.IO.Compression.CompressionLevel]::Optimal)
            $entry.LastWriteTime = $fixedTimestamp
        }

        $files = @(Get-ChildItem -LiteralPath $flywheelRoot -File -Recurse | Sort-Object FullName)
        foreach ($file in $files) {
            $relative = $file.FullName.Substring($repositoryPrefixLength).Replace('\', '/')
            if ($relative -eq '.flywheel/installation.yaml') {
                throw 'Installer-owned .flywheel/installation.yaml must not be included in a framework release package.'
            }

            $entry = $archive.CreateEntry($relative, [System.IO.Compression.CompressionLevel]::Optimal)
            $entry.LastWriteTime = $fixedTimestamp
            $input = [System.IO.File]::OpenRead($file.FullName)
            $output = $entry.Open()
            try {
                $input.CopyTo($output)
            }
            finally {
                $output.Dispose()
                $input.Dispose()
            }
        }
    }
    finally {
        $archive.Dispose()
        $fileStream.Dispose()
    }

    $sha256 = (Get-FileHash -LiteralPath $packagePath -Algorithm SHA256).Hash.ToLowerInvariant()
    Set-Content -LiteralPath $checksumPath -Value "$sha256  $packageName" -Encoding ASCII -ErrorAction Stop

    Write-Output "Framework version: $frameworkVersion"
    Write-Output "Package: $packagePath"
    Write-Output "SHA-256: $sha256"
    Write-Output "Checksum: $checksumPath"
}
