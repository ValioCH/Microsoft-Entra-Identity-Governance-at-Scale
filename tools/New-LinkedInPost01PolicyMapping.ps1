[CmdletBinding()]
param([string]$OutputPath)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $OutputPath = Join-Path $PSScriptRoot '..\docs\communications\ready-to-publish\post-01\02-birthright-policy-mapping.svg'
}
$OutputPath = [System.IO.Path]::GetFullPath($OutputPath)
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $OutputPath) | Out-Null

$svg = @'
<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="1050" viewBox="0 0 1200 1050" role="img">
  <style>
    text { font-family: "Segoe UI", Arial, sans-serif; }
    .kicker { font-size: 18px; font-weight: 700; letter-spacing: 1.6px; fill: #2563EB; }
    .title { font-size: 42px; font-weight: 750; fill: #0F172A; }
    .subtitle { font-size: 21px; fill: #475569; }
    .head { font-size: 17px; font-weight: 700; fill: #FFFFFF; }
    .cell { font-size: 17px; fill: #1E293B; }
    .cell-strong { font-size: 17px; font-weight: 650; fill: #0F172A; }
    .status { font-size: 14px; font-weight: 750; letter-spacing: .7px; }
    .note-title { font-size: 17px; font-weight: 750; fill: #9F1239; letter-spacing: 1px; }
    .note { font-size: 19px; fill: #4C0519; }
    .footer { font-size: 15px; fill: #64748B; }
  </style>
  <rect width="1200" height="1050" fill="#F8FAFC"/>
  <rect width="18" height="1050" fill="#2563EB"/>
  <text x="70" y="62" class="kicker">BIRTHRIGHT ACCESS POLICY</text>
  <text x="70" y="125" class="title">HR facts do not assign permissions directly</text>
  <text x="70" y="165" class="subtitle">IAM translates approved workforce facts into controlled, low-risk access decisions.</text>

  <rect x="70" y="215" width="1060" height="54" rx="10" fill="#0F3B66"/>
  <text x="90" y="249" class="head">SOURCE FACT / CONDITION</text>
  <text x="385" y="249" class="head">CALCULATED IAM RESULT</text>
  <text x="890" y="249" class="head">EVIDENCE STATE</text>

  <g>
    <rect x="70" y="279" width="1060" height="82" fill="#FFFFFF" stroke="#CBD5E1"/>
    <text x="90" y="314" class="cell-strong">Active LAB workforce</text><text x="90" y="340" class="cell">and account enabled</text>
    <text x="385" y="314" class="cell-strong">Active-workforce dynamic group</text><text x="385" y="340" class="cell">Pilot E5 assigned through that group</text>
    <rect x="890" y="301" width="170" height="32" rx="16" fill="#CCFBF1"/><text x="975" y="323" text-anchor="middle" class="status" fill="#0F766E">VERIFIED LIVE</text>

    <rect x="70" y="361" width="1060" height="82" fill="#EFF6FF" stroke="#CBD5E1"/>
    <text x="90" y="396" class="cell-strong">Department</text><text x="90" y="422" class="cell">HR / Finance / IT / Sales / Operations</text>
    <text x="385" y="396" class="cell-strong">Department dynamic group</text><text x="385" y="422" class="cell">Collaboration scope; no administrative role</text>
    <rect x="890" y="383" width="170" height="32" rx="16" fill="#CCFBF1"/><text x="975" y="405" text-anchor="middle" class="status" fill="#0F766E">VERIFIED LIVE</text>

    <rect x="70" y="443" width="1060" height="82" fill="#FFFFFF" stroke="#CBD5E1"/>
    <text x="90" y="478" class="cell-strong">Employee / Contractor</text><text x="90" y="504" class="cell">authoritative worker type</text>
    <text x="385" y="478" class="cell-strong">Separate workforce governance decisions</text><text x="385" y="504" class="cell">Contractor scope kept distinct from employee policy</text>
    <rect x="890" y="465" width="170" height="32" rx="16" fill="#DBEAFE"/><text x="975" y="487" text-anchor="middle" class="status" fill="#1D4ED8">OFFLINE POLICY</text>

    <rect x="70" y="525" width="1060" height="82" fill="#EFF6FF" stroke="#CBD5E1"/>
    <text x="90" y="560" class="cell-strong">Location</text><text x="90" y="586" class="cell">Sofia / Varna / Bucharest</text>
    <text x="385" y="560" class="cell-strong">Location governance group</text><text x="385" y="586" class="cell">Prepared as a deterministic policy decision</text>
    <rect x="890" y="547" width="170" height="32" rx="16" fill="#DBEAFE"/><text x="975" y="569" text-anchor="middle" class="status" fill="#1D4ED8">OFFLINE POLICY</text>

    <rect x="70" y="607" width="1060" height="82" fill="#FFFFFF" stroke="#CBD5E1"/>
    <text x="90" y="642" class="cell-strong">PreHire</text><text x="90" y="668" class="cell">not yet an active worker</text>
    <text x="385" y="642" class="cell-strong">Staging group only</text><text x="385" y="668" class="cell">No active-workforce access</text>
    <rect x="890" y="629" width="170" height="32" rx="16" fill="#DBEAFE"/><text x="975" y="651" text-anchor="middle" class="status" fill="#1D4ED8">OFFLINE POLICY</text>

    <rect x="70" y="689" width="1060" height="96" fill="#EFF6FF" stroke="#CBD5E1"/>
    <text x="90" y="727" class="cell-strong">Disable / LeaveScheduled</text><text x="90" y="753" class="cell">lifecycle state changed</text>
    <text x="385" y="722" class="cell-strong">Remove calculated birthright access</text><text x="385" y="748" class="cell">Residual assigned access flagged for reconciliation</text>
    <rect x="890" y="713" width="210" height="32" rx="16" fill="#FEF3C7"/><text x="995" y="735" text-anchor="middle" class="status" fill="#92400E">LIVE FINDING</text>
  </g>

  <rect x="70" y="830" width="1060" height="130" rx="18" fill="#FFF1F2" stroke="#FECDD3"/>
  <text x="95" y="867" class="note-title">PRIVILEGE BOUNDARY</text>
  <text x="95" y="906" class="note">No HR attribute grants an Entra role, Azure RBAC role or PIM eligibility.</text>
  <text x="95" y="936" class="note">Privileged access follows a separate identity, approval and activation lifecycle.</text>
  <text x="70" y="1010" class="footer">EV-IG-003-006 | Access Packages intentionally excluded: they were not implemented in this pilot.</text>
</svg>
'@

[System.IO.File]::WriteAllText($OutputPath, $svg, [System.Text.UTF8Encoding]::new($false))
Get-Item -LiteralPath $OutputPath | Select-Object FullName, Length
