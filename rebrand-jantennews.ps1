# Rebrand Script: Indonesia Daily -> Janten News
# Developed: 2026-03-30
# Purpose: Complete branding migration with encoding fixes

param(
    [switch]$Verify = $false,
    [switch]$Dry = $false,
    [switch]$Verbose = $false
)

# Colors for output
$colors = @{
    Success = 'Green'
    Error   = 'Red'
    Warning = 'Yellow'
    Info    = 'Cyan'
}

function Write-Status {
    param([string]$Message, [string]$Type = 'Info')
    Write-Host $Message -ForegroundColor $colors[$Type]
}

# Counters
$stats = @{
    MainPages    = 0
    ArticlePages = 0
    CSS          = 0
    Packages     = 0
    Docs         = 0
    TotalChanged = 0
}

# Step 1: Backup articles.json
Write-Status "=== STEP 1: Backup articles.json ===" 'Info'
$backupPath = "articles.json.bak.$(Get-Date -Format 'yyyyMMddHHmmss')"
if (Test-Path 'articles.json') {
    Copy-Item 'articles.json' $backupPath
    Write-Status "✓ Backup created: $backupPath" 'Success'
} else {
    Write-Status "! articles.json not found" 'Warning'
}

# Step 2: Define replacement mappings
Write-Status "=== STEP 2: Setting up replacement rules ===" 'Info'

$replacements = @(
    @{ Old = 'Indonesia Daily'; New = 'Janten News'; Context = 'Brand Name' },
    @{ Old = 'INDONESIA DAILY'; New = 'JANTEN NEWS'; Context = 'Brand Name (Uppercase)' },
    @{ Old = 'indonesiadaily'; New = 'jantenNews'; Context = 'Brand Name (Camelcase)' },
    @{ Old = 'IndonesiaDaily'; New = 'JantenNews'; Context = 'Brand Name (PascalCase)' },
    @{ Old = 'www.indonesiakku.com'; New = 'jantenNews'; Context = 'URL reference' },
    @{ Old = 'indonesiakku@gmail.com'; New = 'jantenNews@gmail.com'; Context = 'Email' },
    @{ Old = 'Contact Us - Indonesia Daily'; New = 'Contact Us - Janten News'; Context = 'Page Title' },
    @{ Old = 'Search - Indonesia Daily'; New = 'Search - Janten News'; Context = 'Page Title' },
    @{ Old = 'News - Indonesia Daily'; New = 'News - Janten News'; Context = 'Page Title' },
    @{ Old = 'Berita - Indonesia Daily'; New = 'Berita - Janten News'; Context = 'Page Title' },
    @{ Old = 'Register - Indonesia Daily'; New = 'Register - Janten News'; Context = 'Page Title' },
    @{ Old = 'Login - Indonesia Daily'; New = 'Login - Janten News'; Context = 'Page Title' }
)

# Quotation encoding fixes
$quotationFixes = @(
    @{ Old = [char]0x201C; New = '"'; Context = 'Left Double Quote (U+201C)' },  # "
    @{ Old = [char]0x201D; New = '"'; Context = 'Right Double Quote (U+201D)' }, # "
    @{ Old = [char]0x2018; New = "'"; Context = 'Left Single Quote (U+2018)' },  # '
    @{ Old = [char]0x2019; New = "'"; Context = 'Right Single Quote (U+2019)' }  # '
)

# Dash replacements
$dashFixes = @(
    @{ Old = [char]0x2013; New = '-'; Context = 'En Dash (U+2013)' },            # –
    @{ Old = [char]0x2014; New = '-'; Context = 'Em Dash (U+2014)' }             # —
)

# Step 3: Process HTML files
Write-Status "=== STEP 3: Processing HTML files ===" 'Info'

