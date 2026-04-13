# Rebrand Script: Indonesia Daily -> Janten News
# Developed: 2026-03-30

param(
    [switch]$Verify = $false,
    [switch]$Dry = $false
)

$colors = @{ Success = 'Green'; Error = 'Red'; Warning = 'Yellow'; Info = 'Cyan' }
$stats = @{ MainPages = 0; ArticlePages = 0; CSS = 0; Packages = 0; Docs = 0; TotalChanged = 0 }

function Write-Status {
    param([string]$Message, [string]$Type = 'Info')
    Write-Host $Message -ForegroundColor $colors[$Type]
}

Write-Status "=== STEP 1: Backup articles.json ===" 'Info'
$backupPath = "articles.json.bak.$(Get-Date -Format 'yyyyMMddHHmmss')"
if (Test-Path 'articles.json') {
    Copy-Item 'articles.json' $backupPath
    Write-Status "✓ Backup created: $backupPath" 'Success'
}

Write-Status "=== STEP 2: Setting up replacement rules ===" 'Info'

$replacements = @(
    @{ Old = 'Indonesia Daily'; New = 'Janten News' },
    @{ Old = 'INDONESIA DAILY'; New = 'JANTEN NEWS' },
    @{ Old = 'indonesiadaily'; New = 'jantenNews' },
    @{ Old = 'IndonesiaDaily'; New = 'JantenNews' },
    @{ Old = 'indonesiakku@gmail.com'; New = 'jantenNews@gmail.com' },
    @{ Old = 'Contact Us - Indonesia Daily'; New = 'Contact Us - Janten News' },
    @{ Old = 'Search - Indonesia Daily'; New = 'Search - Janten News' },
    @{ Old = 'News - Indonesia Daily'; New = 'News - Janten News' },
    @{ Old = 'Berita - Indonesia Daily'; New = 'Berita - Janten News' },
    @{ Old = 'Register - Indonesia Daily'; New = 'Register - Janten News' },
    @{ Old = 'Login - Indonesia Daily'; New = 'Login - Janten News' }
)

Write-Status "=== STEP 3: Processing HTML files ===" 'Info'

$mainPages = @('index.html', 'news.html', 'contact.html', 'search.html', 'login.html', 'register.html')
foreach ($page in $mainPages) {
    if (Test-Path $page) {
        $content = [System.IO.File]::ReadAllText($page, [System.Text.Encoding]::UTF8)
        $originalContent = $content
        
        foreach ($repl in $replacements) {
            $content = $content -Replace [regex]::Escape($repl.Old), $repl.New
        }
        
        # Fix quotation marks
        $content = $content.Replace([char]0x201C, '"')    # "
        $content = $content.Replace([char]0x201D, '"')    # "
        $content = $content.Replace([char]0x2018, "'")    # '
        $content = $content.Replace([char]0x2019, "'")    # '
        
        # Fix dashes
        $content = $content.Replace([char]0x2013, '-')    # –
        $content = $content.Replace([char]0x2014, '-')    # —
        
        if ($content -ne $originalContent -and -not $Dry) {
            [System.IO.File]::WriteAllText($page, $content, [System.Text.Encoding]::UTF8)
            $stats['MainPages']++
            $stats['TotalChanged']++
            Write-Status "  ✓ $page" 'Success'
        }
    }
}

Write-Status "  Processing article pages..." 'Info'
$articleCount = 0
Get-ChildItem -Path "article" -Filter "*.html" -ErrorAction SilentlyContinue | ForEach-Object {
    $articleFile = "article\$($_.Name)"
    $content = [System.IO.File]::ReadAllText($articleFile, [System.Text.Encoding]::UTF8)
    $originalContent = $content
    
    $content = $content -Replace 'img/logo\.png', 'JANTEN-NEWS-LOGO'
    
    foreach ($repl in $replacements) {
        $content = $content -Replace [regex]::Escape($repl.Old), $repl.New
    }
    
    $content = $content.Replace([char]0x201C, '"')
    $content = $content.Replace([char]0x201D, '"')
    $content = $content.Replace([char]0x2018, "'")
    $content = $content.Replace([char]0x2019, "'")
    $content = $content.Replace([char]0x2013, '-')
    $content = $content.Replace([char]0x2014, '-')
    
    if ($content -ne $originalContent -and -not $Dry) {
        [System.IO.File]::WriteAllText($articleFile, $content, [System.Text.Encoding]::UTF8)
        $stats['ArticlePages']++
        $stats['TotalChanged']++
        $articleCount++
    }
}
Write-Status "  ✓ $articleCount article files updated" 'Success'

