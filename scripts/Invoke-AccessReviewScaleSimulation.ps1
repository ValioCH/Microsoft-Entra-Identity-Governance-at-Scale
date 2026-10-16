[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$InputPath,

    [string]$OutputDirectory,

    [ValidateRange(1, 365)]
    [int]$InactiveDays = 30,

    [ValidateRange(1, 1000)]
    [int]$MaximumReviewerLoad = 100,

    [int]$Seed = 42
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
    $OutputDirectory = Join-Path $PSScriptRoot '..\outputs\access-review-scale'
}

if (-not (Test-Path -LiteralPath $InputPath)) {
    throw "Input file not found: $InputPath"
}

$records = @(Import-Csv -LiteralPath $InputPath)
if ($records.Count -eq 0) { throw 'Input contains no records.' }

$required = @('EmployeeId', 'Department', 'Location', 'EmployeeType', 'LifecycleAction', 'EmploymentStatus')
$missing = @($required | Where-Object { $_ -notin $records[0].PSObject.Properties.Name })
if ($missing.Count -gt 0) { throw "Missing required columns: $($missing -join ', ')" }

New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
$resolvedInput = (Resolve-Path -LiteralPath $InputPath).Path
$inputHash = (Get-FileHash -LiteralPath $resolvedInput -Algorithm SHA256).Hash
$asOfDate = [datetime]'2026-09-29'

$decisions = @(
    foreach ($record in $records | Sort-Object EmployeeId) {
        if ($record.EmployeeId -notmatch '(\d+)$') { throw "EmployeeId has no numeric suffix: $($record.EmployeeId)" }
        $numericId = [int]$Matches[1]
        $daysSinceSignIn = (($numericId * 37) + $Seed) % 121
        $lastSignIn = $asOfDate.AddDays(-$daysSinceSignIn).ToString('yyyy-MM-dd')
        $isPrivileged = ($numericId % 97 -eq 0)
        $reviewer = 'reviewer.{0}.{1}' -f $record.Department.ToLowerInvariant(), $record.Location.ToLowerInvariant()

        if ($record.LifecycleAction -eq 'Disable' -or $record.EmploymentStatus -eq 'LeaveScheduled') {
            $recommendation = 'Deny'
            $reason = 'Lifecycle indicates disable or scheduled leave.'
        }
        elseif ($isPrivileged) {
            $recommendation = 'ManualReview'
            $reason = 'Privileged-access exception requires evidence-based review.'
        }
        elseif ($record.EmploymentStatus -eq 'PreHire') {
            $recommendation = 'ManualReview'
            $reason = 'Pre-hire access requires start-date confirmation.'
        }
        elseif ($daysSinceSignIn -gt $InactiveDays) {
            $recommendation = 'Deny'
            $reason = "No simulated sign-in within $InactiveDays days."
        }
        else {
            $recommendation = 'Approve'
            $reason = 'Active lifecycle and recent simulated sign-in.'
        }

        [pscustomobject][ordered]@{
            EmployeeId         = $record.EmployeeId
            Department         = $record.Department
            Location           = $record.Location
            ReviewerAlias      = $reviewer
            EmployeeType       = $record.EmployeeType
            EmploymentStatus   = $record.EmploymentStatus
            LifecycleAction    = $record.LifecycleAction
            SimulatedLastSignIn = $lastSignIn
            DaysSinceSignIn    = $daysSinceSignIn
            PrivilegedException = $isPrivileged
            Recommendation     = $recommendation
            RecommendationReason = $reason
        }
    }
)

$reviewerWorkload = @(
    $decisions |
        Group-Object ReviewerAlias |
        ForEach-Object {
            $items = @($_.Group)
            [pscustomobject][ordered]@{
                ReviewerAlias = $_.Name
                Total         = $items.Count
                Approve       = @($items | Where-Object Recommendation -EQ 'Approve').Count
                Deny          = @($items | Where-Object Recommendation -EQ 'Deny').Count
                ManualReview  = @($items | Where-Object Recommendation -EQ 'ManualReview').Count
                WithinLimit   = ($items.Count -le $MaximumReviewerLoad)
            }
        } |
        Sort-Object ReviewerAlias
)

$summary = [ordered]@{
    SchemaVersion        = '1.0'
    AsOfDate             = $asOfDate.ToString('yyyy-MM-dd')
    InputFileName        = [IO.Path]::GetFileName($resolvedInput)
    InputSha256          = $inputHash
    Seed                 = $Seed
    InactiveDays         = $InactiveDays
    TotalIdentities      = $decisions.Count
    ReviewerCount        = $reviewerWorkload.Count
    MaximumReviewerLoad  = ($reviewerWorkload | Measure-Object Total -Maximum).Maximum
    AverageReviewerLoad  = [math]::Round(($reviewerWorkload | Measure-Object Total -Average).Average, 2)
    ReviewersOverLimit   = @($reviewerWorkload | Where-Object { -not $_.WithinLimit }).Count
    Approve              = @($decisions | Where-Object Recommendation -EQ 'Approve').Count
    Deny                 = @($decisions | Where-Object Recommendation -EQ 'Deny').Count
    ManualReview         = @($decisions | Where-Object Recommendation -EQ 'ManualReview').Count
    PrivilegedExceptions = @($decisions | Where-Object PrivilegedException -EQ $true).Count
    Status               = if (@($reviewerWorkload | Where-Object { -not $_.WithinLimit }).Count -eq 0) { 'PASS' } else { 'FAIL' }
}

$decisionPath = Join-Path $OutputDirectory 'access-review-decisions.csv'
$workloadPath = Join-Path $OutputDirectory 'reviewer-workload.csv'
$planPath = Join-Path $OutputDirectory 'access-review-plan.json'
$summaryPath = Join-Path $OutputDirectory 'access-review-summary.json'

$decisions | Export-Csv -LiteralPath $decisionPath -NoTypeInformation -Encoding utf8
$reviewerWorkload | Export-Csv -LiteralPath $workloadPath -NoTypeInformation -Encoding utf8
[ordered]@{ Summary = $summary; ReviewerWorkload = $reviewerWorkload; Decisions = $decisions } |
    ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $planPath -Encoding utf8
$summary | ConvertTo-Json | Set-Content -LiteralPath $summaryPath -Encoding utf8

[pscustomobject]@{
    Status               = $summary.Status
    TotalIdentities      = $summary.TotalIdentities
    ReviewerCount        = $summary.ReviewerCount
    MaximumReviewerLoad  = $summary.MaximumReviewerLoad
    AverageReviewerLoad  = $summary.AverageReviewerLoad
    Approve              = $summary.Approve
    Deny                 = $summary.Deny
    ManualReview         = $summary.ManualReview
    PrivilegedExceptions = $summary.PrivilegedExceptions
    InputSha256          = $inputHash
    PlanSha256           = (Get-FileHash -LiteralPath $planPath -Algorithm SHA256).Hash
    PlanPath             = (Resolve-Path -LiteralPath $planPath).Path
}

if ($summary.Status -ne 'PASS') {
    throw "Reviewer workload exceeded the approved maximum of $MaximumReviewerLoad."
}
