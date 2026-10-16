[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$InputPath,

    [string]$OutputDirectory = (Join-Path $PSScriptRoot '..\outputs\pipeline'),

    [ValidateRange(1, 100000)]
    [int]$MaximumRecords = 10000
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $InputPath)) {
    throw "Input file not found: $InputPath"
}

if ([System.IO.Path]::GetExtension($InputPath) -ne '.csv') {
    throw 'Preflight currently accepts the machine-readable HR CSV export. The workbook remains the human review artifact.'
}

$requiredColumns = @(
    'EmployeeId', 'GivenName', 'Surname', 'UserAlias', 'Department', 'JobTitle',
    'EmployeeType', 'ManagerEmployeeId', 'Location', 'CountryCode',
    'LifecycleAction', 'EmploymentStatus', 'StartDate', 'EndDate', 'CostCenter',
    'SourceSystem', 'RecordVersion'
)
$allowedDepartments = @('Executive', 'HR', 'Finance', 'IT', 'Sales', 'Operations')
$allowedEmployeeTypes = @('Employee', 'Contractor')
$allowedActions = @('Create', 'Update', 'Disable')
$allowedStatuses = @('Active', 'PreHire', 'LeaveScheduled')
$allowedCountries = @('BG', 'RO')

$records = @(Import-Csv -LiteralPath $InputPath)
if ($records.Count -eq 0) {
    throw 'Input contains no HR records.'
}
if ($records.Count -gt $MaximumRecords) {
    throw "Input contains $($records.Count) records and exceeds the approved preflight maximum of $MaximumRecords."
}

$missingColumns = @($requiredColumns | Where-Object { $_ -notin $records[0].PSObject.Properties.Name })
if ($missingColumns.Count -gt 0) {
    throw "Missing required columns: $($missingColumns -join ', ')"
}

$duplicateIds = @(
    $records |
        Group-Object EmployeeId |
        Where-Object Count -GT 1 |
        Select-Object -ExpandProperty Name
)
$knownEmployeeIds = [System.Collections.Generic.HashSet[string]]::new([string[]]$records.EmployeeId)
$issues = [System.Collections.Generic.List[object]]::new()

foreach ($record in $records) {
    $recordIssues = [System.Collections.Generic.List[string]]::new()

    foreach ($column in $requiredColumns | Where-Object { $_ -notin @('ManagerEmployeeId', 'EndDate') }) {
        if ([string]::IsNullOrWhiteSpace($record.$column)) {
            $recordIssues.Add("Missing:$column")
        }
    }
    if ($record.EmployeeId -in $duplicateIds) { $recordIssues.Add('Duplicate:EmployeeId') }
    if ($record.Department -notin $allowedDepartments) { $recordIssues.Add('Invalid:Department') }
    if ($record.EmployeeType -notin $allowedEmployeeTypes) { $recordIssues.Add('Invalid:EmployeeType') }
    if ($record.LifecycleAction -notin $allowedActions) { $recordIssues.Add('Invalid:LifecycleAction') }
    if ($record.EmploymentStatus -notin $allowedStatuses) { $recordIssues.Add('Invalid:EmploymentStatus') }
    if ($record.CountryCode -notin $allowedCountries) { $recordIssues.Add('Invalid:CountryCode') }
    if (-not [string]::IsNullOrWhiteSpace($record.ManagerEmployeeId) -and -not $knownEmployeeIds.Contains($record.ManagerEmployeeId)) {
        $recordIssues.Add('Invalid:ManagerReference')
    }
    if ($record.ManagerEmployeeId -eq $record.EmployeeId) { $recordIssues.Add('Invalid:SelfManager') }
    if ($record.LifecycleAction -eq 'Disable' -and [string]::IsNullOrWhiteSpace($record.EndDate)) {
        $recordIssues.Add('Missing:DisableEndDate')
    }
    if ($record.UserAlias -notmatch '^[a-z0-9]+(?:\.[a-z0-9]+)+$') { $recordIssues.Add('Invalid:UserAlias') }
    if ($record.RecordVersion -notmatch '^\d+$') { $recordIssues.Add('Invalid:RecordVersion') }

    if ($recordIssues.Count -gt 0) {
        $issues.Add([pscustomobject]@{
            EmployeeId = $record.EmployeeId
            Issues     = @($recordIssues)
        })
    }
}

New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
$resolvedInput = (Resolve-Path -LiteralPath $InputPath).Path
$inputHash = (Get-FileHash -LiteralPath $resolvedInput -Algorithm SHA256).Hash
$generatedAt = [DateTimeOffset]::Now

$summary = [ordered]@{
    GeneratedAt       = $generatedAt.ToString('o')
    InputFileName     = [System.IO.Path]::GetFileName($resolvedInput)
    InputSha256       = $inputHash
    TotalRecords      = $records.Count
    CreateRecords     = @($records | Where-Object LifecycleAction -EQ 'Create').Count
    UpdateRecords     = @($records | Where-Object LifecycleAction -EQ 'Update').Count
    DisableRecords    = @($records | Where-Object LifecycleAction -EQ 'Disable').Count
    ValidationErrors  = $issues.Count
    PreflightStatus   = if ($issues.Count -eq 0) { 'PASS' } else { 'FAIL' }
}

$plan = [ordered]@{
    SchemaVersion = '1.0'
    Summary       = $summary
    Changes       = @(
        foreach ($record in $records) {
            [ordered]@{
                EmployeeId       = $record.EmployeeId
                UserAlias        = $record.UserAlias
                Action           = $record.LifecycleAction
                Department       = $record.Department
                EmployeeType     = $record.EmployeeType
                ManagerEmployeeId = $record.ManagerEmployeeId
                EmploymentStatus = $record.EmploymentStatus
            }
        }
    )
    Issues        = @($issues)
}

$planPath = Join-Path $OutputDirectory 'hr-change-plan.json'
$summaryPath = Join-Path $OutputDirectory 'hr-preflight-summary.json'
$plan | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $planPath -Encoding utf8
$summary | ConvertTo-Json | Set-Content -LiteralPath $summaryPath -Encoding utf8
$planHash = (Get-FileHash -LiteralPath $planPath -Algorithm SHA256).Hash

[pscustomobject]@{
    Status           = $summary.PreflightStatus
    TotalRecords     = $summary.TotalRecords
    Creates          = $summary.CreateRecords
    Updates          = $summary.UpdateRecords
    Disables         = $summary.DisableRecords
    ValidationErrors = $summary.ValidationErrors
    InputSha256      = $inputHash
    PlanSha256       = $planHash
    PlanPath         = (Resolve-Path -LiteralPath $planPath).Path
}

if ($issues.Count -gt 0) {
    throw "Preflight failed for $($issues.Count) records. No Graph connection or apply operation was attempted."
}
