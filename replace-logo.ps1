# Replace image-based logos with text-based logos
# Purpose: Replace img logo.png with JANTEN NEWS text logo

param([switch]$Dry)

$textLogo = '<span style="font-weight: bold; color: #7C2D12; font-size: 1.2em;">JANTEN</span><span style="color: #1A5E6E; font-size: 0.9em; margin-left: 2px;">NEWS</span>'

$files = @('contact.html', 'news.html', 'search.html', 'index.html')
$changedCount = 0

Write-Host "=== Replacing image logos with text-based logos ===" -ForegroundColor Cyan

foreach ($file in $files) {
    if (Test-Path $file) {
        $content = [System.IO.File]::ReadAllText($file, [System.Text.Encoding]::UTF8)
        $originalContent = $content
        
        # Replace both relative path variations
        $content = $content -Replace '<img src="img/logo\.png"[^>]*alt="jantenNews"[^>]*>', $textLogo
        $content = $content -Replace '<img src="\.\./img/logo\.png"[^>]*>', $textLogo
        
        if ($content -ne $originalContent) {
            if (-not $Dry) {
                [System.IO.File]::WriteAllText($file, $content, [System.Text.Encoding]::UTF8)
                $changedCount++
                Write-Host "  [OK] $file" -ForegroundColor Green
            }
        }
    }
}

Write-Host "Total files updated: $changedCount" -ForegroundColor Yellow
if ($Dry) {
    Write-Host "DRY RUN MODE - use without -Dry to apply" -ForegroundColor Yellow
}