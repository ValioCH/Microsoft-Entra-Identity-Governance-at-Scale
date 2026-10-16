[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$InputPath,

    [string]$PolicyPath = (Join-Path $PSScriptRoot '..\config\birthright-access-policy.csv'),

    [string]$OutputDirectory = (Join-Path $PSScriptRoot '..\outputs\entitlements')
)

$ErrorActionPreference = 'Stop'

foreach ($path in @($InputPath, $PolicyPath)) {
    if (-not (Test-Path -LiteralPath $path)) { throw "Required file not found: $path" }
}

$records = @(Import-Csv -LiteralPath $InputPath)
$rules = @(Import-Csv -LiteralPath $PolicyPath | Sort-Object { [int]$_.Priority }, RuleId)

$supportedAttributes = @('EmploymentStatus', 'EmployeeType', 'Department', 'Location')
$unsupportedRules = @($rules | Where-Object { $_.Attribute -notin $supportedAttributes -or $_.Operator -ne 'Equals' })
if ($unsupportedRules.Count -gt 0) {
    throw "Policy contains unsupported rules: $($unsupportedRules.RuleId -join ', ')"
}

$decisions = [System.Collections.Generic.List[object]]::new()

foreach ($record in $records) {
    $isDisable = $record.LifecycleAction -eq 'Disable' -or $record.EmploymentStatus -eq 'LeaveScheduled'

    if ($isDisable) {
        $decisions.Add([pscustomobject][ordered]@{
            EmployeeId       = $record.EmployeeId
            UserAlias        = $record.UserAlias
            LifecycleAction  = $record.LifecycleAction
            EmploymentStatus = $record.EmploymentStatus
            Decision         = 'REMOVE_ALL_BIRTHRIGHT_ACCESS'
            EntitlementType  = 'LifecycleControl'
            EntitlementName  = 'JML-OFFBOARDING'
            RuleId           = 'JML-LEAVER'
            Reason           = 'Leaver records receive no positive entitlement assignment.'
        })
        continue
    }

    if ($record.EmploymentStatus -eq 'PreHire') {
        $matchingRules = @($rules | Where-Object {
            $_.Attribute -eq 'EmploymentStatus' -and $_.Value -eq 'PreHire'
        })
    }
    else {
        $matchingRules = @($rules | Where-Object { $record.($_.Attribute) -eq $_.Value })
    }
    foreach ($rule in $matchingRules) {
        $decisions.Add([pscustomobject][ordered]@{
            EmployeeId       = $record.EmployeeId
            UserAlias        = $record.UserAlias
            LifecycleAction  = $record.LifecycleAction
            EmploymentStatus = $record.EmploymentStatus
            Decision         = 'ASSIGN'
            EntitlementType  = $rule.EntitlementType
            EntitlementName  = $rule.EntitlementName
            RuleId           = $rule.RuleId
            Reason           = $rule.Description
        })
    }
}

New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
$decisionPath = Join-Path $OutputDirectory 'birthright-access-decisions.csv'
$summaryPath = Join-Path $OutputDirectory 'birthright-access-summary.json'
$decisions | Export-Csv -LiteralPath $decisionPath -NoTypeInformation -Encoding utf8

$privilegedMatches = @($decisions | Where-Object {
    $_.EntitlementName -match '(Global Administrator|Privileged|Admin$|PIM|Role)'
})

$summary = [ordered]@{
    GeneratedAt                = [DateTimeOffset]::Now.ToString('o')
    InputFileName              = [System.IO.Path]::GetFileName($InputPath)
    InputRecords               = $records.Count
    PolicyRules                = $rules.Count
    AccessDecisions            = $decisions.Count
    AssignmentDecisions        = @($decisions | Where-Object Decision -EQ 'ASSIGN').Count
    OffboardingDecisions       = @($decisions | Where-Object Decision -EQ 'REMOVE_ALL_BIRTHRIGHT_ACCESS').Count
    PrivilegedAccessDecisions  = $privilegedMatches.Count
    ControlResult              = if ($privilegedMatches.Count -eq 0) { 'PASS' } else { 'FAIL' }
    ControlStatement           = 'HR attributes must not grant privileged roles; privileged access requires a separate approval and PIM workflow.'
}
$summary | ConvertTo-Json | Set-Content -LiteralPath $summaryPath -Encoding utf8

[pscustomobject]$summary

if ($privilegedMatches.Count -gt 0) {
    throw 'Birthright policy attempted to grant privileged access.'
}
