# scripts/create_structure.ps1
$base = "app/src/main/java/com/roadsense/logger"

Write-Host "🚀 Creating Clean Architecture Structure..." -ForegroundColor Cyan

$folders = @(
    # CORE LAYER
    "core/state",
    "core/session",
    "core/config",
    "core/validation",
    
    # CONNECTIVITY
    "core/connectivity/bluetooth",
    "core/connectivity/protocol",
    "core/connectivity/serialization",
    
    # DEVICE
    "core/device",
    
    # DATA LAYER
    "data/local/database/dao",
    "data/local/database/entities",
    "data/local/repository",
    "data/remote",
    "data/model",
    
    # DOMAIN LAYER
    "domain/entity",
    "domain/repository",
    "domain/usecase",
    
    # PRESENTATION LAYER
    "presentation/ui/main",
    "presentation/ui/dashboard",
    "presentation/ui/speed",
    "presentation/ui/odometer",
    "presentation/ui/statistics",
    "presentation/ui/settings",
    "presentation/ui/export",
    "presentation/ui/components",
    
    # UTILS
    "utils/extensions",
    "utils/formatters",
    "utils/validators",
    "utils/converters",
    
    # DI
    "di",
    
    # WORKER
    "worker"
)

foreach ($folder in $folders) {
    $path = Join-Path $base $folder
    New-Item -ItemType Directory -Force -Path $path | Out-Null
    Write-Host "Created: $path" -ForegroundColor Green
}

Write-Host "✅ Structure created successfully!" -ForegroundColor Green