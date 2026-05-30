# ══════════════════════════════════════════════════════════════════════════════
#  LifeOS Automated Build & Firebase Deploy System 🚀
# ══════════════════════════════════════════════════════════════════════════════
Write-Host ""
Write-Host "⚡ LifeOS Automated Firebase Deploy Starting..." -ForegroundColor Green
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
    if ($projectId -eq "YOUR_FIREBASE_PROJECT_ID") {
        Write-Host "⚠️  Please open '.firebaserc' and replace 'YOUR_FIREBASE_PROJECT_ID' with your actual Firebase Project ID first!" -ForegroundColor Yellow
        exit 1
    }
    Write-Host "✅ Target Firebase Project: $projectId" -ForegroundColor Gray
} else {
    Write-Error "Could not parse Project ID from .firebaserc."
    exit 1
}

# ── 2. Compile APK ────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "[2/3] Compiling fresh release APK..." -ForegroundColor Cyan
Write-Host "Running: flutter build apk --release" -ForegroundColor DarkGray

# Clean first to ensure no locked caches
flutter clean
flutter build apk --release

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Compilation failed. Please fix compile errors first." -ForegroundColor Red
    exit 1
}

$apkPath = "build/app/outputs/flutter-apk/app-release.apk"
if (-not (Test-Path $apkPath)) {
    Write-Host "❌ APK was built successfully but not found at: $apkPath" -ForegroundColor Red
    exit 1
}

$apkSize = (Get-Item $apkPath).Length / 1MB
Write-Host "✅ APK compiled successfully! Size: $($apkSize.ToString('F2')) MB" -ForegroundColor Green

# ── 3. Deploy to Firebase Hosting ─────────────────────────────────────────────
Write-Host ""
Write-Host "[3/3] Deploying to Firebase Hosting..." -ForegroundColor Cyan

firebase deploy --only hosting

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Deployment failed. Make sure you ran 'firebase login' first!" -ForegroundColor Red
    exit 1
}

$publicDownloadUrl = "https://$projectId.web.app/app-release.apk"

Write-Host "--------------------------------------------------" -ForegroundColor DarkGreen
Write-Host "🎉 DEPLOYMENT COMPLETE!" -ForegroundColor Green
Write-Host "Your public download URL is:" -ForegroundColor Green
Write-Host "$publicDownloadUrl" -ForegroundColor Yellow
Write-Host "--------------------------------------------------" -ForegroundColor DarkGreen
Write-Host "Copy the link above and paste it into your Admin Dashboard under 'Download URL' to publish this update!" -ForegroundColor Gray
Write-Host ""
