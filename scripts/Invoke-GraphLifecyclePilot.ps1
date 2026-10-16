[CmdletBinding()]
param(
    [string]$InputPath = (Join-Path $PSScriptRoot '..\data\hr-live-pilot.csv'),
    [string]$OutputDirectory = (Join-Path $PSScriptRoot '..\outputs\live-pilot'),
    [switch]$UseDeviceCode,
    [switch]$Apply,
    [string]$ApprovedPlanHash
)

$ErrorActionPreference = 'Stop'

function Get-Sha256Text {
    param([Parameter(Mandatory)][string]$Text)
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
        return ([System.BitConverter]::ToString($sha.ComputeHash($bytes))).Replace('-', '')
    }
    finally { $sha.Dispose() }
}

function New-RandomPassword {
    $bytes = New-Object byte[] 24
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    try { $rng.GetBytes($bytes) } finally { $rng.Dispose() }
    return 'Aa1!' + ([Convert]::ToBase64String($bytes) -replace '[+/=]', 'x')
}

if (-not (Test-Path -LiteralPath $InputPath)) { throw "Input file not found: $InputPath" }
$records = @(Import-Csv -LiteralPath $InputPath | Sort-Object EmployeeId)
if ($records.Count -eq 0) { throw 'Live pilot input is empty.' }
if ($records.Count -gt 20) { throw 'Live pilot safety limit is 20 records.' }

$tenantDomain = Read-Host 'Enter the verified tenant domain only (for example tenant.onmicrosoft.com)'
if ($tenantDomain -notmatch '^[a-zA-Z0-9.-]+\.onmicrosoft\.com$') {
    throw 'Expected a verified onmicrosoft.com tenant domain.'
}

Import-Module Microsoft.Graph.Authentication -ErrorAction Stop
$requiredScope = if ($Apply) { 'User.ReadWrite.All' } else { 'User.Read.All' }
$connect = @{ Scopes = $requiredScope; NoWelcome = $true; ContextScope = 'Process' }
if ($UseDeviceCode) { $connect.UseDeviceCode = $true }
Connect-MgGraph @connect

