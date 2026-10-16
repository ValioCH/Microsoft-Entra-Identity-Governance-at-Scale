[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$InputPath,

    [string]$OutputDirectory,

    [ValidateRange(1, 100)]
    [int]$MinimumMfaReadinessPercent = 95
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
    $OutputDirectory = Join-Path $PSScriptRoot '..\outputs\conditional-access-scale'
}
if (-not (Test-Path -LiteralPath $InputPath)) { throw "Input file not found: $InputPath" }

$records = @(Import-Csv -LiteralPath $InputPath)
if ($records.Count -eq 0) { throw 'Input contains no records.' }
New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null

$resolvedInput = (Resolve-Path -LiteralPath $InputPath).Path
$inputHash = (Get-FileHash -LiteralPath $resolvedInput -Algorithm SHA256).Hash

$impact = @(
    foreach ($record in $records | Sort-Object EmployeeId) {
        if ($record.EmployeeId -notmatch '(\d+)$') { throw "EmployeeId has no numeric suffix: $($record.EmployeeId)" }
        $id = [int]$Matches[1]
        $isEmergency = $id -in @(1, 2)
        $isPrivileged = ($id % 97 -eq 0)
        $mfaRegistered = ($id % 10 -ne 0)

        $ring = if ($isEmergency) {
            'Ring0-Emergency-Exclusion'
        }
        elseif ($isPrivileged) {
            'Ring1-Privileged-Pilot'
        }
        elseif ($record.Department -eq 'IT' -and $record.Location -eq 'Sofia') {
            'Ring2-IT-Pilot'
        }
        elseif ($record.Department -in @('HR', 'Finance')) {
            'Ring3-Department-Rollout'
        }
        else {
            'Ring4-Broad-Workforce'
        }

        $evaluation = if ($isEmergency) {
            'Excluded'
        }
        elseif ($record.LifecycleAction -eq 'Disable' -or $record.EmploymentStatus -eq 'LeaveScheduled') {
            'NotTargeted-Inactive'
        }
        elseif ($mfaRegistered) {
            'WouldSatisfy-MFA'
        }
        else {
            'UserActionRequired-RegisterMFA'
        }

        [pscustomobject][ordered]@{
            EmployeeId       = $record.EmployeeId
            Department       = $record.Department
            Location         = $record.Location
            DeploymentRing   = $ring
            EmergencyAccess  = $isEmergency
            Privileged       = $isPrivileged
            MfaRegistered    = $mfaRegistered
            Evaluation       = $evaluation
        }
    }
)

$rings = @(
    $impact |
        Group-Object DeploymentRing |
        ForEach-Object {
            $items = @($_.Group)
            $targeted = @($items | Where-Object { $_.Evaluation -like 'WouldSatisfy-*' -or $_.Evaluation -like 'UserActionRequired-*' })
            $ready = @($items | Where-Object Evaluation -EQ 'WouldSatisfy-MFA').Count
            $readiness = if ($targeted.Count -eq 0) { 100 } else { [math]::Round(($ready / $targeted.Count) * 100, 2) }
            [pscustomobject][ordered]@{
                DeploymentRing    = $_.Name
                Identities        = $items.Count
                TargetedActive    = $targeted.Count
                WouldSatisfyMfa   = $ready
                UserActionRequired = @($items | Where-Object Evaluation -Like 'UserActionRequired-*').Count
                Excluded          = @($items | Where-Object Evaluation -EQ 'Excluded').Count
                Inactive          = @($items | Where-Object Evaluation -EQ 'NotTargeted-Inactive').Count
                MfaReadinessPercent = $readiness
                PromotionDecision = if ($_.Name -eq 'Ring0-Emergency-Exclusion') { 'Excluded' } elseif ($readiness -ge $MinimumMfaReadinessPercent) { 'Go' } else { 'NoGo-RemediateMFA' }
            }
        } |
        Sort-Object DeploymentRing
)

$summary = [ordered]@{
    SchemaVersion              = '1.0'
    InputFileName              = [IO.Path]::GetFileName($resolvedInput)
    InputSha256                = $inputHash
    TotalIdentities            = $impact.Count
    EmergencyExclusions        = @($impact | Where-Object EmergencyAccess -EQ $true).Count
    PrivilegedIdentities       = @($impact | Where-Object Privileged -EQ $true).Count
    WouldSatisfyMfa            = @($impact | Where-Object Evaluation -EQ 'WouldSatisfy-MFA').Count
    UserActionRequired         = @($impact | Where-Object Evaluation -Like 'UserActionRequired-*').Count
    InactiveNotTargeted        = @($impact | Where-Object Evaluation -EQ 'NotTargeted-Inactive').Count
    MinimumMfaReadinessPercent = $MinimumMfaReadinessPercent
    RingsReadyForPromotion     = @($rings | Where-Object PromotionDecision -EQ 'Go').Count
    RingsBlocked               = @($rings | Where-Object PromotionDecision -Like 'NoGo-*').Count
    Status                     = if (@($impact | Where-Object EmergencyAccess -EQ $true).Count -eq 2) { 'PASS' } else { 'FAIL' }
}

$impactPath = Join-Path $OutputDirectory 'conditional-access-impact.csv'
$ringsPath = Join-Path $OutputDirectory 'deployment-ring-summary.csv'
$planPath = Join-Path $OutputDirectory 'conditional-access-plan.json'
$summaryPath = Join-Path $OutputDirectory 'conditional-access-summary.json'
$impact | Export-Csv -LiteralPath $impactPath -NoTypeInformation -Encoding utf8
$rings | Export-Csv -LiteralPath $ringsPath -NoTypeInformation -Encoding utf8
[ordered]@{ Summary = $summary; Rings = $rings; Impact = $impact } | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $planPath -Encoding utf8
$summary | ConvertTo-Json | Set-Content -LiteralPath $summaryPath -Encoding utf8

[pscustomobject]@{
    Status                 = $summary.Status
    TotalIdentities        = $summary.TotalIdentities
    EmergencyExclusions    = $summary.EmergencyExclusions
    PrivilegedIdentities   = $summary.PrivilegedIdentities
    WouldSatisfyMfa        = $summary.WouldSatisfyMfa
    UserActionRequired     = $summary.UserActionRequired
    InactiveNotTargeted    = $summary.InactiveNotTargeted
    RingsReadyForPromotion = $summary.RingsReadyForPromotion
    RingsBlocked           = $summary.RingsBlocked
    InputSha256            = $inputHash
    PlanSha256             = (Get-FileHash -LiteralPath $planPath -Algorithm SHA256).Hash
    PlanPath               = (Resolve-Path -LiteralPath $planPath).Path
}

if ($summary.Status -ne 'PASS') { throw 'Emergency-access exclusion invariant failed.' }