# Main pages
$mainPages = @('index.html', 'news.html', 'contact.html', 'search.html', 'login.html', 'register.html', 'clearstorage.html', 'testauth.html', 'debug-images.html')
foreach ($page in $mainPages) {
    if (Test-Path $page) {
        $content = [System.IO.File]::ReadAllText($page, [System.Text.Encoding]::UTF8)
        $originalContent = $content
        
        # Apply branding replacements
        foreach ($repl in $replacements) {
            $content = $content -Replace [regex]::Escape($repl.Old), $repl.New
        }
        
        # Apply quotation fixes
        foreach ($fix in $quotationFixes) {
            $content = $content.Replace($fix.Old, $fix.New)
        }
        
        # Apply dash fixes
        foreach ($fix in $dashFixes) {
            $content = $content.Replace($fix.Old, $fix.New)
        }
        
        if ($content -ne $originalContent) {
            if (-not $Dry) {
                [System.IO.File]::WriteAllText($page, $content, [System.Text.Encoding]::UTF8)
                $stats['MainPages']++
                $stats['TotalChanged']++
            }
            Write-Status "  ✓ $page" 'Success'
        }
    }
}

# Article pages
Write-Status "  Processing article pages..." 'Info'
$articleCount = 0
Get-ChildItem -Path "article" -Name "*.html" -ErrorAction SilentlyContinue | ForEach-Object {
    $articleFile = "article\$_"
    $content = [System.IO.File]::ReadAllText($articleFile, [System.Text.Encoding]::UTF8)
    $originalContent = $content
    
    # Replace logo.png references with text logo
    $content = $content -Replace 'img/logo\.png', 'JANTEN-NEWS-LOGO'
    
    # Apply branding replacements
    foreach ($repl in $replacements) {
        $content = $content -Replace [regex]::Escape($repl.Old), $repl.New
    }
    
    # Apply encoding fixes
    foreach ($fix in $quotationFixes) {
        $content = $content.Replace($fix.Old, $fix.New)
    }
    foreach ($fix in $dashFixes) {
        $content = $content.Replace($fix.Old, $fix.New)
    }
    
    if ($content -ne $originalContent) {
        if (-not $Dry) {
            [System.IO.File]::WriteAllText($articleFile, $content, [System.Text.Encoding]::UTF8)
            $stats['ArticlePages']++
            $stats['TotalChanged']++
        }
        $articleCount++
    }
}
if ($articleCount -gt 0) {
    Write-Status "  ✓ $articleCount article files updated" 'Success'
}

# Step 4: Update CSS files
Write-Status "=== STEP 4: Processing CSS files ===" 'Info'
Get-ChildItem -Path "css" -Name "*.css" -ErrorAction SilentlyContinue | ForEach-Object {
    $cssFile = "css\$_"
    $content = [System.IO.File]::ReadAllText($cssFile, [System.Text.Encoding]::UTF8)
    $originalContent = $content
    
    # Verify new color scheme is present
    if ($content -match '--primary:\s*#7C2D12') {
        Write-Status "  ✓ $_ (color scheme verified)" 'Success'
    }
    
    if ($content -ne $originalContent) {
        $stats['CSS']++
    }
}

# Step 5: Update package.json files
Write-Status "=== STEP 5: Processing package.json files ===" 'Info'
$packageFiles = @('package.json', 'tools/package.json')
foreach ($pkgFile in $packageFiles) {
    if (Test-Path $pkgFile) {
        $content = [System.IO.File]::ReadAllText($pkgFile, [System.Text.Encoding]::UTF8)
        $originalContent = $content
        
        # Update name field
        $content = $content -Replace '"name":\s*"[^"]*"', '"name": "jantennews"'
        
        # Update description if present
        $content = $content -Replace 'Indonesia Daily', 'Janten News'
        
        if ($content -ne $originalContent) {
            if (-not $Dry) {
                [System.IO.File]::WriteAllText($pkgFile, $content, [System.Text.Encoding]::UTF8)
                $stats['Packages']++
                $stats['TotalChanged']++
            }
            Write-Status "  ✓ $pkgFile" 'Success'
        }
    }
}

