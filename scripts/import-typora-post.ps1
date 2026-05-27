param(
    [Parameter(Mandatory = $true)]
    [string]$SourceMarkdown,

    [string]$PostsDir = "content/posts",

    [string]$BundleName,

    [string]$TyporaImageDir = "$env:APPDATA\Typora\typora-user-images"
)

$ErrorActionPreference = "Stop"

function Get-BundleName {
    param([string]$Name)

    $bundle = [System.IO.Path]::GetFileNameWithoutExtension($Name)
    $bundle = $bundle -replace '[<>:"/\\|?*]+', '-'
    $bundle = $bundle.Trim()

    if ([string]::IsNullOrWhiteSpace($bundle)) {
        throw "Cannot derive a Hugo bundle name from: $Name"
    }

    return $bundle
}

function Split-FrontMatter {
    param([string]$Content)

    if ($Content.StartsWith("+++`r`n")) {
        $end = $Content.IndexOf("`r`n+++`r`n", 4)
        if ($end -ge 0) {
            $frontMatter = $Content.Substring(0, $end + 7)
            $body = $Content.Substring($end + 7).TrimStart("`r", "`n")
            return @{ FrontMatter = $frontMatter; Body = $body }
        }
    }

    if ($Content.StartsWith("+++`n")) {
        $end = $Content.IndexOf("`n+++`n", 4)
        if ($end -ge 0) {
            $frontMatter = $Content.Substring(0, $end + 5)
            $body = $Content.Substring($end + 5).TrimStart("`r", "`n")
            return @{ FrontMatter = $frontMatter; Body = $body }
        }
    }

    if ($Content.StartsWith("---`r`n")) {
        $end = $Content.IndexOf("`r`n---`r`n", 4)
        if ($end -ge 0) {
            $frontMatter = $Content.Substring(0, $end + 7)
            $body = $Content.Substring($end + 7).TrimStart("`r", "`n")
            return @{ FrontMatter = $frontMatter; Body = $body }
        }
    }

    if ($Content.StartsWith("---`n")) {
        $end = $Content.IndexOf("`n---`n", 4)
        if ($end -ge 0) {
            $frontMatter = $Content.Substring(0, $end + 5)
            $body = $Content.Substring($end + 5).TrimStart("`r", "`n")
            return @{ FrontMatter = $frontMatter; Body = $body }
        }
    }

    return @{ FrontMatter = ""; Body = $Content }
}

function Get-DefaultFrontMatter {
    param(
        [string]$Title
    )

    $escapedTitle = $Title.Replace("'", "''")
    $date = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssK")
    return @"
+++
date = '$date'
draft = false
title = '$escapedTitle'
+++

"@
}

function Resolve-ImageSource {
    param(
        [string]$RawPath,
        [string]$SourceDir,
        [string]$TyporaImageDir
    )

    $trimmed = $RawPath.Trim()
    if ($trimmed.StartsWith("<") -and $trimmed.EndsWith(">")) {
        $trimmed = $trimmed.Substring(1, $trimmed.Length - 2)
    }

    if (
        $trimmed.StartsWith("http://") -or
        $trimmed.StartsWith("https://") -or
        $trimmed.StartsWith("data:") -or
        $trimmed.StartsWith("/") -or
        $trimmed.StartsWith("#")
    ) {
        return $null
    }

    if ($trimmed -match '^[A-Za-z]:\\') {
        if (Test-Path -LiteralPath $trimmed) {
            return (Resolve-Path -LiteralPath $trimmed).Path
        }
    } else {
        $relativePath = [System.IO.Path]::GetFullPath((Join-Path $SourceDir $trimmed))
        if (Test-Path -LiteralPath $relativePath) {
            return $relativePath
        }
    }

    $fileName = [System.IO.Path]::GetFileName($trimmed)
    if (-not [string]::IsNullOrWhiteSpace($fileName)) {
        $typoraPath = Join-Path $TyporaImageDir $fileName
        if (Test-Path -LiteralPath $typoraPath) {
            return (Resolve-Path -LiteralPath $typoraPath).Path
        }
    }

    throw "Cannot find image referenced by Markdown: $RawPath"
}

$resolvedMarkdown = (Resolve-Path -LiteralPath $SourceMarkdown).Path
$sourceDir = Split-Path -Parent $resolvedMarkdown
$postName = [System.IO.Path]::GetFileName($resolvedMarkdown)
$bundleName = if ([string]::IsNullOrWhiteSpace($BundleName)) {
    Get-BundleName -Name $postName
} else {
    $BundleName.Trim()
}

if ([string]::IsNullOrWhiteSpace($bundleName)) {
    throw "BundleName cannot be empty."
}

$bundleDir = Join-Path $PostsDir $bundleName
$bundleDir = [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $bundleDir))
New-Item -ItemType Directory -Force -Path $bundleDir | Out-Null

$sourceContent = Get-Content -LiteralPath $resolvedMarkdown -Raw -Encoding UTF8
$sourceParts = Split-FrontMatter -Content $sourceContent

$targetMarkdown = Join-Path $bundleDir "index.md"
$existingFrontMatter = ""
if (Test-Path -LiteralPath $targetMarkdown) {
    $existingContent = Get-Content -LiteralPath $targetMarkdown -Raw -Encoding UTF8
    $existingParts = Split-FrontMatter -Content $existingContent
    $existingFrontMatter = $existingParts.FrontMatter
}

$frontMatter = $sourceParts.FrontMatter
if ([string]::IsNullOrWhiteSpace($frontMatter)) {
    if (-not [string]::IsNullOrWhiteSpace($existingFrontMatter)) {
        $frontMatter = $existingFrontMatter
    } else {
        $frontMatter = Get-DefaultFrontMatter -Title ([System.IO.Path]::GetFileNameWithoutExtension($postName))
    }
}

$body = $sourceParts.Body
$imagePattern = '!\[(?<alt>[^\]]*)\]\((?<path>[^)]+)\)'

$rewrittenBody = [regex]::Replace($body, $imagePattern, {
    param($match)

    $rawPath = $match.Groups["path"].Value
    $resolvedImage = Resolve-ImageSource -RawPath $rawPath -SourceDir $sourceDir -TyporaImageDir $TyporaImageDir
    if ($null -eq $resolvedImage) {
        return $match.Value
    }

    $fileName = [System.IO.Path]::GetFileName($resolvedImage)
    Copy-Item -LiteralPath $resolvedImage -Destination (Join-Path $bundleDir $fileName) -Force
    return "![$($match.Groups["alt"].Value)]($fileName)"
})

$finalContent = $frontMatter.TrimEnd("`r", "`n") + "`r`n`r`n" + $rewrittenBody.TrimStart("`r", "`n") + "`r`n"
Set-Content -LiteralPath $targetMarkdown -Value $finalContent -Encoding UTF8

Write-Output "Imported to $targetMarkdown"
