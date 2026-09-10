[CmdletBinding()]
param(
    [string]$FileName = 'Documentation.html'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$templatePath = Join-Path $PSScriptRoot 'DocTemplate.html'
if (-not (Test-Path -LiteralPath $templatePath -PathType Leaf)) {
    throw "Template file not found: $templatePath"
}

if ([System.IO.Path]::GetFileName($FileName) -ne $FileName -or
    [System.IO.Path]::GetExtension($FileName) -ne '.html' -or
    $FileName -ieq 'index.html') {
    throw "FileName must be an HTML leaf name other than index.html: $FileName"
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
$releasesRoot = [System.IO.Path]::GetFullPath((Join-Path $sourceRoot 'releases'))
$requiredPrefix = $sourceRoot + [System.IO.Path]::DirectorySeparatorChar
if (-not $releasesRoot.StartsWith($requiredPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "The resolved releases directory is outside the source folder: $releasesRoot"
}

$versionDirectory = [System.IO.Path]::GetFullPath((Join-Path $releasesRoot $templateVersion))
$releasePrefix = $releasesRoot + [System.IO.Path]::DirectorySeparatorChar
if (-not $versionDirectory.StartsWith($releasePrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "The resolved version directory is outside the source folder: $versionDirectory"
}

$baseName = [System.IO.Path]::GetFileNameWithoutExtension($FileName)
$isReleaseBaseline = $FileName -ieq 'Documentation.html'
$workspaceName = if ($isReleaseBaseline) { 'workspace' } else { "workspace-$baseName" }
$workspaceDirectory = Join-Path $versionDirectory $workspaceName
New-Item -ItemType Directory -Path $workspaceDirectory -Force | Out-Null
$targetPath = Join-Path $workspaceDirectory $FileName
Copy-Item -LiteralPath $templatePath -Destination $targetPath -Force
$assetsPath = Join-Path $workspaceDirectory 'assets'
New-Item -ItemType Directory -Path $assetsPath -Force | Out-Null

$sourceHash = (Get-FileHash -LiteralPath $templatePath -Algorithm SHA256).Hash
$targetHash = (Get-FileHash -LiteralPath $targetPath -Algorithm SHA256).Hash
if ($sourceHash -ne $targetHash) {
    throw "The copied template does not match the source: $targetPath"
}

$promptName = if ($isReleaseBaseline) { 'prompt.md' } else { "prompt-$baseName.md" }
$promptPath = Join-Path $versionDirectory $promptName
$prompt = "Read the file `"$targetPath`" and execute the instructions it contains. Do nothing else."
[System.IO.File]::WriteAllText($promptPath, $prompt + [Environment]::NewLine, [System.Text.UTF8Encoding]::new($false))

Write-Output "Template version: $templateVersion"
Write-Output "Test copy: $targetPath"
Write-Output "Prompt: $promptPath"
