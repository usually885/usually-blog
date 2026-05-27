param(
    [Parameter(Mandatory = $true)]
    [string]$SourceMarkdown,

    [string]$BundleName,

    [string]$PostsDir = "content/posts",

    [string]$TyporaImageDir = "$env:APPDATA\Typora\typora-user-images",

    [switch]$Stage
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$importScript = Join-Path $scriptDir "import-typora-post.ps1"

if (-not (Test-Path -LiteralPath $importScript)) {
    throw "Missing helper script: $importScript"
}

$importParams = @{
    SourceMarkdown = $SourceMarkdown
    PostsDir = $PostsDir
    TyporaImageDir = $TyporaImageDir
}

if (-not [string]::IsNullOrWhiteSpace($BundleName)) {
    $importParams.BundleName = $BundleName
}

& $importScript @importParams
hugo --gc --minify | Out-Host

$resolvedMarkdown = (Resolve-Path -LiteralPath $SourceMarkdown).Path
$finalBundle = if ([string]::IsNullOrWhiteSpace($BundleName)) {
    [System.IO.Path]::GetFileNameWithoutExtension($resolvedMarkdown)
} else {
    $BundleName
}

$bundlePath = Join-Path $PostsDir $finalBundle

if ($Stage) {
    git add -- $bundlePath
    Write-Output "Staged $bundlePath"
} else {
    Write-Output "Imported and built $bundlePath"
}
