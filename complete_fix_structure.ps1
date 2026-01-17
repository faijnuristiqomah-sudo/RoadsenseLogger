# Save as: complete_fix.ps1
# Run: .\complete_fix.ps1

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "COMPLETE PROJECT STRUCTURE FIX" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan

$basePath = ".\app\src\main\java\com\roadsense\logger"
$modelPath = "$basePath\model"
$bluetoothPath = "$basePath\core\bluetooth"

Write-Host "`nStep 1: Checking current structure..." -ForegroundColor Yellow

# Create directories if they don't exist
if (-not (Test-Path $bluetoothPath)) {
    New-Item -ItemType Directory -Force -Path $bluetoothPath | Out-Null
    Write-Host "  Created: core\bluetooth\" -ForegroundColor Green
}

# Check what files exist
if (Test-Path $modelPath) {
    Write-Host "`nFiles in model/ folder:" -ForegroundColor Gray
    Get-ChildItem $modelPath -Filter "*.kt" -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Host "  - $($_.Name)" -ForegroundColor DarkGray
    }
} else {
    Write-Host "`nmodel/ folder does not exist" -ForegroundColor Yellow
}

Write-Host "`nFiles in root folder:" -ForegroundColor Gray
Get-ChildItem $basePath -Filter "*.kt" -ErrorAction SilentlyContinue | ForEach-Object {
    Write-Host "  - $($_.Name)" -ForegroundColor DarkGray
}

Write-Host "`nStep 2: Fixing file names..." -ForegroundColor Yellow

# Fix typos in model folder
if (Test-Path "$modelPath\BluetoohHandler.kt") {
    Rename-Item "$modelPath\BluetoohHandler.kt" "BluetoothHandler.kt" -ErrorAction SilentlyContinue
    Write-Host "  - Fixed: BluetoohHandler.kt -> BluetoothHandler.kt" -ForegroundColor Green
}

if (Test-Path "$modelPath\RoadsenseAplplication.kt") {
    Rename-Item "$modelPath\RoadsenseAplplication.kt" "RoadsenseApplication.kt" -ErrorAction SilentlyContinue
    Write-Host "  - Fixed: RoadsenseAplplication.kt -> RoadsenseApplication.kt" -ForegroundColor Green
}

Write-Host "`nStep 3: Moving files to correct locations..." -ForegroundColor Yellow

# Move EnhancedData.kt to core/data/models/
if (Test-Path "$modelPath\EnhancedData.kt") {
    $modelsDir = "$basePath\core\data\models"
    if (-not (Test-Path $modelsDir)) {
        New-Item -ItemType Directory -Force -Path $modelsDir | Out-Null
    }
    Move-Item "$modelPath\EnhancedData.kt" $modelsDir -Force -ErrorAction SilentlyContinue
    Write-Host "  - Moved EnhancedData.kt to core/data/models/" -ForegroundColor Green
}

# Move Bluetooth files to core/bluetooth/
$bluetoothFiles = @("BluetoothHandler.kt", "PermissionHelper.kt")

foreach ($file in $bluetoothFiles) {
    $moved = $false
    
    if (Test-Path "$modelPath\$file") {
        Move-Item "$modelPath\$file" $bluetoothPath -Force -ErrorAction SilentlyContinue
        Write-Host "  - Moved $file from model/ to core/bluetooth/" -ForegroundColor Green
        $moved = $true
    } elseif (Test-Path "$basePath\$file") {
        Move-Item "$basePath\$file" $bluetoothPath -Force -ErrorAction SilentlyContinue
        Write-Host "  - Moved $file from root to core/bluetooth/" -ForegroundColor Green
        $moved = $true
    }
    
    if (-not $moved) {
        Write-Host "  - WARNING: $file not found" -ForegroundColor Yellow
    }
}

# Move MainActivity and RoadsenseApplication to root
$rootFiles = @("MainActivity.kt", "RoadsenseApplication.kt")

foreach ($file in $rootFiles) {
    if (Test-Path "$modelPath\$file") {
        Move-Item "$modelPath\$file" $basePath -Force -ErrorAction SilentlyContinue
        Write-Host "  - Moved $file to root" -ForegroundColor Green
    }
}

Write-Host "`nStep 4: Updating package declarations..." -ForegroundColor Yellow

# Update BluetoothHandler.kt
$btHandlerPath = "$bluetoothPath\BluetoothHandler.kt"
if (Test-Path $btHandlerPath) {
    $content = Get-Content $btHandlerPath -Raw -Encoding UTF8
    $content = $content -replace 'package com\.roadsense\.logger\.model', 'package com.roadsense.logger.core.bluetooth'
    $content = $content -replace 'package com\.roadsense\.logger\s', 'package com.roadsense.logger.core.bluetooth'
    $content | Out-File $btHandlerPath -Encoding UTF8 -NoNewline
    Write-Host "  - Updated BluetoothHandler.kt package" -ForegroundColor Green
}

# Update PermissionHelper.kt
$permHelperPath = "$bluetoothPath\PermissionHelper.kt"
if (Test-Path $permHelperPath) {
    $content = Get-Content $permHelperPath -Raw -Encoding UTF8
    $content = $content -replace 'package com\.roadsense\.logger\.model', 'package com.roadsense.logger.core.bluetooth'
    $content = $content -replace 'package com\.roadsense\.logger\s', 'package com.roadsense.logger.core.bluetooth'
    $content | Out-File $permHelperPath -Encoding UTF8 -NoNewline
    Write-Host "  - Updated PermissionHelper.kt package" -ForegroundColor Green
}

