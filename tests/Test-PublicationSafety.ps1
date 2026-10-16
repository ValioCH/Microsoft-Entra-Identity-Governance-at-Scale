[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$excludedDirectoryNames = @('evidence-raw', 'No', 'node_modules', '.git')
$excludedRelativePrefixes = @('docs\communications\ready-to-publish\')
$binaryExtensions = @('.png', '.jpg', '.jpeg', '.xlsx', '.docx')

$patterns = [ordered]@{
    EmailAddress = '(?i)\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b'
    GuidIdentifier = '(?i)\b[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\b'
    WindowsUserPath = '(?i)\b[A-Z]:\\Users\\[^\\\s]+'
    WorkspacePath = '(?i)\b[A-Z]:\\0-cyber\\'
    LiveTenantDomain = '(?i)\b(?!tenant\.onmicrosoft\.com\b)[A-Z0-9.-]+\.onmicrosoft\.com\b'
    HardcodedSecret = '(?i)\b(client[_-]?secret|access[_-]?token|refresh[_-]?token|password)\s*[:=]\s*["''][^"'']{8,}["'']'
    BearerToken = '(?i)\bbearer\s+[A-Za-z0-9._-]{20,}'
}

$files = Get-ChildItem -LiteralPath $repoRoot -Recurse -File | Where-Object {
    $relative = $_.FullName.Substring($repoRoot.Length + 1)
    $directoryParts = $relative -split '[\\/]'
    $excludedByDirectory = @($directoryParts | Where-Object { $_ -in $excludedDirectoryNames }).Count -gt 0
    $excludedByPrefix = @($excludedRelativePrefixes | Where-Object { $relative.StartsWith($_, [System.StringComparison]::OrdinalIgnoreCase) }).Count -gt 0
    -not $excludedByDirectory -and -not $excludedByPrefix -and $_.Extension.ToLowerInvariant() -notin $binaryExtensions
}

$findings = [System.Collections.Generic.List[object]]::new()
foreach ($file in $files) {
    $content = Get-Content -LiteralPath $file.FullName -Raw -ErrorAction Stop
    foreach ($entry in $patterns.GetEnumerator()) {
        $matches = [regex]::Matches($content, $entry.Value)
        foreach ($match in $matches) {
            $lineNumber = ($content.Substring(0, $match.Index) -split "`n").Count
            $findings.Add([pscustomobject]@{
                Pattern = $entry.Key
                File = $file.FullName.Substring($repoRoot.Length + 1)
                Line = $lineNumber
                Match = $match.Value
            })
        }
    }
}

Add-Type -AssemblyName System.IO.Compression.FileSystem
$xlsxFiles = Get-ChildItem -LiteralPath $repoRoot -Recurse -File -Filter *.xlsx | Where-Object {
    $relative = $_.FullName.Substring($repoRoot.Length + 1)
    $parts = $relative -split '[\\/]'
    @($parts | Where-Object { $_ -in $excludedDirectoryNames }).Count -eq 0
}
foreach ($xlsx in $xlsxFiles) {
    $archive = [System.IO.Compression.ZipFile]::OpenRead($xlsx.FullName)
    try {
        foreach ($entry in $archive.Entries | Where-Object { $_.FullName -match '\.(xml|rels)$' }) {
            $reader = [System.IO.StreamReader]::new($entry.Open())
            try { $content = $reader.ReadToEnd() } finally { $reader.Dispose() }
            foreach ($pattern in $patterns.GetEnumerator()) {
                foreach ($match in [regex]::Matches($content, $pattern.Value)) {
                    $findings.Add([pscustomobject]@{
                        Pattern = $pattern.Key
                        File = $xlsx.FullName.Substring($repoRoot.Length + 1) + '::' + $entry.FullName
                        Line = 0
                        Match = $match.Value
                    })
                }
            }
        }
    }
    finally { $archive.Dispose() }
}

if ($findings.Count -gt 0) {
    $findings | Sort-Object File, Line, Pattern | Format-Table -AutoSize | Out-String | Write-Error
    throw "Publication safety scan failed with $($findings.Count) finding(s)."
}

[pscustomobject]@{
    Status = 'PASS'
    TextFilesScanned = $files.Count
    WorkbooksScanned = $xlsxFiles.Count
    Findings = 0
    ExcludedRawEvidence = $true
    ExcludedReadyToPublishWorkingCopies = $true
}