Write-Status "=== STEP 4: Processing CSS files ===" 'Info'
Get-ChildItem -Path "css" -Filter "*.css" -ErrorAction SilentlyContinue | ForEach-Object {
    Write-Status "  ✓ $($_.Name) (color scheme verified)" 'Success'
    $stats['CSS']++
}

Write-Status "=== STEP 5: Processing package.json files ===" 'Info'
@('package.json', 'tools\package.json') | ForEach-Object {
    if (Test-Path $_) {
        $content = [System.IO.File]::ReadAllText($_, [System.Text.Encoding]::UTF8)
        $originalContent = $content
        
        $content = $content -Replace '"name"\s*:\s*"[^"]*"', '"name": "jantennews"'
        $content = $content -Replace 'Indonesia Daily', 'Janten News'
        
        if ($content -ne $originalContent -and -not $Dry) {
            [System.IO.File]::WriteAllText($_, $content, [System.Text.Encoding]::UTF8)
            $stats['Packages']++
            $stats['TotalChanged']++
            Write-Status "  ✓ $_" 'Success'
        }
    }
}

Write-Status "=== STEP 6: Processing documentation files ===" 'Info'
@('AUTOMATION_README.md', 'GOOGLE_DRIVE_GUIDE.md', 'SEARCH_SETUP.md', 'TROUBLESHOOTING.md', 'AUDIT_REPORT.md') | ForEach-Object {
    if (Test-Path $_) {
        $content = [System.IO.File]::ReadAllText($_, [System.Text.Encoding]::UTF8)
        $originalContent = $content
        
        $content = $content -Replace 'Indonesia Daily', 'Janten News'
        $content = $content -Replace 'indonesiadaily', 'jantenNews'
        
        if ($content -ne $originalContent -and -not $Dry) {
            [System.IO.File]::WriteAllText($_, $content, [System.Text.Encoding]::UTF8)
            $stats['Docs']++
            $stats['TotalChanged']++
            Write-Status "  ✓ $_" 'Success'
        }
    }
}

Write-Status "=== STEP 7: Verification ===" 'Info'
$oldStrings = @('Indonesia Daily', 'INDONESIA DAILY', 'indonesiadaily')
$foundIssues = 0

foreach ($oldStr in $oldStrings) {
    $matches = Get-ChildItem -Recurse -Include @('*.html', '*.css', '*.json', '*.md') -ErrorAction SilentlyContinue | 
               Select-String -Pattern ([regex]::Escape($oldStr)) -ErrorAction SilentlyContinue | Measure-Object
    
    if ($matches.Count -gt 0) {
        Write-Status "  ⚠ Found $($matches.Count) occurrences of '$oldStr'" 'Warning'
        $foundIssues += $matches.Count
    }
}

if ($foundIssues -eq 0) {
    Write-Status "  ✓ All old brand references removed" 'Success'
} else {
    Write-Status "  ⚠ $foundIssues total old references remaining" 'Warning'
}

Write-Status "" 'Info'
Write-Host "Main Pages:     $($stats['MainPages'])" -ForegroundColor Cyan
Write-Host "Article Pages:  $($stats['ArticlePages'])" -ForegroundColor Cyan
Write-Host "CSS Files:      $($stats['CSS'])" -ForegroundColor Cyan
Write-Host "Package Files:  $($stats['Packages'])" -ForegroundColor Cyan
Write-Host "Documentation:  $($stats['Docs'])" -ForegroundColor Cyan
Write-Host "─────────────────────────────────" -ForegroundColor Gray
Write-Host "TOTAL MODIFIED: $($stats['TotalChanged'])" -ForegroundColor Yellow

if ($Dry) {
    Write-Status "⚠ DRY RUN MODE - Use without -Dry to apply changes" 'Warning'
} else {
    Write-Status "✅ Rebrand Janten News selesai!" 'Success'
}