# Step 6: Update documentation files
Write-Status "=== STEP 6: Processing documentation files ===" 'Info'
$docFiles = @('AUTOMATION_README.md', 'GOOGLE_DRIVE_GUIDE.md', 'GOOGLE_DRIVE_IMAGES_GUIDE.md', 'SEARCH_SETUP.md', 'TROUBLESHOOTING.md', 'PERBAIKAN_STATUS.md', 'AUDIT_REPORT.md')
foreach ($docFile in $docFiles) {
    if (Test-Path $docFile) {
        $content = [System.IO.File]::ReadAllText($docFile, [System.Text.Encoding]::UTF8)
        $originalContent = $content
        
        $content = $content -Replace 'Indonesia Daily', 'Janten News'
        $content = $content -Replace 'indonesiadaily', 'jantenNews'
        $content = $content -Replace 'INDONESIA DAILY', 'JANTEN NEWS'
        
        if ($content -ne $originalContent) {
            if (-not $Dry) {
                [System.IO.File]::WriteAllText($docFile, $content, [System.Text.Encoding]::UTF8)
                $stats['Docs']++
                $stats['TotalChanged']++
            }
            Write-Status "  ✓ $docFile" 'Success'
        }
    }
}

# Step 7: Update netlify.toml if exists
if (Test-Path 'netlify.toml') {
    Write-Status "=== STEP 7: Processing netlify.toml ===" 'Info'
    $content = [System.IO.File]::ReadAllText('netlify.toml', [System.Text.Encoding]::UTF8)
    $originalContent = $content
    
    $content = $content -Replace 'Indonesia Daily', 'Janten News'
    $content = $content -Replace 'indonesiadaily', 'jantenNews'
    
    if ($content -ne $originalContent) {
        if (-not $Dry) {
            [System.IO.File]::WriteAllText('netlify.toml', $content, [System.Text.Encoding]::UTF8)
            $stats['Docs']++
            $stats['TotalChanged']++
        }
        Write-Status "  ✓ netlify.toml" 'Success'
    }
}

# Step 8: Verification
if ($Verify) {
    Write-Status "=== STEP 8: Verification ===" 'Info'
    
    $oldStrings = @('Indonesia Daily', 'INDONESIA DAILY', 'indonesiadaily', 'IndonesiaDaily', 'img/logo.png')
    $foundIssues = $false
    
    foreach ($oldStr in $oldStrings) {
        $matches = Get-ChildItem -Recurse -Include *.html, *.css, *.json, *.md | 
                   Select-String -Pattern ([regex]::Escape($oldStr)) -ErrorAction SilentlyContinue |
                   Measure-Object
        
        if ($matches.Count -gt 0) {
            Write-Status "  ⚠ Found $($matches.Count) occurrences of '$oldStr'" 'Warning'
            $foundIssues = $true
        }
    }
    
    if (-not $foundIssues) {
        Write-Status "  ✓ All old brand references removed" 'Success'
    }
    
    # Verify new colors
    $colorMatches = Get-ChildItem -Name "css/*.css" | 
                    Select-String -Pattern '#7C2D12|#2A0E05|#1A5E6E' |
                    Measure-Object
    Write-Status "  ✓ Found $($colorMatches.Count) new color references" 'Success'
}

# Final report
Write-Status "=== REBRAND REPORT ===" 'Info'
Write-Host ""
Write-Host "Main Pages:     $($stats['MainPages'])" -ForegroundColor Cyan
Write-Host "Article Pages:  $($stats['ArticlePages'])" -ForegroundColor Cyan
Write-Host "CSS Files:      $($stats['CSS'])" -ForegroundColor Cyan
Write-Host "Package Files:  $($stats['Packages'])" -ForegroundColor Cyan
Write-Host "Documentation:  $($stats['Docs'])" -ForegroundColor Cyan
Write-Host "─────────────────────────────────" -ForegroundColor Gray
Write-Host "TOTAL MODIFIED: $($stats['TotalChanged'])" -ForegroundColor Yellow
Write-Host ""

if ($Dry) {
    Write-Status "⚠ DRY RUN MODE - No files were modified" 'Warning'
} else {
    Write-Status "✅ Rebrand Janten News selesai!" 'Success'
}

if ($Verify) {
    Write-Status "✅ Verification completed" 'Success'
}
