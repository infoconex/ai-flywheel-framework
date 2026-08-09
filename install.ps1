#Requires -Version 5.1

<#
.SYNOPSIS
Starts the AI Flywheel Framework 2026.08.08 installer.

.DESCRIPTION
This lightweight launcher is safe for the `irm ... | iex` delivery pattern. It
runs in an isolated child scope, downloads the reviewed canonical framework
installer to a temporary .ps1 file, executes it in its own script scope, and
removes the temporary file afterward.

The launcher and canonical installer both target framework release 2026.08.08.
#>

& {
    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'
    $ProgressPreference = 'SilentlyContinue'

    $frameworkVersion = '2026.08.08'
    $installerCommit = '63678c78021d3b1c84280f49f47f844a60c7e76c'
    $installerUri = "https://raw.githubusercontent.com/Infoconex/ai-flywheel-framework/$installerCommit/scripts/install-framework.ps1"
    $installerPath = Join-Path ([System.IO.Path]::GetTempPath()) ("ai-flywheel-framework-$frameworkVersion-$([guid]::NewGuid().ToString('N').Substring(0, 8)).ps1")

    try {
        $request = @{
            Uri = $installerUri
            OutFile = $installerPath
            Headers = @{ 'User-Agent' = 'ai-flywheel-framework-installer' }
            ErrorAction = 'Stop'
        }
        if ($PSVersionTable.PSEdition -eq 'Desktop') {
            [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
            $request['UseBasicParsing'] = $true
        }

        Invoke-WebRequest @request
        & $installerPath
    }
    finally {
        Remove-Item -LiteralPath $installerPath -Force -ErrorAction SilentlyContinue
    }
}
