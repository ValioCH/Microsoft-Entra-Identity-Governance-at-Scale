[CmdletBinding()]
param(
    [string]$OutputDirectory
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
    $OutputDirectory = Join-Path $PSScriptRoot '..\docs\communications\visuals'
}
$OutputDirectory = [System.IO.Path]::GetFullPath($OutputDirectory)
New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null

function X([string]$Value) {
    [System.Security.SecurityElement]::Escape($Value)
}

function Text-Lines {
    param([string[]]$Lines, [int]$X, [int]$Y, [string]$Class, [int]$Gap = 30, [string]$Anchor = 'start')
    $parts = for ($i = 0; $i -lt $Lines.Count; $i++) {
        '<text x="{0}" y="{1}" class="{2}" text-anchor="{3}">{4}</text>' -f $X, ($Y + $i * $Gap), $Class, $Anchor, (X $Lines[$i])
    }
    $parts -join "`n"
}

function New-SeriesVisual {
    param(
        [string]$FileName,
        [string]$Number,
        [string[]]$Title,
        [string[]]$Problem,
        [array]$Flow,
        [array]$Tests,
        [array]$Metrics,
        [string[]]$Boundary,
        [string]$Evidence,
        [string]$Accent = '#2563EB'
    )

    $flowWidth = [math]::Floor(1040 / $Flow.Count)
    $flowSvg = for ($i = 0; $i -lt $Flow.Count; $i++) {
        $x = 80 + $i * $flowWidth
        $lines = @($Flow[$i].Lines)
        $arrow = if ($i -lt $Flow.Count - 1) { '<text x="{0}" y="476" class="arrow">&gt;</text>' -f ($x + $flowWidth - 15) } else { '' }
        @"
<rect x="$x" y="395" width="$($flowWidth - 30)" height="140" rx="18" class="flow-box"/>
<circle cx="$($x + 30)" cy="427" r="17" fill="$Accent"/>
<text x="$($x + 30)" y="434" class="step" text-anchor="middle">$($i + 1)</text>
$(Text-Lines -Lines $lines -X ($x + 20) -Y 470 -Class 'flow-text' -Gap 26)
$arrow
"@
    }

    $testWidth = [math]::Floor(1040 / $Tests.Count)
    $testSvg = for ($i = 0; $i -lt $Tests.Count; $i++) {
        $x = 80 + $i * $testWidth
        $label = X $Tests[$i].Label
        $lines = @($Tests[$i].Lines)
        $kind = X $Tests[$i].Kind
        @"
<rect x="$x" y="650" width="$($testWidth - 20)" height="218" rx="18" class="test-box"/>
<rect x="$($x + 18)" y="670" width="150" height="32" rx="16" fill="#E0E7FF"/>
<text x="$($x + 93)" y="692" class="chip" text-anchor="middle">$kind</text>
<text x="$($x + 18)" y="742" class="test-title">$label</text>
$(Text-Lines -Lines $lines -X ($x + 18) -Y 782 -Class 'body' -Gap 27)
"@
    }

    $metricWidth = [math]::Floor(1040 / $Metrics.Count)
    $metricSvg = for ($i = 0; $i -lt $Metrics.Count; $i++) {
        $x = 80 + $i * $metricWidth
        @"
<rect x="$x" y="955" width="$($metricWidth - 20)" height="125" rx="16" class="metric-box"/>
<text x="$($x + 18)" y="1007" class="metric" fill="$Accent">$(X $Metrics[$i].Value)</text>
<text x="$($x + 18)" y="1044" class="metric-label">$(X $Metrics[$i].Label)</text>
"@
    }

    $svg = @"
<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="1350" viewBox="0 0 1200 1350" role="img">
<style>
text { font-family: "Segoe UI", Arial, sans-serif; }
.kicker { font-size: 18px; font-weight: 700; letter-spacing: 1.8px; fill: $Accent; }
.number { font-size: 17px; font-weight: 700; fill: $Accent; }
.title { font-size: 47px; font-weight: 750; fill: #0F172A; }
.question { font-size: 23px; font-weight: 600; fill: #1E293B; }
.section { font-size: 17px; font-weight: 750; letter-spacing: 1.3px; fill: #64748B; }
.flow-box, .test-box, .metric-box { fill: #FFFFFF; stroke: #CBD5E1; stroke-width: 2; }
.flow-text { font-size: 20px; font-weight: 650; fill: #1E293B; }
.step { font-size: 18px; font-weight: 750; fill: #FFFFFF; }
.arrow { font-size: 54px; font-weight: 300; fill: #94A3B8; }
.chip { font-size: 14px; font-weight: 750; letter-spacing: 1px; fill: #3730A3; }
.test-title { font-size: 23px; font-weight: 700; fill: #0F172A; }
.body { font-size: 18px; fill: #475569; }
.metric { font-size: 34px; font-weight: 750; }
.metric-label { font-size: 17px; fill: #475569; }
.boundary-title { font-size: 17px; font-weight: 750; letter-spacing: 1px; fill: #9F1239; }
.boundary { font-size: 19px; fill: #4C0519; }
.evidence { font-size: 15px; fill: #64748B; }
</style>
<rect width="1200" height="1350" fill="#F8FAFC"/>
<rect width="18" height="1350" fill="$Accent"/>
<text x="80" y="66" class="kicker">ENTERPRISE IDENTITY GOVERNANCE AT SCALE</text>
<rect x="932" y="38" width="188" height="44" rx="22" fill="#DBEAFE"/>
<text x="1026" y="66" class="number" text-anchor="middle">IMPLEMENTATION</text>
$(Text-Lines -Lines $Title -X 80 -Y 145 -Class 'title' -Gap 56)
<rect x="80" y="265" width="1040" height="88" rx="18" fill="#EFF6FF" stroke="#BFDBFE"/>
$(Text-Lines -Lines $Problem -X 110 -Y 305 -Class 'question' -Gap 30)
<text x="80" y="380" class="section">DESIGN BEFORE AUTOMATION</text>
$($flowSvg -join "`n")
<text x="80" y="628" class="section">WHAT WAS ACTUALLY TESTED</text>
$($testSvg -join "`n")
<text x="80" y="932" class="section">OBSERVED RESULT</text>
$($metricSvg -join "`n")
<rect x="80" y="1135" width="1040" height="142" rx="18" fill="#FFF1F2" stroke="#FECDD3"/>
<text x="105" y="1170" class="boundary-title">EVIDENCE BOUNDARY</text>
$(Text-Lines -Lines $Boundary -X 105 -Y 1207 -Class 'boundary' -Gap 28)
<text x="80" y="1320" class="evidence">$(X $Evidence)</text>
</svg>
"@

    [System.IO.File]::WriteAllText((Join-Path $OutputDirectory $FileName), $svg, [System.Text.UTF8Encoding]::new($false))
}

New-SeriesVisual -FileName 'post-01-hr-to-birthright-access.svg' -Number '1' `
    -Title @('From HR facts to', 'governed birthright access') `
    -Problem @('How do we avoid 1,000 manual tickets', 'without letting HR attributes create privilege?') `
    -Flow @(
        @{ Lines=@('HR facts', 'status / dept.', 'manager / location') },
        @{ Lines=@('Validate', 'schema / values', 'references') },
        @{ Lines=@('IAM policy', 'groups / license', 'no admin roles') },
        @{ Lines=@('Approve / apply', 'verify state', 'record evidence') }
    ) `
    -Tests @(
        @{ Kind='REVIEWABLE MODEL'; Label='20 synthetic records'; Lines=@('Makes source fields and', 'IAM mappings inspectable.') },
        @{ Kind='VERIFIED LIVE'; Label='2 + 10 identities'; Lines=@('JML behavior, dynamic', 'groups, licensing, rerun.') },
        @{ Kind='OFFLINE SCALE'; Label='1,000 records'; Lines=@('Validation and change-plan', 'generation only.') }
    ) `
    -Metrics @(
        @{ Value='915'; Label='planned creates' },
        @{ Value='57'; Label='planned updates' },
        @{ Value='28'; Label='planned disables' },
        @{ Value='0'; Label='validation errors' }
    ) `
    -Boundary @('1,000 identities were not provisioned into Entra.', 'This validates preflight and policy logic - not production throughput.') `
    -Evidence 'EV-IG-002-006 | HR owns facts; IAM owns access policy.'

New-SeriesVisual -FileName 'post-02-privileged-access.svg' -Number '2' `
    -Title @('Privilege is a', 'separate lifecycle') `
    -Problem @('Department = IT must never mean', 'automatic administrative privilege.') `
    -Flow @(
        @{ Lines=@('Separate', 'Tier 2 admin', 'identity') },
        @{ Lines=@('Role group', 'explicit governed', 'membership') },
        @{ Lines=@('PIM eligible', 'MFA / ticket', 'approval') },
        @{ Lines=@('1-hour task', 'audit / rollback', 'expiry') }
    ) `
    -Tests @(
        @{ Kind='BEFORE'; Label='No standing role'; Lines=@('Eligible assignment;', 'active assignments empty.') },
        @{ Kind='VERIFIED LIVE'; Label='Controlled action'; Lines=@('Group change completed', 'and actor audited.') },
        @{ Kind='AFTER'; Label='Automatic expiry'; Lines=@('Active role removed;', 'eligibility retained.') }
    ) `
    -Metrics @(
        @{ Value='MFA'; Label='required' },
        @{ Value='1 h'; Label='activation used' },
        @{ Value='2'; Label='approvers configured' },
        @{ Value='0'; Label='active after expiry' }
    ) `
    -Boundary @('One Tier 2 identity and one Groups Administrator role were tested.', 'Tier 0/1 and enterprise rollout remain architecture - not verified deployment.') `
    -Evidence 'EV-IG-007 | Separate operator, approver and audit-verification responsibilities.' -Accent '#0F766E'

New-SeriesVisual -FileName 'post-03-human-access-review.svg' -Number '3' `
    -Title @('Recommendation is', 'not authorization') `
    -Problem @('What happens when an inactivity signal', 'conflicts with current operational evidence?') `
    -Flow @(
        @{ Lines=@('Privileged', 'role group', 'review scope') },
        @{ Lines=@('My Access', 'delegated', 'reviewer task') },
        @{ Lines=@('Signals', 'recommendation', 'PIM evidence') },
        @{ Lines=@('Decision', 'justification', 'audit trail') }
    ) `
    -Tests @(
        @{ Kind='AUTOMATION'; Label='Deny recommendation'; Lines=@('Inactivity over 30 days', 'was used as a helper.') },
        @{ Kind='HUMAN CONTROL'; Label='Approve decision'; Lines=@('Recent PIM evidence', 'supported retention.') },
        @{ Kind='VERIFIED LIVE'; Label='Auditable outcome'; Lines=@('Reviewer, date and reason', 'were recorded.') }
    ) `
    -Metrics @(
        @{ Value='Deny'; Label='system suggested' },
        @{ Value='Approve'; Label='reviewer decided' },
        @{ Value='1'; Label='justified decision' },
        @{ Value='1'; Label='member retained' }
    ) `
    -Boundary @('This live pilot covered one privileged identity.', 'Two reviewers in one stage are alternatives - not four-eyes approval.') `
    -Evidence 'EV-IG-008 | My Access for decision; Entra admin center for monitoring.' -Accent '#7C3AED'

New-SeriesVisual -FileName 'post-04-review-operating-model.svg' -Number '4' `
    -Title @('1,000 reviews without', 'one central bottleneck') `
    -Problem @('Scale requires accountable routing and capacity limits,', 'not 1,000 decisions assigned to one administrator.') `
    -Flow @(
        @{ Lines=@('Population', '1,000 synthetic', 'identities') },
        @{ Lines=@('Policy', 'lifecycle / activity', 'privilege precedence') },
        @{ Lines=@('Route', 'department', '+ location') },
        @{ Lines=@('Gate', 'max 100 items', 'per reviewer') }
    ) `
    -Tests @(
        @{ Kind='POLICY'; Label='Decision precedence'; Lines=@('Privilege and pre-hire', 'force manual review.') },
        @{ Kind='CAPACITY'; Label='16 reviewer queues'; Lines=@('Maximum load 81;', 'average load 62.5.') },
        @{ Kind='REPEATABILITY'; Label='Matching plan hash'; Lines=@('Second run produced', 'the same output.') }
    ) `
    -Metrics @(
        @{ Value='245'; Label='Approve' },
        @{ Value='726'; Label='Deny' },
        @{ Value='29'; Label='Manual review' },
        @{ Value='0'; Label='queues over 100' }
    ) `
    -Boundary @('The recommendations are deterministic synthetic test pressure.', 'They were not 1,000 live Entra reviews and were not applied to access.') `
    -Evidence 'EV-IG-009 | Tests coverage, ownership, exception routing and workload bounds.' -Accent '#C2410C'

New-SeriesVisual -FileName 'post-05-conditional-access-rollout.svg' -Number '5' `
    -Title @('A controlled No-Go', 'is a security result') `
    -Problem @('A valid policy is not safe to enforce until', 'recovery, readiness and rollback gates pass.') `
    -Flow @(
        @{ Lines=@('Ring 0', 'emergency', 'exclusions') },
        @{ Lines=@('Ring 1', 'privileged', 'pilot') },
        @{ Lines=@('Rings 2-3', 'IT / HR', 'Finance') },
        @{ Lines=@('Ring 4', 'broad', 'workforce') }
    ) `
    -Tests @(
        @{ Kind='LIVE DECISION'; Label='Policy discarded'; Lines=@('Security Defaults stayed', 'enabled; no CA created.') },
        @{ Kind='READINESS MODEL'; Label='95% promotion gate'; Lines=@('MFA gaps block the next', 'deployment ring.') },
        @{ Kind='ROLLBACK FIRST'; Label='Controlled change'; Lines=@('What If, report-only and', 'support precede enforcement.') }
    ) `
    -Metrics @(
        @{ Value='872'; Label='would satisfy MFA' },
        @{ Value='98'; Label='need registration' },
        @{ Value='28'; Label='inactive / untargeted' },
        @{ Value='0 / 4'; Label='rings ready' }
    ) `
    -Boundary @('The rollout model and No-Go decision were validated.', 'No live Conditional Access policy was created or enforced.') `
    -Evidence 'EV-IG-010 | A successful simulation enforced the decision not to deploy.' -Accent '#B91C1C'

Get-ChildItem -LiteralPath $OutputDirectory -Filter '*.svg' | Sort-Object Name | Select-Object Name, Length
