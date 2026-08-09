#Requires -Version 5.1

<#
.SYNOPSIS
Runs local regression tests for the standalone framework installer.

.DESCRIPTION
Packages the repository's real `.flywheel` twice to prove deterministic local
packaging, installs it into a temporary Git repository with the canonical framework
installer, verifies CLI-compatible provenance and mutation scope, confirms reinstall
refusal preserves existing state, and checks the public launcher boundary.
#>

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repositoryRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$launcherPath = Join-Path $repositoryRoot 'install.ps1'
$installerPath = Join-Path $repositoryRoot 'scripts\install-framework.ps1'
$packagerPath = Join-Path $repositoryRoot 'tools\package-framework.ps1'
$testRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('AIFW-FRAMEWORK-TEST-' + [guid]::NewGuid().ToString('N').Substring(0, 8))
$packageOutput1 = Join-Path $testRoot 'dist-1'
$packageOutput2 = Join-Path $testRoot 'dist-2'
$targetRepository = Join-Path $testRoot 'target'
$packageName = 'ai-flywheel-framework-2026.08.08.zip'
$gitEnvironmentNames = @('GIT_DIR', 'GIT_WORK_TREE', 'GIT_COMMON_DIR', 'GIT_OBJECT_DIRECTORY', 'GIT_INDEX_FILE')
$savedGitEnvironment = @{}

function Assert-Test {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][bool]$Condition,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$Message
    )

    if (-not $Condition) { throw $Message }
}

function Invoke-NativeCommandCapture {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$FilePath,
        [Parameter()][string[]]$Arguments = @()
    )

    $stdoutPath = Join-Path $testRoot ('stdout-' + [guid]::NewGuid().ToString('N') + '.txt')
    $stderrPath = Join-Path $testRoot ('stderr-' + [guid]::NewGuid().ToString('N') + '.txt')
    try {
        & $FilePath @Arguments 1> $stdoutPath 2> $stderrPath
        $exitCode = $LASTEXITCODE

        $stdoutContent = if (Test-Path -LiteralPath $stdoutPath) {
            Get-Content -LiteralPath $stdoutPath -Raw -ErrorAction SilentlyContinue
        }
        $stderrContent = if (Test-Path -LiteralPath $stderrPath) {
            Get-Content -LiteralPath $stderrPath -Raw -ErrorAction SilentlyContinue
        }
        $stdout = if ($null -eq $stdoutContent) { '' } else { $stdoutContent.Trim() }
        $stderr = if ($null -eq $stderrContent) { '' } else { $stderrContent.Trim() }

        return [pscustomobject]@{
            FilePath = $FilePath
            Arguments = @($Arguments)
            ExitCode = $exitCode
            StdOut = $stdout
            StdErr = $stderr
        }
    }
    finally {
        Remove-Item -LiteralPath $stdoutPath, $stderrPath -Force -ErrorAction SilentlyContinue
    }
}

function Format-NativeCommandFailure {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Message,
        [Parameter(Mandatory)][pscustomobject]$Result
    )

    $command = @($Result.FilePath) + @($Result.Arguments)
    return @(
        $Message
        "Command: $($command -join ' ')"
        "Exit code: $($Result.ExitCode)"
        "stdout: $($Result.StdOut)"
        "stderr: $($Result.StdErr)"
    ) -join [Environment]::NewLine
}

