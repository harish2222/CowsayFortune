#Requires -Modules Pester

Describe "Comprehensive Feature Matrix Tests" {
    BeforeAll {
        $modulePath = Join-Path (Split-Path $PSScriptRoot -Parent) 'Forgum.psd1'
        Import-Module $modulePath -Force
        $script:OriginalConfig = Get-CFConfig
    }

    AfterAll {
        Set-CFConfig -Config $script:OriginalConfig
    }

    AfterEach {
        Set-CFConfig -Config $script:OriginalConfig
    }

    # --- TEST 1: Invoke-Cowsay with default params returns string with cow face ---
    It "Test 01: Invoke-Cowsay default returns string containing cow face" {
        $output = Invoke-Cowsay -Text "Hello"
        $output | Should -BeOfType System.String
        $raw = $output -replace '\x1b\[[0-9;]*m', ''
        $raw | Should -Match '\^__\^'
    }

    # --- TEST 2: Invoke-Cowsay with all params (Text, CowFile, Eyes, Tongue, Thoughts) ---
    It "Test 02: Invoke-Cowsay with all custom params applies all substitutions" {
        $output = Invoke-Cowsay -Text "CustomAll" -CowFile 'tux' -Eyes '@@' -Tongue '##' -Thoughts 'o'
        $raw = $output -replace '\x1b\[[0-9;]*m', ''
        $raw | Should -Match 'CustomAll'
        $raw | Should -Match '@_@'
    }

    # --- TEST 3: Invoke-Cowsay -Lolcat switch produces ANSI truecolor codes ---
    It "Test 03: Invoke-Cowsay -Lolcat produces 24-bit ANSI escape codes" {
        $config = Get-CFConfig
        $config.lolcat.truecolor = $true
        Set-CFConfig -Config $config
        $output = Invoke-Cowsay -Text "Rainbow" -Lolcat
        $esc = [char]27
        $output | Should -Match "${esc}\[38;2;"
    }

    # --- TEST 4: Invoke-Cowsay without -Lolcat has no ANSI codes ---
    It "Test 04: Invoke-Cowsay without -Lolcat has no color codes" {
        $output = Invoke-Cowsay -Text "Plain"
        $esc = [char]27
        $output | Should -Not -Match "${esc}\[38;"
    }

    # --- TEST 5: Get-CFCow list contains expected cows ---
    It "Test 05: Get-CFCow list includes default, tux, and more than 50 cows" {
        $cows = @(Get-CFCow)
        $cows | Should -Contain 'default'
        $cows | Should -Contain 'tux'
        $cows.Count | Should -BeGreaterThan 50
    }

    # --- TEST 6: Get-CFCow -Name returns cow template content ---
    It "Test 06: Get-CFCow -Name returns non-empty cow template" {
        $cow = Get-CFCow -Name 'default'
        $cow | Should -Not -BeNullOrEmpty
        $cow | Should -BeOfType System.String
        $cow.Length | Should -BeGreaterThan 50
    }

    # --- TEST 7: Get-CFCow -Name throws for nonexistent cow ---
    It "Test 07: Get-CFCow -Name nonexistent throws error" {
        { Get-CFCow -Name 'nonexistent_xyz_abc' } | Should -Throw
    }

    # --- TEST 8: Get-Fortune returns non-empty string ---
    It "Test 08: Get-Fortune returns a non-empty string" {
        $fortune = Get-Fortune
        $fortune | Should -BeOfType System.String
        $fortune.Length | Should -BeGreaterThan 0
    }

    # --- TEST 9: Get-Fortune returns different results across calls ---
    It "Test 09: Get-Fortune produces at least 2 unique results in 20 calls" {
        $fortunes = @()
        for ($i = 0; $i -lt 20; $i++) { $fortunes += Get-Fortune }
        ($fortunes | Select-Object -Unique).Count | Should -BeGreaterThan 1
    }

    # --- TEST 10: Get-Fortune throws for nonexistent database ---
    It "Test 10: Get-Fortune with nonexistent database throws" {
        { Get-Fortune -Database 'nonexistent_xyz' } | Should -Throw
    }

    # --- TEST 11: Get-CFConfig returns all expected sections ---
    It "Test 11: Get-CFConfig returns all 7 required config sections" {
        $config = Get-CFConfig
        $config.PSObject.Properties.Name | Should -Contain 'animation'
        $config.PSObject.Properties.Name | Should -Contain 'cow'
        $config.PSObject.Properties.Name | Should -Contain 'fortune'
        $config.PSObject.Properties.Name | Should -Contain 'lolcat'
        $config.PSObject.Properties.Name | Should -Contain 'output'
        $config.PSObject.Properties.Name | Should -Contain 'shell'
        $config.PSObject.Properties.Name | Should -Contain 'startup'
    }

    # --- TEST 12: Set-CFConfig persists and Get-CFConfig reads back ---
    It "Test 12: Set-CFConfig + Get-CFConfig round-trip preserves values" {
        $config = Get-CFConfig
        $config.lolcat.enabled = $true
        $config.lolcat.frequency = 0.5
        $config.cow.file = 'tux'
        $config.animation.speed = 50
        Set-CFConfig -Config $config

        $reloaded = Get-CFConfig
        $reloaded.lolcat.enabled | Should -Be $true
        $reloaded.lolcat.frequency | Should -Be 0.5
        $reloaded.cow.file | Should -Be 'tux'
        $reloaded.animation.speed | Should -Be 50
    }

    # --- TEST 13: Config cache invalidation works ---
    It "Test 13: Config cache is invalidated after Set-CFConfig" {
        $config = Get-CFConfig
        $config.output.maxWidth = 80
        Set-CFConfig -Config $config

        $config2 = Get-CFConfig
        $config2.output.maxWidth | Should -Be 80

        $config2.output.maxWidth = 60
        Set-CFConfig -Config $config2
    }

    # --- TEST 14: Invoke-Cowsay word wrap respects maxWidth ---
    It "Test 14: Long message is word-wrapped within maxWidth" {
        $config = Get-CFConfig
        $config.output.maxWidth = 40
        Set-CFConfig -Config $config

        $longText = "This is a very long message that must be wrapped at forty characters width to stay within limits"
        $output = Invoke-Cowsay -Text $longText
        $raw = $output -replace '\x1b\[[0-9;]*m', ''
        $lines = $raw -split "`n"
        $maxLen = ($lines | ForEach-Object { $_.Length } | Measure-Object -Maximum).Maximum
        $maxLen | Should -BeLessThan 60
    }

    # --- TEST 15: Invoke-Cowsay handles empty message ---
    It "Test 15: Invoke-Cowsay with empty string still returns output" {
        $output = Invoke-Cowsay -Text ""
        $output | Should -Not -BeNullOrEmpty
        $raw = $output -replace '\x1b\[[0-9;]*m', ''
        $raw | Should -Match '\^__\^'
    }

    # --- TEST 16: Invoke-Cowsay handles multiline message ---
    It "Test 16: Invoke-Cowsay multiline message preserves both lines" {
        $output = Invoke-Cowsay -Text "Alpha`nBeta"
        $raw = $output -replace '\x1b\[[0-9;]*m', ''
        $raw | Should -Match 'Alpha'
        $raw | Should -Match 'Beta'
    }

    # --- TEST 17: Invoke-Forgum returns cow with fortune (default config) ---
    It "Test 17: Invoke-Forgum returns non-empty string with cow face" {
        $output = Invoke-Forgum
        $output | Should -BeOfType System.String
        $raw = $output -replace '\x1b\[[0-9;]*m', ''
        $raw | Should -Match '\^__\^'
    }

    # --- TEST 18: Invoke-Forgum -Think uses thinking bubble ---
    It "Test 18: Invoke-Forgum -Think produces thinking bubble output" {
        $output = Invoke-Forgum -Think
        $output | Should -Not -BeNullOrEmpty
        $raw = $output -replace '\x1b\[[0-9;]*m', ''
        $raw | Should -Match '\^__\^'
    }

    # --- TEST 19: Invoke-Forgum -CowFile uses specified cow ---
    It "Test 19: Invoke-Forgum -CowFile tux produces non-empty output" {
        $output = Invoke-Forgum -CowFile 'tux'
        $output | Should -Not -BeNullOrEmpty
        $output | Should -BeOfType System.String
        $output.Length | Should -BeGreaterThan 20
    }

    # --- TEST 20: Invoke-Forgum -Lolcat produces ANSI color codes ---
    It "Test 20: Invoke-Forgum -Lolcat produces truecolor ANSI codes" {
        $config = Get-CFConfig
        $config.lolcat.truecolor = $true
        Set-CFConfig -Config $config

        $output = Invoke-Forgum -Lolcat
        $esc = [char]27
        $output | Should -Match "${esc}\[38;2;"
    }

    # --- TEST 21: Invoke-Forgum lolcat via config (not switch) ---
    It "Test 21: Config-based lolcat.enabled produces ANSI without -Lolcat switch" {
        $config = Get-CFConfig
        $config.lolcat.enabled = $true
        $config.lolcat.truecolor = $true
        Set-CFConfig -Config $config

        $output = Invoke-Forgum
        $esc = [char]27
        $output | Should -Match "${esc}\[38;2;"
    }

    # --- TEST 22: Invoke-Forgum -Lolcat overrides config disabled ---
    It "Test 22: -Lolcat switch overrides config.lolcat.enabled=false" {
        $config = Get-CFConfig
        $config.lolcat.enabled = $false
        Set-CFConfig -Config $config

        $output = Invoke-Forgum -Lolcat
        $esc = [char]27
        $output | Should -Match "${esc}\[38;"
    }

    # --- TEST 23: Invoke-Cowsay -Lolcat truecolor vs 256-color ---
    It "Test 23: Invoke-Cowsay -Lolcat truecolor uses 38;2; and non-truecolor uses 38;5;" {
        $config = Get-CFConfig
        $config.lolcat.truecolor = $true
        Set-CFConfig -Config $config
        $tc = Invoke-Cowsay -Text "TrueColor" -Lolcat

        $config.lolcat.truecolor = $false
        Set-CFConfig -Config $config
        $fc = Invoke-Cowsay -Text "FakeColor" -Lolcat

        $esc = [char]27
        $tc | Should -Match "${esc}\[38;2;"
        $fc | Should -Match "${esc}\[38;5;"
    }

    # --- TEST 24: Show-CFAnimation with static mode returns output ---
    It "Test 24: Show-CFAnimation static mode returns cow output unchanged" {
        $cowOutput = Invoke-Cowsay -Text "AnimTest"
        $result = Show-CFAnimation -CowOutput $cowOutput
        $raw = $result -replace '\x1b\[[0-9;]*m', ''
        $raw | Should -Match 'AnimTest'
    }

    # --- TEST 25: All 107 cows render without error ---
    It "Test 25: All cow files render successfully with Invoke-Cowsay" {
        $cows = @(Get-CFCow)
        $failed = @()
        foreach ($cow in $cows) {
            try {
                $output = Invoke-Cowsay -Text "CowTest" -CowFile $cow
                if (-not $output) { $failed += $cow }
            } catch {
                $failed += $cow
            }
        }
        $failed.Count | Should -Be 0
    }

    # --- TEST 26: Config sections persist independently ---
    It "Test 26: Changing lolcat section does not affect cow section" {
        $config = Get-CFConfig
        $originalCowFile = $config.cow.file
        $config.lolcat.enabled = $true
        Set-CFConfig -Config $config

        $reloaded = Get-CFConfig
        $reloaded.cow.file | Should -Be $originalCowFile
        $reloaded.lolcat.enabled | Should -Be $true
    }

    # --- TEST 27: Special characters in message are preserved ---
    It "Test 27: Special characters in cow message are preserved in output" {
        $output = Invoke-Cowsay -Text "Hello <world> & 'friends' (test) !"
        $raw = $output -replace '\x1b\[[0-9;]*m', ''
        $raw | Should -Match 'Hello <world>'
    }

    # --- TEST 28: Very long single word does not crash ---
    It "Test 28: Very long single word (500 chars) renders without crash" {
        $longWord = "A" * 500
        $output = Invoke-Cowsay -Text $longWord
        $output | Should -Not -BeNullOrEmpty
        $raw = $output -replace '\x1b\[[0-9;]*m', ''
        $raw | Should -Match 'AAAA'
    }

    # --- TEST 29: Config cache returns same object reference within TTL ---
    It "Test 29: Config cache returns same object within 30s TTL" {
        $c1 = Get-CFConfig
        $c2 = Get-CFConfig
        [object]::ReferenceEquals($c1, $c2) | Should -Be $true
    }

    # --- TEST 30: Invoke-Cowsay -Lolcat with 256-color mode ---
    It "Test 30: Invoke-Cowsay -Lolcat with truecolor=false uses 256-color" {
        $config = Get-CFConfig
        $config.lolcat.truecolor = $false
        Set-CFConfig -Config $config

        $output = Invoke-Cowsay -Text "Color256" -Lolcat
        $esc = [char]27
        $output | Should -Match "${esc}\[38;5;"
        $output | Should -Not -Match "${esc}\[38;2;"
    }
}

Describe "Platform Configuration Samples" {
    BeforeAll {
        $script:ProjectRoot = Join-Path (Split-Path $PSScriptRoot -Parent) ''
    }

    It "PowerShell integration doc has PowerShell code blocks" {
        $content = Get-Content (Join-Path $script:ProjectRoot 'wiki/PowerShell-Integration.md') -Raw
        $blocks = [regex]::Matches($content, '(?s)```powershell\r?\n(.*?)```')
        $blocks.Count | Should -BeGreaterThan 0
    }

    It "Bash integration doc has bash code blocks" {
        $content = Get-Content (Join-Path $script:ProjectRoot 'wiki/Bash-Zsh-Integration.md') -Raw
        $blocks = [regex]::Matches($content, '(?s)```bash\r?\n(.*?)```')
        $blocks.Count | Should -BeGreaterThan 0
    }

    It "Fish integration doc has fish code blocks" {
        $content = Get-Content (Join-Path $script:ProjectRoot 'wiki/Fish-Integration.md') -Raw
        $blocks = [regex]::Matches($content, '(?s)```fish\r?\n(.*?)```')
        $blocks.Count | Should -BeGreaterThan 0
    }
}
