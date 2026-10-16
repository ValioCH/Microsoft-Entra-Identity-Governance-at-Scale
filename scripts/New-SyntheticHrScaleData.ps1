[CmdletBinding()]
param(
    [ValidateRange(20, 10000)]
    [int]$Count = 1000,

    [string]$OutputPath = (Join-Path $PSScriptRoot '..\outputs\scale\synthetic-hr-1000.csv'),

    [int]$Seed = 42
)

$ErrorActionPreference = 'Stop'
$random = [System.Random]::new($Seed)
$outputDirectory = Split-Path -Parent $OutputPath
New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null

$departments = @(
    [pscustomobject]@{ Name = 'Executive'; CostCenter = 'CC-100'; ManagerId = 'SCALE-000001' },
    [pscustomobject]@{ Name = 'HR'; CostCenter = 'CC-110'; ManagerId = 'SCALE-000002' },
    [pscustomobject]@{ Name = 'Finance'; CostCenter = 'CC-120'; ManagerId = 'SCALE-000003' },
    [pscustomobject]@{ Name = 'IT'; CostCenter = 'CC-130'; ManagerId = 'SCALE-000004' },
    [pscustomobject]@{ Name = 'Sales'; CostCenter = 'CC-140'; ManagerId = 'SCALE-000005' },
    [pscustomobject]@{ Name = 'Operations'; CostCenter = 'CC-150'; ManagerId = 'SCALE-000006' }
)

$locations = @(
    [pscustomobject]@{ Name = 'Sofia'; Country = 'BG' },
    [pscustomobject]@{ Name = 'Varna'; Country = 'BG' },
    [pscustomobject]@{ Name = 'Bucharest'; Country = 'RO' }
)

$records = [System.Collections.Generic.List[object]]::new()

for ($index = 1; $index -le $Count; $index++) {
    $employeeId = 'SCALE-{0:D6}' -f $index

    if ($index -le 6) {
        $department = $departments[$index - 1]
        $managerId = if ($index -eq 1) { '' } else { 'SCALE-000001' }
        $jobTitle = if ($index -eq 1) { 'Chief Operating Officer' } else { "$($department.Name) Director" }
        $employeeType = 'Employee'
        $lifecycleAction = 'Create'
        $employmentStatus = 'Active'
        $endDate = ''
    }
    else {
        $department = $departments[$random.Next(1, $departments.Count)]
        $managerId = $department.ManagerId
        $employeeType = if ($random.NextDouble() -lt 0.10) { 'Contractor' } else { 'Employee' }
        $actionRoll = $random.NextDouble()
        $lifecycleAction = if ($actionRoll -lt 0.03) { 'Disable' } elseif ($actionRoll -lt 0.08) { 'Update' } else { 'Create' }
        $employmentStatus = if ($lifecycleAction -eq 'Disable') { 'LeaveScheduled' } elseif ($index % 50 -eq 0) { 'PreHire' } else { 'Active' }
        $endDate = if ($lifecycleAction -eq 'Disable') { '2026-09-30' } elseif ($employeeType -eq 'Contractor') { '2026-12-31' } else { '' }
        $jobTitle = if ($employeeType -eq 'Contractor') { "$($department.Name) Contractor" } else { "$($department.Name) Specialist" }
    }

    $location = $locations[$random.Next(0, $locations.Count)]
    $startDay = 1 + ($index % 27)

    $records.Add([pscustomobject][ordered]@{
        EmployeeId       = $employeeId
        GivenName        = 'User'
        Surname          = '{0:D4}' -f $index
        UserAlias        = 'scale.user{0:D4}' -f $index
        Department       = $department.Name
        JobTitle         = $jobTitle
        EmployeeType     = $employeeType
        ManagerEmployeeId = $managerId
        Location         = $location.Name
        CountryCode      = $location.Country
        LifecycleAction  = $lifecycleAction
        EmploymentStatus = $employmentStatus
        StartDate        = '2026-09-{0:D2}' -f $startDay
        EndDate          = $endDate
        CostCenter       = $department.CostCenter
        SourceSystem     = 'HR-SCALE-SIM'
        RecordVersion    = 1
    })
}

$records | Export-Csv -LiteralPath $OutputPath -NoTypeInformation -Encoding utf8

[pscustomobject]@{
    OutputPath = (Resolve-Path -LiteralPath $OutputPath).Path
    Records    = $records.Count
    Creates    = @($records | Where-Object LifecycleAction -EQ 'Create').Count
    Updates    = @($records | Where-Object LifecycleAction -EQ 'Update').Count
    Disables   = @($records | Where-Object LifecycleAction -EQ 'Disable').Count
    Seed       = $Seed
}
