@{
    Severity = @('Error', 'Warning')

    # The installer owns a small interactive terminal experience. Write-Host is
    # intentionally limited to presentation while installation integrity is
    # enforced through explicit checks and terminating errors.
    ExcludeRules = @('PSAvoidUsingWriteHost')

    Rules = @{
        PSUseCompatibleSyntax = @{
            Enable = $true
            TargetVersions = @('5.1', '7.0')
        }
    }
}
