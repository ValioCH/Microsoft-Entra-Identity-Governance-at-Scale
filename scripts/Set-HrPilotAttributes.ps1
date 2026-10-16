[CmdletBinding()]
param(
    [string]$HrDataPath = (Join-Path $PSScriptRoot '..\data\hr-pilot.csv'),
    [string]$UserMapPath,
    [switch]$UseDeviceCode,
    [switch]$Apply
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $HrDataPath)) {
    throw "HR data file not found: $HrDataPath"
}

$hrRecords = @(Import-Csv -LiteralPath $HrDataPath)
$allowedEmployeeTypes = @('Employee', 'Contractor')

if ($hrRecords.Count -eq 0) {
    throw 'The HR source contains no records.'
}

if (-not [string]::IsNullOrWhiteSpace($UserMapPath)) {
    if (-not (Test-Path -LiteralPath $UserMapPath)) {
        throw "External user map not found: $UserMapPath"
    }
    $userMap = @(Import-Csv -LiteralPath $UserMapPath)
}
else {
    $userMap = @(
        foreach ($record in $hrRecords) {
            [pscustomobject]@{
                Alias             = $record.Alias
                UserPrincipalName = Read-Host "Enter the live UPN for alias '$($record.Alias)'"
            }
        }
    )
}

foreach ($record in $hrRecords) {
    $requiredValues = @(
        $record.Alias,
        $record.Department,
        $record.JobTitle,
        $record.EmployeeType,
        $record.EmployeeId
    )

    if ($requiredValues.Where({ [string]::IsNullOrWhiteSpace($_) }).Count -gt 0) {
        throw "HR record '$($record.Alias)' contains an empty required value."
    }

    if ($record.EmployeeType -notin $allowedEmployeeTypes) {
        throw "HR record '$($record.Alias)' has an unsupported EmployeeType."
    }

    $matchingMap = @($userMap | Where-Object Alias -EQ $record.Alias)
    if ($matchingMap.Count -ne 1) {
        throw "Alias '$($record.Alias)' must have exactly one entry in the local user map."
    }

    if ([string]::IsNullOrWhiteSpace($matchingMap[0].UserPrincipalName) -or
        $matchingMap[0].UserPrincipalName -match '^<.+>$') {
        throw "Alias '$($record.Alias)' still has a placeholder UPN."
    }

    if ($matchingMap[0].UserPrincipalName -notmatch '^[^@\s]+@[^@\s]+$') {
        throw "Alias '$($record.Alias)' requires a full UPN in user@domain format, not a display name."
    }
}

Import-Module Microsoft.Graph.Authentication -ErrorAction Stop
$requiredScope = if ($Apply) { 'User.ReadUpdate.All' } else { 'User.Read.All' }
$connectParameters = @{
    Scopes    = $requiredScope
    NoWelcome = $true
}
if ($UseDeviceCode) {
    $connectParameters.UseDeviceCode = $true
}
Connect-MgGraph @connectParameters

try {
    foreach ($record in $hrRecords) {
        $mapEntry = $userMap | Where-Object Alias -EQ $record.Alias
        $encodedUserId = [uri]::EscapeDataString($mapEntry.UserPrincipalName)
        $userUri = "/v1.0/users/$encodedUserId"
        $current = Invoke-MgGraphRequest -Method GET -Uri "$userUri`?`$select=id,department,jobTitle,employeeType,employeeId"

        $desired = [ordered]@{
            department   = $record.Department
            jobTitle     = $record.JobTitle
            employeeType = $record.EmployeeType
            employeeId   = $record.EmployeeId
        }

        $changedFields = @(
            foreach ($field in $desired.Keys) {
                if ([string]$current[$field] -cne [string]$desired[$field]) {
                    $field
                }
            }
        )

        if ($changedFields.Count -eq 0) {
            Write-Output "NO CHANGE | alias=$($record.Alias)"
            continue
        }

        if (-not $Apply) {
            Write-Output "DRY RUN | alias=$($record.Alias) | fields=$($changedFields -join ',')"
            continue
        }

        Invoke-MgGraphRequest -Method PATCH -Uri $userUri -Body ($desired | ConvertTo-Json -Compress) -ContentType 'application/json'
        Write-Output "APPLIED | alias=$($record.Alias) | fields=$($changedFields -join ',')"
    }
}
finally {
    Disconnect-MgGraph | Out-Null
}