try {
    foreach ($name in $gitEnvironmentNames) {
        $value = [Environment]::GetEnvironmentVariable($name, 'Process')
        if ($null -ne $value) {
            $savedGitEnvironment[$name] = $value
            [Environment]::SetEnvironmentVariable($name, $null, 'Process')
        }
    }

    New-Item -ItemType Directory -Path $packageOutput1 -Force | Out-Null
    New-Item -ItemType Directory -Path $packageOutput2 -Force | Out-Null
    New-Item -ItemType Directory -Path $targetRepository -Force | Out-Null

    & $packagerPath -OutputDirectory $packageOutput1 -Confirm:$false
    & $packagerPath -OutputDirectory $packageOutput2 -Confirm:$false

    $packagePath = Join-Path $packageOutput1 $packageName
    $secondPackagePath = Join-Path $packageOutput2 $packageName
    Assert-Test -Condition (Test-Path -LiteralPath $packagePath -PathType Leaf) -Message 'Framework package was not created.'
    Assert-Test -Condition (Test-Path -LiteralPath "$packagePath.sha256" -PathType Leaf) -Message 'Framework checksum sidecar was not created.'
    Assert-Test -Condition (Test-Path -LiteralPath $secondPackagePath -PathType Leaf) -Message 'Second framework package was not created.'

    $packageSha256 = (Get-FileHash -LiteralPath $packagePath -Algorithm SHA256).Hash.ToLowerInvariant()
    $secondPackageSha256 = (Get-FileHash -LiteralPath $secondPackagePath -Algorithm SHA256).Hash.ToLowerInvariant()
    Assert-Test -Condition ($packageSha256 -eq $secondPackageSha256) -Message 'Repeated framework packaging produced different ZIP hashes.'

    $git = Get-Command git -ErrorAction Stop
    $gitVersion = Invoke-NativeCommandCapture -FilePath $git.Source -Arguments @('--version')
    Assert-Test -Condition ($gitVersion.ExitCode -eq 0) -Message (Format-NativeCommandFailure -Message 'Git executable could not report its version.' -Result $gitVersion)

    $gitInit = Invoke-NativeCommandCapture -FilePath $git.Source -Arguments @('-C', $targetRepository, 'init', '--quiet')
    Assert-Test -Condition ($gitInit.ExitCode -eq 0) -Message (Format-NativeCommandFailure -Message 'Unable to initialize temporary Git repository.' -Result $gitInit)

    $gitDirectory = Join-Path $targetRepository '.git'
    Assert-Test -Condition (Test-Path -LiteralPath $gitDirectory -PathType Container) -Message "Temporary Git repository did not create a .git directory. Git: $($git.Source); version: $($gitVersion.StdOut)"

    $insideWorkTreeResult = Invoke-NativeCommandCapture -FilePath $git.Source -Arguments @('-C', $targetRepository, 'rev-parse', '--is-inside-work-tree')
    Assert-Test -Condition ($insideWorkTreeResult.ExitCode -eq 0) -Message (Format-NativeCommandFailure -Message 'Git could not verify the temporary repository as a work tree.' -Result $insideWorkTreeResult)
    Assert-Test -Condition ($insideWorkTreeResult.StdOut.Trim() -eq 'true') -Message (Format-NativeCommandFailure -Message 'Temporary Git repository is not recognized as a work tree.' -Result $insideWorkTreeResult)

    $topLevelResult = Invoke-NativeCommandCapture -FilePath $git.Source -Arguments @('-C', $targetRepository, 'rev-parse', '--show-toplevel')
    Assert-Test -Condition ($topLevelResult.ExitCode -eq 0) -Message (Format-NativeCommandFailure -Message 'Git could not resolve the temporary repository root.' -Result $topLevelResult)
    Assert-Test -Condition (-not [string]::IsNullOrWhiteSpace($topLevelResult.StdOut)) -Message (Format-NativeCommandFailure -Message 'Git returned an empty repository root.' -Result $topLevelResult)

    $pathTrimCharacters = [char[]]'\/'
    $resolvedTopLevel = (Resolve-Path -LiteralPath $topLevelResult.StdOut.Trim()).Path.TrimEnd($pathTrimCharacters)
    $resolvedTargetRepository = (Resolve-Path -LiteralPath $targetRepository).Path.TrimEnd($pathTrimCharacters)
    Assert-Test -Condition ($resolvedTopLevel -eq $resolvedTargetRepository) -Message "Git resolved unexpected repository root '$resolvedTopLevel'; expected '$resolvedTargetRepository'."

    & $installerPath -Repository $targetRepository -PackagePath $packagePath -NonInteractive -Apply -Confirm:$false

    $installedFlywheel = Join-Path $targetRepository '.flywheel'
    $manifestPath = Join-Path $installedFlywheel 'manifest.yaml'
    $installationPath = Join-Path $installedFlywheel 'installation.yaml'
    Assert-Test -Condition (Test-Path -LiteralPath $installedFlywheel -PathType Container) -Message '.flywheel was not installed.'
    Assert-Test -Condition (Test-Path -LiteralPath $manifestPath -PathType Leaf) -Message 'Installed manifest is missing.'
    Assert-Test -Condition (Test-Path -LiteralPath $installationPath -PathType Leaf) -Message 'Installation provenance is missing.'

    $manifest = Get-Content -LiteralPath $manifestPath -Raw
    Assert-Test -Condition ($manifest -match '(?m)^\s*version:\s*2026\.08\.08\s*$') -Message 'Installed framework version is incorrect.'

    $installation = Get-Content -LiteralPath $installationPath -Raw
    Assert-Test -Condition ($installation -match '(?m)^schema_version:\s*1\s*$') -Message 'Installation metadata schema version is missing.'
    Assert-Test -Condition ($installation -match '(?m)^framework_version:\s*"2026\.08\.08"\s*$') -Message 'Installation metadata framework version is incorrect.'
    $archivePattern = '(?m)^archive_sha256:\s*"{0}"\s*$' -f [regex]::Escape($packageSha256)
    Assert-Test -Condition ($installation -match $archivePattern) -Message 'Installation metadata archive checksum is incorrect.'
    Assert-Test -Condition ($installation -match '(?m)^source_identity:\s*"local-archive"\s*$') -Message 'Installation metadata source identity is incorrect.'
    Assert-Test -Condition ($installation -match '(?m)^owned_files:\s*$') -Message 'Installation metadata owned_files mapping is missing.'
    Assert-Test -Condition ($installation.Contains('".flywheel/manifest.yaml"'.Replace('\', ''))) -Message 'Installation metadata must track immutable framework files.'
    Assert-Test -Condition (-not $installation.Contains('".flywheel/state.yaml"'.Replace('\', ''))) -Message 'Mutable state.yaml must not be recorded as an owned immutable file.'
    Assert-Test -Condition (-not $installation.Contains('".flywheel/operations/'.Replace('\', ''))) -Message 'Mutable operations content must not be recorded as owned immutable files.'

    $topLevel = @(Get-ChildItem -LiteralPath $targetRepository -Force | Where-Object { $_.Name -notin @('.git', '.flywheel') })
    Assert-Test -Condition ($topLevel.Count -eq 0) -Message 'Installer introduced content outside .flywheel.'

    $markerPath = Join-Path $installedFlywheel 'installer-regression-marker.txt'
    Set-Content -LiteralPath $markerPath -Value 'preserve-me' -Encoding ASCII
    $secondInstallOutputPath = Join-Path $testRoot 'second-install-output.txt'
    $secondInstallFailed = $false
    try {
        & $installerPath -Repository $targetRepository -PackagePath $packagePath -NonInteractive -Apply -Confirm:$false *> $secondInstallOutputPath
    }
    catch {
        $secondInstallFailed = $true
    }

    $secondInstallOutput = if (Test-Path -LiteralPath $secondInstallOutputPath) {
        Get-Content -LiteralPath $secondInstallOutputPath -Raw -ErrorAction SilentlyContinue
    }
    if ($null -eq $secondInstallOutput) { $secondInstallOutput = '' }

    Assert-Test -Condition $secondInstallFailed -Message 'Installer did not refuse an existing .flywheel installation.'
    Assert-Test -Condition ($secondInstallOutput -match '\[FAIL\] A \.flywheel directory already exists\.') -Message 'Expected reinstall refusal message was not emitted.'
    Assert-Test -Condition ($secondInstallOutput -notmatch '## Diagnostic Details') -Message 'Expected reinstall refusal emitted unexpected diagnostic details.'
    Assert-Test -Condition (Test-Path -LiteralPath $markerPath -PathType Leaf) -Message 'Existing Flywheel content was modified during refused reinstall.'
    if (-not [string]::IsNullOrWhiteSpace($secondInstallOutput)) {
        Write-Output $secondInstallOutput.Trim()
    }

    $installerText = Get-Content -LiteralPath $installerPath -Raw
    Assert-Test -Condition ($installerText -notmatch '(?im)Get-Command\s+(python|py)\b') -Message 'Framework installer must not discover Python.'
    Assert-Test -Condition ($installerText -notmatch '(?i)ai-flywheel-cli-python') -Message 'Framework installer must not depend on the Python CLI repository.'
    Assert-Test -Condition ($installerText -notmatch '(?i)start-execution|advance-lifecycle|complete-execution') -Message 'Framework installer must not perform lifecycle operations.'

    $tokens = $null
    $parseErrors = $null
    $launcherAst = [System.Management.Automation.Language.Parser]::ParseFile($launcherPath, [ref]$tokens, [ref]$parseErrors)
    Assert-Test -Condition ($parseErrors.Count -eq 0) -Message 'Public launcher contains a parse error.'
    Assert-Test -Condition ($null -eq $launcherAst.ParamBlock) -Message 'Public launcher must not have a top-level parameter block.'

    $launcherText = Get-Content -LiteralPath $launcherPath -Raw
    Assert-Test -Condition ($launcherText.Contains('& {')) -Message 'Public launcher must isolate Invoke-Expression execution in a child scope.'
    Assert-Test -Condition ($launcherText -match "frameworkVersion\s*=\s*'2026\.08\.08'") -Message 'Public launcher must target framework version 2026.08.08.'
    Assert-Test -Condition ($launcherText -match "installerCommit\s*=\s*'[0-9a-f]{40}'") -Message 'Public launcher must pin an immutable canonical installer commit.'
    Assert-Test -Condition ($launcherText.Contains('/scripts/install-framework.ps1')) -Message 'Public launcher must delegate to the canonical framework installer.'

    Write-Output 'Framework installer regression tests passed.'
}
catch {
    Write-Host ''
    Write-Host '[FAIL] Framework installer regression failed.' -ForegroundColor Red
    Write-Host "Message: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.InvocationInfo -and $_.InvocationInfo.PositionMessage) {
        Write-Host "Location: $($_.InvocationInfo.PositionMessage.Trim())"
    }
    if (-not [string]::IsNullOrWhiteSpace($_.ScriptStackTrace)) {
        Write-Host 'Stack trace:'
        Write-Host $_.ScriptStackTrace
    }
    throw
}
finally {
    foreach ($name in $gitEnvironmentNames) {
        [Environment]::SetEnvironmentVariable($name, $null, 'Process')
    }
    foreach ($name in $savedGitEnvironment.Keys) {
        [Environment]::SetEnvironmentVariable($name, $savedGitEnvironment[$name], 'Process')
    }

    if (Test-Path -LiteralPath $testRoot) {
        Remove-Item -LiteralPath $testRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}
