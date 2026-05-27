param(
    [Parameter(Mandatory = $true)]
    [string]$SourceMarkdown,

    [string]$PostsDir = "content/posts",

    [string]$BundleName,

    [string]$TyporaImageDir = "$env:APPDATA\\Typora\\typora-user-images"
)

$ErrorActionPreference = "Stop"

function Get-BundleName {
    param([string]$Name)

    $bundleName = [System.IO.Path]::GetFileNameWithoutExtension($Name)
    $bundleName = $bundleName -replace '[<>:"/\\|?*]+', '-'
    $bundleName = $bundleName.Trim()
    if ([string]::IsNullOrWhiteSpace($bundleName)) {
        throw "无法从文件名生成文章目录名: $Name"
    }
    return $bundleName
}

$resolvedMarkdown = (Resolve-Path -LiteralPath $SourceMarkdown).Path
$postName = [System.IO.Path]::GetFileName($resolvedMarkdown)
$bundleName = if ([string]::IsNullOrWhiteSpace($BundleName)) {
    Get-BundleName -Name $postName
} else {
    $BundleName
}
$bundleDir = Join-Path $PostsDir $bundleName
$bundleDir = [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $bundleDir))

New-Item -ItemType Directory -Force -Path $bundleDir | Out-Null

$content = Get-Content -LiteralPath $resolvedMarkdown -Raw

$pattern = '!\[(?<alt>[^\]]*)\]\((?<path>[A-Za-z]:\\[^)]+(?:typora-user-images\\[^)]+))\)'
$matches = [regex]::Matches($content, $pattern)

foreach ($match in $matches) {
    $originalPath = $match.Groups["path"].Value
    $fileName = [System.IO.Path]::GetFileName($originalPath)
    $sourceImage = $originalPath

    if (-not (Test-Path -LiteralPath $sourceImage)) {
        $fallbackImage = Join-Path $TyporaImageDir $fileName
        if (Test-Path -LiteralPath $fallbackImage) {
            $sourceImage = $fallbackImage
        } else {
            throw "找不到图片文件: $originalPath"
        }
    }

    Copy-Item -LiteralPath $sourceImage -Destination (Join-Path $bundleDir $fileName) -Force
    $content = $content.Replace($match.Value, "![$($match.Groups["alt"].Value)]($fileName)")
}

$targetMarkdown = Join-Path $bundleDir "index.md"
Set-Content -LiteralPath $targetMarkdown -Value $content -Encoding UTF8

Write-Output "Imported to $targetMarkdown"
