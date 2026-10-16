[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot

function Assert-Equal {
    param(
        [Parameter(Mandatory)]$Actual,
        [Parameter(Mandatory)]$Expected,
        [Parameter(Mandatory)][string]$Label
    )

    if ($Actual -ne $Expected) {
        throw "$Label failed. Expected '$Expected'; observed '$Actual'."
    }
}

$runRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("entra-identity-governance-test-" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $runRoot | Out-Null

try {
    $inputPath = Join-Path $runRoot 'synthetic-hr-1000.csv'
    $pipelineDirectory = Join-Path $runRoot 'pipeline'
    $entitlementDirectory = Join-Path $runRoot 'entitlements'
    $reviewDirectoryA = Join-Path $runRoot 'review-a'
    $reviewDirectoryB = Join-Path $runRoot 'review-b'
    $caDirectoryA = Join-Path $runRoot 'ca-a'
    $caDirectoryB = Join-Path $runRoot 'ca-b'

    & (Join-Path $repoRoot 'scripts\New-SyntheticHrScaleData.ps1') -Count 1000 -Seed 42 -OutputPath $inputPath | Out-Null
    & (Join-Path $repoRoot 'scripts\Invoke-HrPipelinePreflight.ps1') -InputPath $inputPath -OutputDirectory $pipelineDirectory | Out-Null
    & (Join-Path $repoRoot 'scripts\Resolve-HrBirthrightAccess.ps1') -InputPath $inputPath -OutputDirectory $entitlementDirectory | Out-Null
    & (Join-Path $repoRoot 'scripts\Invoke-AccessReviewScaleSimulation.ps1') -InputPath $inputPath -OutputDirectory $reviewDirectoryA -MaximumReviewerLoad 100 | Out-Null
    & (Join-Path $repoRoot 'scripts\Invoke-AccessReviewScaleSimulation.ps1') -InputPath $inputPath -OutputDirectory $reviewDirectoryB -MaximumReviewerLoad 100 | Out-Null
    & (Join-Path $repoRoot 'scripts\Invoke-ConditionalAccessScaleSimulation.ps1') -InputPath $inputPath -OutputDirectory $caDirectoryA -MinimumMfaReadinessPercent 95 | Out-Null
    & (Join-Path $repoRoot 'scripts\Invoke-ConditionalAccessScaleSimulation.ps1') -InputPath $inputPath -OutputDirectory $caDirectoryB -MinimumMfaReadinessPercent 95 | Out-Null

    $preflight = Get-Content -LiteralPath (Join-Path $pipelineDirectory 'hr-preflight-summary.json') -Raw | ConvertFrom-Json
    Assert-Equal $preflight.PreflightStatus 'PASS' 'HR preflight status'
    Assert-Equal $preflight.TotalRecords 1000 'HR record count'
    Assert-Equal $preflight.CreateRecords 915 'Create count'
    Assert-Equal $preflight.UpdateRecords 57 'Update count'
    Assert-Equal $preflight.DisableRecords 28 'Disable count'
    Assert-Equal $preflight.ValidationErrors 0 'Validation error count'

    $entitlements = Get-Content -LiteralPath (Join-Path $entitlementDirectory 'birthright-access-summary.json') -Raw | ConvertFrom-Json
    Assert-Equal $entitlements.ControlResult 'PASS' 'Birthright policy control'
    Assert-Equal $entitlements.InputRecords 1000 'Birthright input count'
    Assert-Equal $entitlements.PrivilegedAccessDecisions 0 'HR-derived privileged decisions'

    $reviewA = Get-Content -LiteralPath (Join-Path $reviewDirectoryA 'access-review-summary.json') -Raw | ConvertFrom-Json
    $reviewB = Get-Content -LiteralPath (Join-Path $reviewDirectoryB 'access-review-summary.json') -Raw | ConvertFrom-Json
    Assert-Equal $reviewA.Status 'PASS' 'Access-review scale status'
    Assert-Equal $reviewA.TotalIdentities 1000 'Access-review identity count'
    Assert-Equal $reviewA.ReviewerCount 16 'Reviewer count'
    Assert-Equal $reviewA.MaximumReviewerLoad 81 'Maximum reviewer load'
    Assert-Equal $reviewA.ReviewersOverLimit 0 'Reviewer queues over limit'
    Assert-Equal $reviewA.Approve 245 'Approve recommendations'
    Assert-Equal $reviewA.Deny 726 'Deny recommendations'
    Assert-Equal $reviewA.ManualReview 29 'Manual-review recommendations'
    Assert-Equal $reviewA.PrivilegedExceptions 10 'Privileged exceptions'
    Assert-Equal ((Get-FileHash -LiteralPath (Join-Path $reviewDirectoryA 'access-review-plan.json') -Algorithm SHA256).Hash) ((Get-FileHash -LiteralPath (Join-Path $reviewDirectoryB 'access-review-plan.json') -Algorithm SHA256).Hash) 'Access-review repeatability hash'

    $caA = Get-Content -LiteralPath (Join-Path $caDirectoryA 'conditional-access-summary.json') -Raw | ConvertFrom-Json
    $caB = Get-Content -LiteralPath (Join-Path $caDirectoryB 'conditional-access-summary.json') -Raw | ConvertFrom-Json
    Assert-Equal $caA.Status 'PASS' 'Conditional Access model status'
    Assert-Equal $caA.TotalIdentities 1000 'Conditional Access identity count'
    Assert-Equal $caA.EmergencyExclusions 2 'Emergency exclusions'
    Assert-Equal $caA.PrivilegedIdentities 10 'Privileged identity count'
    Assert-Equal $caA.WouldSatisfyMfa 872 'MFA-ready count'
    Assert-Equal $caA.UserActionRequired 98 'MFA registration count'
    Assert-Equal $caA.InactiveNotTargeted 28 'Inactive identity count'
    Assert-Equal $caA.RingsReadyForPromotion 0 'Rings ready for promotion'
    Assert-Equal $caA.RingsBlocked 4 'Blocked rings'
    Assert-Equal ((Get-FileHash -LiteralPath (Join-Path $caDirectoryA 'conditional-access-plan.json') -Algorithm SHA256).Hash) ((Get-FileHash -LiteralPath (Join-Path $caDirectoryB 'conditional-access-plan.json') -Algorithm SHA256).Hash) 'Conditional Access repeatability hash'

    [pscustomobject]@{
        Status = 'PASS'
        Tests = 25
        Identities = 1000
        HrValidationErrors = 0
        HrDerivedPrivilegedDecisions = 0
        ReviewersOverLimit = 0
        ConditionalAccessRingsPromoted = 0
        Repeatability = 'PASS'
    }
}
finally {
    if (Test-Path -LiteralPath $runRoot) {
        Remove-Item -LiteralPath $runRoot -Recurse -Force
    }
}
