# ══════════════════════════════════════════════════════════════════════════════
#  LifeOS Flutter Web Automated Build & Firebase Deploy System 🚀
# ══════════════════════════════════════════════════════════════════════════════
Write-Host ""
Write-Host "⚡ LifeOS Automated Flutter Web Deploy Starting..." -ForegroundColor Green
Write-Host "--------------------------------------------------" -ForegroundColor DarkGreen

# ── 1. Check Project Config ───────────────────────────────────────────────────
Write-Host "[1/3] Reading project configuration..." -ForegroundColor Cyan

if (-not (Test-Path ".firebaserc")) {
    Write-Error "Could not find .firebaserc file."
    exit 1
}

$rcContent = Get-Content -Path ".firebaserc" -Raw
$projRegex = '"default":\s*"([^"]+)"'
$projMatch = [regex]::Match($rcContent, $projRegex)

if ($projMatch.Success) {
    $projectId = $projMatch.Groups[1].Value
    Write-Host "✅ Target Firebase Project: $projectId" -ForegroundColor Gray
} else {
    Write-Error "Could not parse Project ID from .firebaserc."
    exit 1
}

# ── 2. Compile Flutter Web ────────────────────────────────────────────────────
Write-Host ""
Write-Host "[2/3] Compiling fresh release Web App... (This may take a minute)" -ForegroundColor Cyan
Write-Host "Running: flutter build web --release" -ForegroundColor DarkGray

# Clean first to ensure no locked caches
flutter clean
flutter build web --release

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Compilation failed. Please fix compile errors first." -ForegroundColor Red
    exit 1
}

$webPath = "build/web"
if (-not (Test-Path $webPath)) {
    Write-Host "❌ Web build was completed successfully but not found at: $webPath" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Web App compiled successfully!" -ForegroundColor Green

# ── 3. Deploy to Firebase Hosting ─────────────────────────────────────────────
Write-Host ""
Write-Host "[3/3] Deploying to Firebase Hosting..." -ForegroundColor Cyan

firebase deploy --only hosting

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Deployment failed. Make sure you ran 'firebase login' first!" -ForegroundColor Red
    exit 1
}

$publicWebUrl = "https://$projectId.web.app"

Write-Host "--------------------------------------------------" -ForegroundColor DarkGreen
Write-Host "🎉 WEB DEPLOYMENT COMPLETE!" -ForegroundColor Green
Write-Host "Your live web application is hosted at:" -ForegroundColor Green
Write-Host "$publicWebUrl" -ForegroundColor Yellow
Write-Host "--------------------------------------------------" -ForegroundColor DarkGreen
Write-Host "Open the link above in your browser to view your live LifeOS Web application!" -ForegroundColor Gray
Write-Host ""