try {
    New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
    $changes = [System.Collections.Generic.List[object]]::new()
    $existingByEmployeeId = @{}

    foreach ($record in $records) {
        $upn = "$($record.UserAlias)@$tenantDomain"
        $encodedUpn = [uri]::EscapeDataString($upn)
        $existing = $null
        try {
            $existing = Invoke-MgGraphRequest -Method GET -Uri "/v1.0/users/$encodedUpn`?`$select=id,department,jobTitle,employeeType,employeeId,accountEnabled"
        }
        catch {
            if ($_.Exception.Message -notmatch '404|Request_ResourceNotFound|does not exist') { throw }
        }

        $action = if ($null -eq $existing) { 'Create' } else { 'Update' }
        if ($null -ne $existing -and
            [string]$existing.department -ceq [string]$record.Department -and
            [string]$existing.jobTitle -ceq [string]$record.JobTitle -and
            [string]$existing.employeeType -ceq [string]$record.EmployeeType -and
            [string]$existing.employeeId -ceq [string]$record.EmployeeId -and
            [bool]$existing.accountEnabled) {
            $action = 'NoChange'
        }

        $changes.Add([ordered]@{
            EmployeeId       = $record.EmployeeId
            UserAlias        = $record.UserAlias
            Action           = $action
            Department       = $record.Department
            JobTitle         = $record.JobTitle
            EmployeeType     = $record.EmployeeType
            ManagerEmployeeId = $record.ManagerEmployeeId
            CountryCode      = $record.CountryCode
        })
        if ($null -ne $existing) { $existingByEmployeeId[$record.EmployeeId] = $existing.id }
    }

    $canonicalPlan = @($changes) | ConvertTo-Json -Depth 6 -Compress
    $planHash = Get-Sha256Text -Text $canonicalPlan
    $plan = [ordered]@{
        GeneratedAt = [DateTimeOffset]::Now.ToString('o')
        PlanSha256  = $planHash
        Total       = $changes.Count
        Creates     = @($changes | Where-Object Action -EQ 'Create').Count
        Updates     = @($changes | Where-Object Action -EQ 'Update').Count
        NoChange    = @($changes | Where-Object Action -EQ 'NoChange').Count
        Changes     = @($changes)
    }
    $planPath = Join-Path $OutputDirectory 'graph-pilot-plan.json'
    $plan | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $planPath -Encoding utf8

    if (-not $Apply) {
        [pscustomobject]@{
            Mode       = 'PLAN ONLY'
            Total      = $plan.Total
            Creates    = $plan.Creates
            Updates    = $plan.Updates
            NoChange   = $plan.NoChange
            PlanSha256 = $planHash
            PlanPath   = (Resolve-Path -LiteralPath $planPath).Path
        }
        return
    }

    if ([string]::IsNullOrWhiteSpace($ApprovedPlanHash) -or $ApprovedPlanHash -cne $planHash) {
        throw "Apply blocked. ApprovedPlanHash does not match the current deterministic plan hash: $planHash"
    }

    $encryptedCredentials = [System.Collections.Generic.List[object]]::new()
    $userIdByEmployeeId = @{}

    foreach ($record in $records) {
        $change = $changes | Where-Object EmployeeId -EQ $record.EmployeeId
        $upn = "$($record.UserAlias)@$tenantDomain"
        $body = [ordered]@{
            accountEnabled = $true
            displayName    = "$($record.GivenName) $($record.Surname)"
            givenName      = $record.GivenName
            surname        = $record.Surname
            department     = $record.Department
            jobTitle       = $record.JobTitle
            employeeType   = $record.EmployeeType
            employeeId     = $record.EmployeeId
            usageLocation  = $record.CountryCode
        }

        if ($change.Action -eq 'Create') {
            $password = New-RandomPassword
            $body.mailNickname = $record.UserAlias.Replace('.', '')
            $body.userPrincipalName = $upn
            $body.passwordProfile = @{
                forceChangePasswordNextSignIn = $true
                password = $password
            }
            $created = Invoke-MgGraphRequest -Method POST -Uri '/v1.0/users' -Body ($body | ConvertTo-Json -Depth 5 -Compress) -ContentType 'application/json'
            $userIdByEmployeeId[$record.EmployeeId] = $created.id
            $encryptedCredentials.Add([pscustomobject]@{
                UserAlias = $record.UserAlias
                EncryptedPassword = ConvertFrom-SecureString (ConvertTo-SecureString $password -AsPlainText -Force)
            })
        }
        elseif ($change.Action -eq 'Update') {
            $encodedUpn = [uri]::EscapeDataString($upn)
            Invoke-MgGraphRequest -Method PATCH -Uri "/v1.0/users/$encodedUpn" -Body ($body | ConvertTo-Json -Depth 5 -Compress) -ContentType 'application/json'
            $userIdByEmployeeId[$record.EmployeeId] = $existingByEmployeeId[$record.EmployeeId]
        }
        else {
            $userIdByEmployeeId[$record.EmployeeId] = $existingByEmployeeId[$record.EmployeeId]
        }
    }

    foreach ($record in $records | Where-Object { -not [string]::IsNullOrWhiteSpace($_.ManagerEmployeeId) }) {
        $userId = $userIdByEmployeeId[$record.EmployeeId]
        $managerId = $userIdByEmployeeId[$record.ManagerEmployeeId]
        if ([string]::IsNullOrWhiteSpace($userId) -or [string]::IsNullOrWhiteSpace($managerId)) {
            throw "Manager assignment cannot resolve the approved pilot hierarchy for employee '$($record.EmployeeId)'."
        }
        $managerBody = @{ '@odata.id' = "https://graph.microsoft.com/v1.0/users/$managerId" } | ConvertTo-Json -Compress
        Invoke-MgGraphRequest -Method PUT -Uri "/v1.0/users/$userId/manager/`$ref" -Body $managerBody -ContentType 'application/json'
    }

    if ($encryptedCredentials.Count -gt 0) {
        $credentialDirectory = Join-Path $env:LOCALAPPDATA 'VCHIdentityLab'
        New-Item -ItemType Directory -Force -Path $credentialDirectory | Out-Null
        $credentialPath = Join-Path $credentialDirectory 'pilot-credentials.dpapi.xml'
        $encryptedCredentials | Export-Clixml -LiteralPath $credentialPath
    }

    [pscustomobject]@{
        Mode       = 'APPLIED'
        Total      = $plan.Total
        Creates    = $plan.Creates
        Updates    = $plan.Updates
        NoChange   = $plan.NoChange
        PlanSha256 = $planHash
        Credentials = if ($encryptedCredentials.Count -gt 0) { 'Stored outside repository with Windows DPAPI' } else { 'No new credentials generated' }
    }
}
finally {
    Disconnect-MgGraph -ErrorAction SilentlyContinue | Out-Null
}
