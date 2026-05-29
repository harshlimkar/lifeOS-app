# ══════════════════════════════════════════════════════════════════════════════
#  LifeOS Automated Build & Supabase Deploy System 🚀
# ══════════════════════════════════════════════════════════════════════════════
Write-Host ""
Write-Host "⚡ LifeOS Automated Deploy System Starting..." -ForegroundColor Green
Write-Host "--------------------------------------------------" -ForegroundColor DarkGreen

# ── 1. Scrape Keys from main.dart ─────────────────────────────────────────────
Write-Host "[1/4] Reading Supabase credentials from main.dart..." -ForegroundColor Cyan

if (-not (Test-Path "lib/main.dart")) {
    Write-Error "Could not find lib/main.dart. Please run this script in the root directory of your project."
    exit 1
}

$mainContent = Get-Content -Path "lib/main.dart" -Raw

# Match URL
$urlRegex = "url:\s*'([^']+)'"
$urlMatch = [regex]::Match($mainContent, $urlRegex)
if ($urlMatch.Success) {
    $supabaseUrl = $urlMatch.Groups[1].Value
    Write-Host "✅ Found Supabase URL: $supabaseUrl" -ForegroundColor Gray
} else {
    Write-Error "Could not parse Supabase URL from main.dart. Make sure it is defined in Supabase.initialize."
    exit 1
}

# Match AnonKey (handles optional multi-line formats)
$keyRegex = "anonKey:\s*[\s\S]*?'([^']+)'"
$keyMatch = [regex]::Match($mainContent, $keyRegex)
if ($keyMatch.Success) {
    $anonKey = $keyMatch.Groups[1].Value
    Write-Host "✅ Found Supabase AnonKey (authenticated)" -ForegroundColor Gray
} else {
    Write-Error "Could not parse Supabase AnonKey from main.dart."
    exit 1
}

# ── 2. Compile APK ────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "[2/4] Compiling fresh release APK... (This may take a minute)" -ForegroundColor Cyan
Write-Host "Running: flutter build apk --release" -ForegroundColor DarkGray

# Execute Flutter Build
flutter build apk --release
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Compilation failed. Please fix any syntax or compile errors first." -ForegroundColor Red
    exit 1
}

$apkPath = "build/app/outputs/flutter-apk/app-release.apk"
if (-not (Test-Path $apkPath)) {
    Write-Host "❌ APK was built but not found at the expected path: $apkPath" -ForegroundColor Red
    exit 1
}

$apkSize = (Get-Item $apkPath).Length / 1MB
Write-Host "✅ APK compiled successfully! Size: $($apkSize.ToString('F2')) MB" -ForegroundColor Green

# ── 3. Upload to Supabase Storage ─────────────────────────────────────────────
Write-Host ""
Write-Host "[3/4] Uploading APK to Supabase Storage bucket 'app-releases'..." -ForegroundColor Cyan
Write-Host "Target: app-releases/app-release.apk" -ForegroundColor DarkGray

$uploadUrl = "$supabaseUrl/storage/v1/object/app-releases/app-release.apk"

# Read file bytes
$fileBytes = [System.IO.File]::ReadAllBytes($apkPath)

# Headers (Both apikey and Authorization are required)
$headers = @{
    "apikey"        = $anonKey
    "Authorization" = "Bearer $anonKey"
    "x-upsert"      = "true" # Overwrites the existing APK so the download link stays the same!
}

try {
    # Perform upload
    $response = Invoke-RestMethod -Uri $uploadUrl -Method Post -Headers $headers -Body $fileBytes -ContentType "application/vnd.android.package-archive"
    Write-Host "✅ Upload successful!" -ForegroundColor Green
} catch {
    Write-Host "❌ Upload failed. Details:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    
    # Troubleshooting tips
    Write-Host ""
    Write-Host "💡 Troubleshooting Tip:" -ForegroundColor Yellow
    Write-Host "Make sure your 'app-releases' bucket is created in Supabase under Storage." -ForegroundColor Yellow
    Write-Host "Also ensure you have set the Bucket to 'Public' and allowed anonymous/authenticated uploads in Supabase Storage Policies." -ForegroundColor Yellow
    exit 1
}

# ── 4. Generate Download URL ──────────────────────────────────────────────────
Write-Host ""
Write-Host "[4/4] Generating deployment link..." -ForegroundColor Cyan

$publicDownloadUrl = "$supabaseUrl/storage/v1/object/public/app-releases/app-release.apk"

Write-Host "--------------------------------------------------" -ForegroundColor DarkGreen
Write-Host "🎉 DEPLOYMENT COMPLETE!" -ForegroundColor Green
Write-Host "Your public download URL is:" -ForegroundColor Green
Write-Host "$publicDownloadUrl" -ForegroundColor Yellow
Write-Host "--------------------------------------------------" -ForegroundColor DarkGreen
Write-Host "Copy the link above and paste it into your Admin Dashboard under 'Download URL' to publish this update!" -ForegroundColor Gray
Write-Host ""
