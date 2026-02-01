
param([string]$NewVersion)

$swPath = "d:\fullstack\service-worker.js"
$indexPath = "d:\fullstack\index.html"
$baseDir = "d:\fullstack"

Write-Host "--- PWA Update Utility ---"
Write-Host "Target Directory: $baseDir"

# 1. Determine Current & New Version
$swContent = Get-Content $swPath -Raw -Encoding UTF8
if ($swContent -match "const CACHE_VERSION = 'v(.*?)';") {
    $currentVersion = $matches[1]
    Write-Host "Current Version: $currentVersion"
} else {
    Write-Error "Could not parse CACHE_VERSION in service-worker.js"
    exit 1
}

if (-not $NewVersion) {
    $parts = $currentVersion.Split('.')
    if ($parts.Count -eq 3) {
        $parts[2] = [int]$parts[2] + 1
        $NewVersion = $parts -join '.'
    } else {
        Write-Host "Version format unknown. Please provide new version manually." -ForegroundColor Red
        exit 1
    }
}

Write-Host "Updating to: v$NewVersion" -ForegroundColor Cyan

# 2. Extract Font URL from index.html (Source of Truth)
$indexContent = Get-Content $indexPath -Raw -Encoding UTF8
$fontUrl = ""
if ($indexContent -match 'href="(https://fonts\.googleapis\.com/css2.*?)"') {
    $fontUrl = $matches[1]
    Write-Host "Found Font URL in HTML: $fontUrl"
} else {
    Write-Host "Warning: No Google Fonts URL found in index.html" -ForegroundColor Yellow
}

# 3. Build Asset List
Write-Host "Scanning assets..."
$files = Get-ChildItem -Path $baseDir -Recurse | Where-Object { $_.Name -match '\.(html|js|css|json|png)$' }
$assetList = @()

# Always add root
$assetList += "    './',"

foreach ($f in $files) {
    # Filters
    if ($f.FullName -like "*\node_modules\*") { continue }
    if ($f.FullName -like "*\.git\*") { continue }
    if ($f.Name -eq "service-worker.js") { continue } # Don't cache the worker with versioning
    if ($f.Name -like "update-pwa*") { continue }
    if ($f.Name -like "index_backup*") { continue }
    if ($f.Name -like "release.config.js") { continue }
    
    # Create relative path
    $relPath = "./" + ($f.FullName.Substring($baseDir.Length + 1)).Replace("\", "/")
    $assetList += "    '$relPath',"
}

# Add Hardcoded External Libs (jspdf, xlsx)
# Ideally parse from HTML, but hardcoding standard libs is safe for now to verify
$assetList += "    'https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js',"
$assetList += "    'https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.5.31/jspdf.plugin.autotable.min.js',"
$assetList += "    'https://cdn.jsdelivr.net/npm/xlsx/dist/xlsx.full.min.js',"
if ($fontUrl) {
    $assetList += "    '$fontUrl'"
}

# 4. Update service-worker.js Content
# Replace Version
$swContent = $swContent -replace "const CACHE_VERSION = 'v.*?';", "const CACHE_VERSION = 'v$NewVersion';"

# Replace Asset Array
# We intentionally overwrite the array to keep it fresh
$newArrayBlock = "const ASSETS_TO_CACHE = [" + "`n" + ($assetList -join "`n") + "`n];"
$swContent = $swContent -replace "(?s)const ASSETS_TO_CACHE = \[.*?\];", $newArrayBlock

Set-Content -Path $swPath -Value $swContent -Encoding UTF8
Write-Host "Updated service-worker.js with new assets and version." -ForegroundColor Green

# 5. Update index.html Version Strings
# Footer: "Version v1.2.0" -> "Version v1.2.1"
$indexContent = $indexContent -replace "Version v\d+\.\d+\.\d+", "Version v$NewVersion"
# Modal: "Version 1.2.0" -> "Version 1.2.1" (if any)
$indexContent = $indexContent -replace "Version \d+\.\d+\.\d+", "Version $NewVersion"

Set-Content -Path $indexPath -Value $indexContent -Encoding UTF8
Write-Host "Updated index.html version labels." -ForegroundColor Green

Write-Host "Done! PWA v$NewVersion is ready."
