[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$ProjectRoot,
    [string]$OutputDirectory
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
    $OutputDirectory = Join-Path $PSScriptRoot '..\docs\communications\ready-to-publish\post-01'
}
$OutputDirectory = [System.IO.Path]::GetFullPath($OutputDirectory)
New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null

function Copy-Image([string]$Source, [string]$Name) {
    if (-not (Test-Path -LiteralPath $Source)) { throw "Image not found: $Source" }
    Copy-Item -LiteralPath $Source -Destination (Join-Path $OutputDirectory $Name) -Force
}

Copy-Image `
    -Source (Join-Path $PSScriptRoot '..\docs\communications\visuals\post-01-hr-to-birthright-access.png') `
    -Name '01-architecture-and-evidence-boundary.png'

# The corrected policy-mapping visual is generated separately by
# New-LinkedInPost01PolicyMapping.ps1 and rendered from SVG to PNG.

$groupSource = Join-Path $ProjectRoot 'evidence-raw\2026-09-28\NEW - members by group.png'
$sourceImage = [System.Drawing.Bitmap]::new($groupSource)
try {
    # Keep only the aggregate result table. This removes commands, Graph URLs and the local shell path.
    $cropTop = [Math]::Min(450, $sourceImage.Height - 1)
    $cropHeight = $sourceImage.Height - $cropTop
    $crop = [System.Drawing.Bitmap]::new($sourceImage.Width, $cropHeight)
    try {
        $graphics = [System.Drawing.Graphics]::FromImage($crop)
        try {
            $graphics.DrawImage(
                $sourceImage,
                [System.Drawing.Rectangle]::new(0, 0, $crop.Width, $crop.Height),
                [System.Drawing.Rectangle]::new(0, $cropTop, $sourceImage.Width, $cropHeight),
                [System.Drawing.GraphicsUnit]::Pixel
            )
        }
        finally { $graphics.Dispose() }
        $crop.Save((Join-Path $OutputDirectory '03-department-group-reconciliation.png'), [System.Drawing.Imaging.ImageFormat]::Png)
    }
    finally { $crop.Dispose() }
}
finally { $sourceImage.Dispose() }

Copy-Image `
    -Source (Join-Path $ProjectRoot 'evidence-raw\2026-09-28\NEW - 13 licenses.png') `
    -Name '04-group-based-licensing.png'

Get-ChildItem -LiteralPath $OutputDirectory -Filter '*.png' | Sort-Object Name | Select-Object Name, Length
