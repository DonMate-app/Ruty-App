# build.ps1
$pubspecPath = "pubspec.yaml"
$content = Get-Content $pubspecPath -Raw

if ($content -match 'version:\s*(\d+\.\d+\.\d+)\+(\d+)') {
    $versionName = $Matches[1]
    $buildNumber = [int]$Matches[2]
    $newBuildNumber = $buildNumber + 1

    $newVersionLine = "version: $versionName+$newBuildNumber"
    $content = $content -replace 'version:\s*\d+\.\d+\.\d+\+\d+', $newVersionLine

    Set-Content -Path $pubspecPath -Value $content -NoNewline
    Write-Host "Version incrementada a: $versionName+$newBuildNumber" -ForegroundColor Green
} else {
    Write-Host "No se encontro la linea de version en pubspec.yaml" -ForegroundColor Yellow
    exit 1
}

Write-Host "Compilando APK..." -ForegroundColor Cyan
flutter build apk --release