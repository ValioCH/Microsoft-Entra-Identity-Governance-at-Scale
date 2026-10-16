[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$InputPath,

    [Parameter(Mandatory)]
    [string]$TenantDomain,

    [ValidateSet('Plan', 'Apply')]
    [string]$Mode = 'Plan',

    [string]$ApprovedPlanHash
)

$ErrorActionPreference = 'Stop'

function Get-PlainTextToken {
    $tokenResponse = Get-AzAccessToken -ResourceTypeName MSGraph
    if ($tokenResponse.Token -is [securestring]) {
        return [pscredential]::new('token', $tokenResponse.Token).GetNetworkCredential().Password
    }
    return [string]$tokenResponse.Token
}

function Get-Sha256Text {
    param([Parameter(Mandatory)][string]$Text)
    $bytes = [Text.Encoding]::UTF8.GetBytes($Text)
    $hash = [Security.Cryptography.SHA256]::HashData($bytes)
    return [Convert]::ToHexString($hash)
}

function New-RandomPassword {
    $bytes = [byte[]]::new(24)
    [Security.Cryptography.RandomNumberGenerator]::Fill($bytes)
    return 'Aa1!' + (([Convert]::ToBase64String($bytes)) -replace '[+/=]', 'x')
}

function Invoke-Graph {
    param(
        [Parameter(Mandatory)][ValidateSet('GET', 'POST', 'PATCH', 'PUT')][string]$Method,
        [Parameter(Mandatory)][string]$Uri,
        [object]$Body
    )
    $parameters = @{ Method = $Method; Uri = $Uri; Headers = $script:GraphHeaders }
    if ($null -ne $Body) {
        $parameters.Body = ($Body | ConvertTo-Json -Depth 8 -Compress)
        $parameters.ContentType = 'application/json'
    }
    Invoke-RestMethod @parameters
}

if (-not (Test-Path -LiteralPath $InputPath)) { throw "Input file not found: $InputPath" }
if ($TenantDomain -notmatch '^[a-zA-Z0-9.-]+\.onmicrosoft\.com$') { throw 'TenantDomain must be a verified onmicrosoft.com domain.' }

$records = @(Import-Csv -LiteralPath $InputPath | Sort-Object EmployeeId)
if ($records.Count -lt 1 -or $records.Count -gt 20) { throw 'Live batch safety limit is 1-20 records.' }

$requiredColumns = @('EmployeeId','GivenName','Surname','UserAlias','Department','JobTitle','EmployeeType','ManagerEmployeeId','CountryCode','LifecycleAction','EmploymentStatus')
$missingColumns = @($requiredColumns | Where-Object { $_ -notin $records[0].PSObject.Properties.Name })
if ($missingColumns.Count -gt 0) { throw "Missing columns: $($missingColumns -join ', ')" }
if (@($records.EmployeeId | Group-Object | Where-Object Count -gt 1).Count -gt 0) { throw 'Duplicate EmployeeId values found.' }

$script:GraphHeaders = @{ Authorization = "Bearer $(Get-PlainTextToken)" }

$groupDefinitions = @(
    [ordered]@{ Name='SG-PILOT-Active-Workforce'; Rule='(user.employeeId -startsWith "LAB-") -and (user.accountEnabled -eq true)' },
    [ordered]@{ Name='SG-PILOT-DEPT-Executive'; Rule='(user.employeeId -startsWith "LAB-") -and (user.department -eq "Executive") -and (user.accountEnabled -eq true)' },
    [ordered]@{ Name='SG-PILOT-DEPT-HR'; Rule='(user.employeeId -startsWith "LAB-") -and (user.department -eq "HR") -and (user.accountEnabled -eq true)' },
    [ordered]@{ Name='SG-PILOT-DEPT-Finance'; Rule='(user.employeeId -startsWith "LAB-") -and (user.department -eq "Finance") -and (user.accountEnabled -eq true)' },
    [ordered]@{ Name='SG-PILOT-DEPT-IT'; Rule='(user.employeeId -startsWith "LAB-") -and (user.department -eq "IT") -and (user.accountEnabled -eq true)' },
    [ordered]@{ Name='SG-PILOT-DEPT-Sales'; Rule='(user.employeeId -startsWith "LAB-") -and (user.department -eq "Sales") -and (user.accountEnabled -eq true)' },
    [ordered]@{ Name='SG-PILOT-DEPT-Operations'; Rule='(user.employeeId -startsWith "LAB-") -and (user.department -eq "Operations") -and (user.accountEnabled -eq true)' }
)

