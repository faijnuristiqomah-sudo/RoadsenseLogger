# fix_structure.ps1
# Improved version with error handling

Write-Host "Fixing project structure..." -ForegroundColor Green

$sourceDir = ".\app\src\main\java\com\roadsense\logger"
$destDir = "$sourceDir\core\bluetooth"

# Check if source directory exists
if (-not (Test-Path $sourceDir)) {
    Write-Host "ERROR: Source directory not found: $sourceDir" -ForegroundColor Red
    exit 1
}

# Create destination directory if it doesn't exist
if (-not (Test-Path $destDir)) {
    Write-Host "Creating destination directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Force -Path $destDir | Out-Null
}

# 1. Copy files
Write-Host "`nCopying files to new structure..." -ForegroundColor Yellow

$filesToCopy = @{
    "BluetoothHandler.kt" = $true
    "PermissionHelper.kt" = $true
}

foreach ($fileName in $filesToCopy.Keys) {
    $sourcePath = "$sourceDir\$fileName"
    
    if (Test-Path $sourcePath) {
        Copy-Item $sourcePath $destDir -Force
        Write-Host "  - Copied $fileName" -ForegroundColor Green
    } else {
        Write-Host "  - WARNING: $fileName not found, skipping..." -ForegroundColor Yellow
    }
}

# 2. Update package declarations
Write-Host "`nUpdating package declarations..." -ForegroundColor Yellow

# BluetoothHandler.kt
$btFile = "$destDir\BluetoothHandler.kt"
if (Test-Path $btFile) {
    $content = Get-Content $btFile -Raw
    $content = $content -replace 'package com\.roadsense\.logger\s*$', 'package com.roadsense.logger.core.bluetooth'
    $content = $content -replace 'package com\.roadsense\.logger\n', "package com.roadsense.logger.core.bluetooth`n"
    $content | Out-File -FilePath $btFile -Encoding UTF8 -NoNewline
    Write-Host "  - Updated BluetoothHandler.kt package" -ForegroundColor Green
} else {
    Write-Host "  - WARNING: BluetoothHandler.kt not found in destination" -ForegroundColor Yellow
}

# PermissionHelper.kt
$permFile = "$destDir\PermissionHelper.kt"
if (Test-Path $permFile) {
    $content = Get-Content $permFile -Raw
    $content = $content -replace 'package com\.roadsense\.logger\s*$', 'package com.roadsense.logger.core.bluetooth'
    $content = $content -replace 'package com\.roadsense\.logger\n', "package com.roadsense.logger.core.bluetooth`n"
    $content | Out-File -FilePath $permFile -Encoding UTF8 -NoNewline
    Write-Host "  - Updated PermissionHelper.kt package" -ForegroundColor Green
} else {
    Write-Host "  - WARNING: PermissionHelper.kt not found in destination" -ForegroundColor Yellow
}

# 3. Update MainActivity imports
Write-Host "`nUpdating MainActivity.kt imports..." -ForegroundColor Yellow

$mainFile = "$sourceDir\MainActivity.kt"
if (Test-Path $mainFile) {
    $content = Get-Content $mainFile -Raw
    
    # Update imports
    $content = $content -replace 'import com\.roadsense\.logger\.BluetoothHandler', 'import com.roadsense.logger.core.bluetooth.BluetoothHandler'
    $content = $content -replace 'import com\.roadsense\.logger\.PermissionHelper', 'import com.roadsense.logger.core.bluetooth.PermissionHelper'
    
    $content | Out-File -FilePath $mainFile -Encoding UTF8 -NoNewline
    Write-Host "  - Updated MainActivity.kt imports" -ForegroundColor Green
} else {
    Write-Host "  - WARNING: MainActivity.kt not found" -ForegroundColor Yellow
}

# 4. Update RoadsenseApplication if exists
$appFile = "$sourceDir\RoadsenseApplication.kt"
if (Test-Path $appFile) {
    Write-Host "`nUpdating RoadsenseApplication.kt imports..." -ForegroundColor Yellow
    $content = Get-Content $appFile -Raw
    
    $content = $content -replace 'import com\.roadsense\.logger\.BluetoothHandler', 'import com.roadsense.logger.core.bluetooth.BluetoothHandler'
    $content = $content -replace 'import com\.roadsense\.logger\.PermissionHelper', 'import com.roadsense.logger.core.bluetooth.PermissionHelper'
    
    $content | Out-File -FilePath $appFile -Encoding UTF8 -NoNewline
    Write-Host "  - Updated RoadsenseApplication.kt imports" -ForegroundColor Green
}

# 5. Delete old files from root (optional - commented out for safety)
Write-Host "`nCleaning up..." -ForegroundColor Yellow
Write-Host "  - Old files kept in root directory (delete manually if needed)" -ForegroundColor Gray

# Uncomment these lines if you want to auto-delete old files:
# Remove-Item "$sourceDir\BluetoothHandler.kt" -Force -ErrorAction SilentlyContinue
# Remove-Item "$sourceDir\PermissionHelper.kt" -Force -ErrorAction SilentlyContinue

Write-Host "`n==================================" -ForegroundColor Cyan
Write-Host "Structure fix completed!" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Cyan

Write-Host "`nNext steps:" -ForegroundColor White
Write-Host "1. Sync project with Gradle files" -ForegroundColor Gray
Write-Host "2. Build project: .\gradlew build" -ForegroundColor Gray
Write-Host "3. Delete old files manually if needed:" -ForegroundColor Gray
Write-Host "   - $sourceDir\BluetoothHandler.kt" -ForegroundColor DarkGray
Write-Host "   - $sourceDir\PermissionHelper.kt" -ForegroundColor DarkGray

Write-Host "`nFiles location:" -ForegroundColor White
Write-Host "  New: $destDir" -ForegroundColor Cyan