# Update EnhancedData.kt
$enhancedDataPath = "$basePath\core\data\models\EnhancedData.kt"
if (Test-Path $enhancedDataPath) {
    $content = Get-Content $enhancedDataPath -Raw -Encoding UTF8
    $content = $content -replace 'package com\.roadsense\.logger\.model', 'package com.roadsense.logger.core.data.models'
    $content = $content -replace 'package com\.roadsense\.logger\s', 'package com.roadsense.logger.core.data.models'
    $content | Out-File $enhancedDataPath -Encoding UTF8 -NoNewline
    Write-Host "  - Updated EnhancedData.kt package" -ForegroundColor Green
}

# Update MainActivity.kt imports
$mainActivityPath = "$basePath\MainActivity.kt"
if (Test-Path $mainActivityPath) {
    $content = Get-Content $mainActivityPath -Raw -Encoding UTF8
    
    # Update imports
    $content = $content -replace 'import com\.roadsense\.logger\.model\.BluetoothHandler', 'import com.roadsense.logger.core.bluetooth.BluetoothHandler'
    $content = $content -replace 'import com\.roadsense\.logger\.BluetoothHandler', 'import com.roadsense.logger.core.bluetooth.BluetoothHandler'
    $content = $content -replace 'import com\.roadsense\.logger\.model\.PermissionHelper', 'import com.roadsense.logger.core.bluetooth.PermissionHelper'
    $content = $content -replace 'import com\.roadsense\.logger\.PermissionHelper', 'import com.roadsense.logger.core.bluetooth.PermissionHelper'
    $content = $content -replace 'import com\.roadsense\.logger\.model\.EnhancedData', 'import com.roadsense.logger.core.data.models.EnhancedData'
    $content = $content -replace 'import com\.roadsense\.logger\.EnhancedData', 'import com.roadsense.logger.core.data.models.EnhancedData'
    
    $content | Out-File $mainActivityPath -Encoding UTF8 -NoNewline
    Write-Host "  - Updated MainActivity.kt imports" -ForegroundColor Green
}

# Update RoadsenseApplication.kt imports
$appPath = "$basePath\RoadsenseApplication.kt"
if (Test-Path $appPath) {
    $content = Get-Content $appPath -Raw -Encoding UTF8
    
    $content = $content -replace 'import com\.roadsense\.logger\.model\.BluetoothHandler', 'import com.roadsense.logger.core.bluetooth.BluetoothHandler'
    $content = $content -replace 'import com\.roadsense\.logger\.BluetoothHandler', 'import com.roadsense.logger.core.bluetooth.BluetoothHandler'
    
    $content | Out-File $appPath -Encoding UTF8 -NoNewline
    Write-Host "  - Updated RoadsenseApplication.kt imports" -ForegroundColor Green
}

Write-Host "`nStep 5: Cleaning up empty directories..." -ForegroundColor Yellow

# Check if model folder is empty and remove it
if (Test-Path $modelPath) {
    $items = Get-ChildItem $modelPath -ErrorAction SilentlyContinue
    if ($items.Count -eq 0) {
        Remove-Item $modelPath -Force -ErrorAction SilentlyContinue
        Write-Host "  - Removed empty model/ folder" -ForegroundColor Green
    } else {
        Write-Host "  - model/ folder not empty, keeping it:" -ForegroundColor Yellow
        $items | ForEach-Object {
            Write-Host "    - $($_.Name)" -ForegroundColor DarkGray
        }
    }
}

Write-Host "`nStep 6: Verifying final structure..." -ForegroundColor Yellow

# Show final structure
Write-Host "`nFinal structure in root:" -ForegroundColor Cyan
Get-ChildItem $basePath -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    Write-Host "  [DIR]  $($_.Name)" -ForegroundColor Cyan
}

Get-ChildItem $basePath -Filter "*.kt" -ErrorAction SilentlyContinue | ForEach-Object {
    Write-Host "  [FILE] $($_.Name)" -ForegroundColor Green
}

Write-Host "`nFiles in core/bluetooth/:" -ForegroundColor Cyan
if (Test-Path $bluetoothPath) {
    Get-ChildItem $bluetoothPath -Filter "*.kt" -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Host "  [FILE] $($_.Name)" -ForegroundColor Green
    }
} else {
    Write-Host "  (folder does not exist)" -ForegroundColor Yellow
}

Write-Host "`nFiles in core/data/models/:" -ForegroundColor Cyan
$modelsPath = "$basePath\core\data\models"
if (Test-Path $modelsPath) {
    Get-ChildItem $modelsPath -Filter "*.kt" -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Host "  [FILE] $($_.Name)" -ForegroundColor Green
    }
} else {
    Write-Host "  (folder does not exist)" -ForegroundColor Yellow
}

Write-Host "`n==========================================" -ForegroundColor Cyan
Write-Host "FIX COMPLETED SUCCESSFULLY!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan

Write-Host "`nNext steps:" -ForegroundColor White
Write-Host "1. Open Android Studio" -ForegroundColor Gray
Write-Host "2. File -> Sync Project with Gradle Files" -ForegroundColor Gray
Write-Host "3. Build -> Clean Project" -ForegroundColor Gray
Write-Host "4. Build -> Rebuild Project" -ForegroundColor Gray
Write-Host "5. Run on device or emulator" -ForegroundColor Gray

Write-Host "`nIf you still have issues:" -ForegroundColor Yellow
Write-Host "- File -> Invalidate Caches -> Invalidate and Restart" -ForegroundColor DarkGray
Write-Host "- Check Build tab for specific errors" -ForegroundColor DarkGray
Write-Host "- Verify all imports are correct" -ForegroundColor DarkGray