$existingGroups = @((Invoke-Graph -Method GET -Uri 'https://graph.microsoft.com/v1.0/groups?$select=id,displayName,membershipRule,groupTypes&$top=999').value)
$groupPlan = foreach ($definition in $groupDefinitions) {
    $existing = $existingGroups | Where-Object displayName -CEQ $definition.Name | Select-Object -First 1
    $action = if ($null -eq $existing) { 'Create' } elseif ($existing.membershipRule -ceq $definition.Rule) { 'NoChange' } else { 'ReviewExisting' }
    [ordered]@{ Name=$definition.Name; Action=$action; Rule=$definition.Rule }
}

$userPlan = foreach ($record in $records) {
    $upn = "$($record.UserAlias)@$TenantDomain"
    $encodedUpn = [uri]::EscapeDataString($upn)
    $existing = $null
    try {
        $existing = Invoke-Graph -Method GET -Uri "https://graph.microsoft.com/v1.0/users/$encodedUpn`?`$select=id,department,jobTitle,employeeType,employeeId,accountEnabled"
    }
    catch {
        if ($_.Exception.Response.StatusCode.value__ -ne 404) { throw }
    }

    $action = if ($record.LifecycleAction -eq 'Disable') {
        if ($null -eq $existing) { 'SkipMissingDisable' } elseif (-not [bool]$existing.accountEnabled) { 'NoChange' } else { 'Disable' }
    }
    elseif ($null -eq $existing) { 'Create' }
    elseif (
        [string]$existing.department -ceq [string]$record.Department -and
        [string]$existing.jobTitle -ceq [string]$record.JobTitle -and
        [string]$existing.employeeType -ceq [string]$record.EmployeeType -and
        [string]$existing.employeeId -ceq [string]$record.EmployeeId -and
        [bool]$existing.accountEnabled
    ) { 'NoChange' }
    else { 'Update' }

    [ordered]@{
        EmployeeId=$record.EmployeeId
        Alias=$record.UserAlias
        Action=$action
        Department=$record.Department
        ManagerEmployeeId=$record.ManagerEmployeeId
    }
}

$canonical = [ordered]@{ Groups=@($groupPlan); Users=@($userPlan) } | ConvertTo-Json -Depth 8 -Compress
$planHash = Get-Sha256Text -Text $canonical
$plan = [ordered]@{
    GeneratedAt=[DateTimeOffset]::UtcNow.ToString('o')
    PlanSha256=$planHash
    GroupSummary=[ordered]@{
        Create=@($groupPlan | Where-Object Action -eq 'Create').Count
        NoChange=@($groupPlan | Where-Object Action -eq 'NoChange').Count
        ReviewExisting=@($groupPlan | Where-Object Action -eq 'ReviewExisting').Count
    }
    UserSummary=[ordered]@{
        Create=@($userPlan | Where-Object Action -eq 'Create').Count
        Update=@($userPlan | Where-Object Action -eq 'Update').Count
        Disable=@($userPlan | Where-Object Action -eq 'Disable').Count
        NoChange=@($userPlan | Where-Object Action -eq 'NoChange').Count
        SkipMissingDisable=@($userPlan | Where-Object Action -eq 'SkipMissingDisable').Count
    }
    Groups=@($groupPlan)
    Users=@($userPlan)
}

$plan | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath './identity-batch-plan.json' -Encoding utf8
$plan | Select-Object PlanSha256, GroupSummary, UserSummary

if ($Mode -eq 'Plan') {
    Write-Host 'PLAN ONLY — no Microsoft Entra changes were made.' -ForegroundColor Cyan
    return
}

if ($plan.GroupSummary.ReviewExisting -gt 0) { throw 'Apply blocked: an existing pilot group has a different rule and requires human review.' }
if ([string]::IsNullOrWhiteSpace($ApprovedPlanHash) -or $ApprovedPlanHash -cne $planHash) {
    throw "Apply blocked: ApprovedPlanHash must exactly match $planHash"
}

