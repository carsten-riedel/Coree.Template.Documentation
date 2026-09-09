[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$templatePath = Join-Path $PSScriptRoot 'DocTemplate.html'
if (-not (Test-Path -LiteralPath $templatePath -PathType Leaf)) {
    throw "Template file not found: $templatePath"
}

$templateContent = Get-Content -LiteralPath $templatePath -Raw
$headMatch = [regex]::Match($templateContent, '(?is)<head\b[^>]*>(?<content>.*?)</head>')
if (-not $headMatch.Success) {
    throw "The template does not contain a live <head> element: $templatePath"
}

$versionMetaMatches = @(
    [regex]::Matches($headMatch.Groups['content'].Value, '(?is)<meta\b[^>]*>') |
        Where-Object {
            $_.Value -match '(?i)\bname\s*=\s*["'']documentation-template-version["'']'
        }
)

if ($versionMetaMatches.Count -ne 1) {
    throw "Expected exactly one documentation-template-version meta element in the live <head>; found $($versionMetaMatches.Count)."
}

$contentMatch = [regex]::Match(
    $versionMetaMatches[0].Value,
    '(?i)\bcontent\s*=\s*["''](?<version>[^"'']+)["'']'
)
if (-not $contentMatch.Success) {
    throw 'The documentation-template-version meta element has no content value.'
}

$templateVersion = $contentMatch.Groups['version'].Value
if ($templateVersion -notmatch '^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?(?:\+[0-9A-Za-z.-]+)?$') {
    throw "The template version is not a valid semantic version: $templateVersion"
}

$sourceRoot = [System.IO.Path]::GetFullPath($PSScriptRoot)
$targetDirectory = [System.IO.Path]::GetFullPath((Join-Path $sourceRoot $templateVersion))
$requiredPrefix = $sourceRoot + [System.IO.Path]::DirectorySeparatorChar
if (-not $targetDirectory.StartsWith($requiredPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "The resolved target directory is outside the source folder: $targetDirectory"
}

New-Item -ItemType Directory -Path $targetDirectory -Force | Out-Null
$targetPath = Join-Path $targetDirectory (Split-Path -Leaf $templatePath)
Copy-Item -LiteralPath $templatePath -Destination $targetPath -Force

$sourceHash = (Get-FileHash -LiteralPath $templatePath -Algorithm SHA256).Hash
$targetHash = (Get-FileHash -LiteralPath $targetPath -Algorithm SHA256).Hash
if ($sourceHash -ne $targetHash) {
    throw "The copied template does not match the source: $targetPath"
}

Write-Output "Template version: $templateVersion"
Write-Output "Test copy: $targetPath"