foreach ($definition in $groupDefinitions) {
    $decision = $groupPlan | Where-Object Name -CEQ $definition.Name
    if ($decision.Action -eq 'Create') {
        $mailNickname = ($definition.Name -replace '[^a-zA-Z0-9]', '').ToLowerInvariant()
        $body = [ordered]@{
            displayName=$definition.Name
            description='Controlled dynamic group for the Enterprise Identity Governance lab pilot'
            mailEnabled=$false
            mailNickname=$mailNickname
            securityEnabled=$true
            groupTypes=@('DynamicMembership')
            membershipRule=$definition.Rule
            membershipRuleProcessingState='On'
        }
        Invoke-Graph -Method POST -Uri 'https://graph.microsoft.com/v1.0/groups' -Body $body | Out-Null
    }
}

$userIdByEmployeeId = @{}
foreach ($record in $records) {
    $decision = $userPlan | Where-Object EmployeeId -CEQ $record.EmployeeId
    $upn = "$($record.UserAlias)@$TenantDomain"
    $encodedUpn = [uri]::EscapeDataString($upn)

    if ($decision.Action -eq 'Create') {
        $body = [ordered]@{
            accountEnabled=$true
            displayName="$($record.GivenName) $($record.Surname)"
            givenName=$record.GivenName
            surname=$record.Surname
            mailNickname=($record.UserAlias -replace '[^a-zA-Z0-9]', '')
            userPrincipalName=$upn
            department=$record.Department
            jobTitle=$record.JobTitle
            employeeType=$record.EmployeeType
            employeeId=$record.EmployeeId
            usageLocation=$record.CountryCode
            passwordProfile=[ordered]@{
                forceChangePasswordNextSignIn=$true
                password=(New-RandomPassword)
            }
        }
        $created = Invoke-Graph -Method POST -Uri 'https://graph.microsoft.com/v1.0/users' -Body $body
        $userIdByEmployeeId[$record.EmployeeId] = $created.id
    }
    elseif ($decision.Action -eq 'Update') {
        $body = [ordered]@{
            accountEnabled=$true
            department=$record.Department
            jobTitle=$record.JobTitle
            employeeType=$record.EmployeeType
            employeeId=$record.EmployeeId
            usageLocation=$record.CountryCode
        }
        Invoke-Graph -Method PATCH -Uri "https://graph.microsoft.com/v1.0/users/$encodedUpn" -Body $body | Out-Null
        $existing = Invoke-Graph -Method GET -Uri "https://graph.microsoft.com/v1.0/users/$encodedUpn`?`$select=id"
        $userIdByEmployeeId[$record.EmployeeId] = $existing.id
    }
    elseif ($decision.Action -eq 'Disable') {
        Invoke-Graph -Method PATCH -Uri "https://graph.microsoft.com/v1.0/users/$encodedUpn" -Body @{ accountEnabled=$false } | Out-Null
    }
    elseif ($decision.Action -eq 'NoChange') {
        $existing = Invoke-Graph -Method GET -Uri "https://graph.microsoft.com/v1.0/users/$encodedUpn`?`$select=id"
        $userIdByEmployeeId[$record.EmployeeId] = $existing.id
    }
}

foreach ($record in $records | Where-Object { $_.LifecycleAction -ne 'Disable' -and -not [string]::IsNullOrWhiteSpace($_.ManagerEmployeeId) }) {
    $userId = $userIdByEmployeeId[$record.EmployeeId]
    $managerId = $userIdByEmployeeId[$record.ManagerEmployeeId]
    if (-not $userId -or -not $managerId) { throw "Manager mapping failed for $($record.EmployeeId)." }
    Invoke-Graph -Method PUT -Uri "https://graph.microsoft.com/v1.0/users/$userId/manager/`$ref" -Body @{ '@odata.id'="https://graph.microsoft.com/v1.0/users/$managerId" } | Out-Null
}

Write-Host 'APPLY COMPLETE — re-run in Plan mode to verify idempotency.' -ForegroundColor Green
