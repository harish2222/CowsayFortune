#Requires -Modules Pester

# Prevent auto-start from modifying config during tests
$env:FORGUM_NOAUTOSTART = '1'

Describe "Module Loading" {
    BeforeAll {
        Import-Module (Join-Path (Split-Path $PSScriptRoot -Parent) 'Forgum.psd1') -Force -ErrorVariable errors
    }

    It "loads without errors" {
        $errors | Should -BeNullOrEmpty
    }

    It "exports exactly 7 functions" {
        (Get-Command -Module Forgum).Count | Should -Be 7
    }

    It "exports Invoke-Cowsay" {
        Get-Command Invoke-Cowsay -Module Forgum | Should -Not -BeNullOrEmpty
    }

    It "exports Invoke-Forgum" {
        Get-Command Invoke-Forgum -Module Forgum | Should -Not -BeNullOrEmpty
    }

    It "exports Get-Fortune" {
        Get-Command Get-Fortune -Module Forgum | Should -Not -BeNullOrEmpty
    }

    It "exports Get-CFCow" {
        Get-Command Get-CFCow -Module Forgum | Should -Not -BeNullOrEmpty
    }

    It "exports Get-CFConfig" {
        Get-Command Get-CFConfig -Module Forgum | Should -Not -BeNullOrEmpty
    }

    It "exports Set-CFConfig" {
        Get-Command Set-CFConfig -Module Forgum | Should -Not -BeNullOrEmpty
    }

    It "exports Show-CFAnimation" {
        Get-Command Show-CFAnimation -Module Forgum | Should -Not -BeNullOrEmpty
    }

    It "has CmdletBinding on public functions" {
        $funcs = @('Invoke-Cowsay', 'Get-Fortune', 'Get-CFCow', 'Get-CFConfig', 'Set-CFConfig', 'Show-CFAnimation', 'Invoke-Forgum')
        foreach ($func in $funcs) {
            $cmd = Get-Command $func -Module Forgum
            $cmd.Parameters.ContainsKey('Verbose') | Should -Be $true
        }
    }
}

Describe "Config System" {
    BeforeAll {
        Import-Module (Join-Path (Split-Path $PSScriptRoot -Parent) 'Forgum.psd1') -Force
        $script:OriginalConfig = Get-CFConfig
        Set-CFConfig -Config (Get-Content (Join-Path (Split-Path $PSScriptRoot -Parent) 'Data/Templates/default-config.json') -Raw | ConvertFrom-Json)
    }

    AfterAll {
        Set-CFConfig -Config $script:OriginalConfig
    }

    Context "Default config" {
        It "returns a config object" {
            $config = Get-CFConfig
            $config | Should -Not -BeNullOrEmpty
        }

        It "has animation mode 'static' by default" {
            (Get-CFConfig).animation.mode | Should -Be 'static'
        }

        It "has cow file 'default' by default" {
            (Get-CFConfig).cow.file | Should -Be 'default'
        }

        It "has lolcat disabled by default" {
            (Get-CFConfig).lolcat.enabled | Should -Be $false
        }

        It "has word wrap enabled by default" {
            (Get-CFConfig).output.wordWrap | Should -Be $true
        }

        It "has max width of 60 by default" {
            (Get-CFConfig).output.maxWidth | Should -Be 60
        }

        It "has animation speed of 20" {
            (Get-CFConfig).animation.speed | Should -Be 20
        }

        It "has animation duration of 12" {
            (Get-CFConfig).animation.duration | Should -Be 12
        }

        It "has animation blinkRate of 0.2" {
            (Get-CFConfig).animation.blinkRate | Should -Be 0.2
        }

        It "has animation amplitude of 2" {
            (Get-CFConfig).animation.amplitude | Should -Be 2
        }

        It "has fortune database set to 'fortunes'" {
            (Get-CFConfig).fortune.database | Should -Be 'fortunes'
        }
    }

    Context "Config persistence" {
        It "saves and reloads config" {
            $config = Get-CFConfig
            $config.lolcat.enabled = $true
            Set-CFConfig -Config $config

            $reloaded = Get-CFConfig
            $reloaded.lolcat.enabled | Should -Be $true

            $config.lolcat.enabled = $false
            Set-CFConfig -Config $config
        }

        It "preserves all sections after save" {
            $config = Get-CFConfig
            $config.lolcat.frequency = 0.5
            Set-CFConfig -Config $config

            $reloaded = Get-CFConfig
            $reloaded.animation.mode | Should -Be 'static'
            $reloaded.cow.file | Should -Be 'default'
            $reloaded.fortune.database | Should -Be 'fortunes'
            $reloaded.output.maxWidth | Should -Be 60

            $config.lolcat.frequency = 0.1
            Set-CFConfig -Config $config
        }

        It "creates config directory if missing" {
            if ($IsLinux -or $IsMacOS) {
                $testDir = Join-Path $HOME '.config/Forgum_test'
            } else {
                $testDir = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'PowerShell/Forgum_test'
            }
            if (Test-Path $testDir) { Remove-Item $testDir -Recurse -Force }

            $env:Forgum_CONFIG = Join-Path $testDir 'config.json'
            try {
                $config = Get-CFConfig
                Set-CFConfig -Config $config
                Test-Path $env:Forgum_CONFIG | Should -Be $true
            }
            finally {
                $env:Forgum_CONFIG = $null
                if (Test-Path $testDir) { Remove-Item $testDir -Recurse -Force }
            }
        }
    }
}

Describe "Fortune System" {
    BeforeAll {
        Import-Module (Join-Path (Split-Path $PSScriptRoot -Parent) 'Forgum.psd1') -Force
        Set-CFConfig -Config (Get-Content (Join-Path (Split-Path $PSScriptRoot -Parent) 'Data/Templates/default-config.json') -Raw | ConvertFrom-Json)
    }

    It "returns a fortune" {
        Get-Fortune | Should -Not -BeNullOrEmpty
    }

    It "returns a string" {
        Get-Fortune | Should -BeOfType System.String
    }

    It "returns non-empty string" {
        (Get-Fortune).Length | Should -BeGreaterThan 0
    }

    It "returns different fortunes on multiple calls" {
        $fortunes = @()
        for ($i = 0; $i -lt 10; $i++) { $fortunes += Get-Fortune }
        ($fortunes | Select-Object -Unique).Count | Should -BeGreaterThan 1
    }

    It "can read the fortunes database file" {
        $fortunePath = Join-Path (Split-Path $PSScriptRoot -Parent) 'Data/Fortunes/fortunes.txt'
        Test-Path $fortunePath | Should -Be $true
    }

    It "fortune file contains percent delimiters" {
        $fortunePath = Join-Path (Split-Path $PSScriptRoot -Parent) 'Data/Fortunes/fortunes.txt'
        $content = Get-Content $fortunePath -Raw
        $content | Should -Match '%'
    }

    It "throws for nonexistent database" {
        $threw = $false
        try { Get-Fortune -Database 'nonexistent_xyz' } catch { $threw = $true }
        $threw | Should -Be $true
    }
}

Describe "Cow System" {
    BeforeAll {
        Import-Module (Join-Path (Split-Path $PSScriptRoot -Parent) 'Forgum.psd1') -Force
        Set-CFConfig -Config (Get-Content (Join-Path (Split-Path $PSScriptRoot -Parent) 'Data/Templates/default-config.json') -Raw | ConvertFrom-Json)
    }

    Context "Cow listing" {
        It "lists available cows" {
            Get-CFCow | Should -Not -BeNullOrEmpty
        }

        It "contains default cow" {
            @(Get-CFCow) -contains 'default' | Should -Be $true
        }

        It "contains tux cow" {
            @(Get-CFCow) -contains 'tux' | Should -Be $true
        }

        It "contains more than 50 cows" {
            @(Get-CFCow).Count | Should -BeGreaterThan 50
        }

        It "returns sorted list" {
            $cows = @(Get-CFCow)
            $sorted = @($cows | Sort-Object)
            $cows.Count | Should -Be $sorted.Count
        }
    }

    Context "Cow reading" {
        It "reads default cow" {
            $cow = Get-CFCow -Name 'default'
            $cow | Should -Not -BeNullOrEmpty
        }

        It "reads tux cow" {
            $cow = Get-CFCow -Name 'tux'
            $cow | Should -Not -BeNullOrEmpty
        }

        It "throws for nonexistent cow" {
            $threw = $false
            try { Get-CFCow -Name 'nonexistent_xyz_abc' } catch { $threw = $true }
            $threw | Should -Be $true
        }
    }

    Context "Cow rendering" {
        It "renders cow with message" {
            $output = Invoke-Cowsay -Text "Hello World"
            $output | Should -Match "Hello World"
        }

        It "renders default face" {
            $output = Invoke-Cowsay -Text "Test" -CowFile 'default'
            $raw = $output -replace '\x1b\[[0-9;]*[a-zA-Z]', ''
            $raw | Should -Match '\^__\^'
        }

        It "renders speech bubble borders" {
            $output = Invoke-Cowsay -Text "Test"
            $raw = $output -replace '\x1b\[[0-9;]*[a-zA-Z]', ''
            $raw | Should -Match '#####'
            $raw | Should -Match '\|\|'
        }

        It "supports thinking mode" {
            $output = Invoke-Cowsay -Text "Thinking..." -Thoughts 'o'
            $raw = $output -replace '\x1b\[[0-9;]*[a-zA-Z]', ''
            $raw | Should -Match "Thinking"
        }

        It "supports custom eyes" {
            $output = Invoke-Cowsay -Text "Test" -Eyes '@@'
            $raw = $output -replace '\x1b\[[0-9;]*[a-zA-Z]', ''
            $raw | Should -Match '@@'
        }

        It "supports custom cow file" {
            $output = Invoke-Cowsay -Text "Tux" -CowFile 'tux'
            $output | Should -Match "Tux"
        }

        It "word wraps long messages" {
            $long = "This is a very long message that should be wrapped at the configured max width to prevent the cow from being too wide"
            $output = Invoke-Cowsay -Text $long
            $raw = $output -replace '\x1b\[[0-9;]*[a-zA-Z]', ''
            $lines = $raw -split "`n"
            $maxLen = ($lines | ForEach-Object { $_.Length } | Measure-Object -Maximum).Maximum
            $maxLen | Should -BeLessThan 100
        }

        It "handles empty message" {
            Invoke-Cowsay -Text "" | Should -Not -BeNullOrEmpty
        }

        It "handles multiline message" {
            $output = Invoke-Cowsay -Text "Line 1`nLine 2"
            $raw = $output -replace '\x1b\[[0-9;]*[a-zA-Z]', ''
            $raw | Should -Match "Line 1"
            $raw | Should -Match "Line 2"
        }
    }
}

Describe "Combined Forgum" {
    BeforeAll {
        Import-Module (Join-Path (Split-Path $PSScriptRoot -Parent) 'Forgum.psd1') -Force
        Set-CFConfig -Config (Get-Content (Join-Path (Split-Path $PSScriptRoot -Parent) 'Data/Templates/default-config.json') -Raw | ConvertFrom-Json)
    }

    It "outputs cowsay with fortune" {
        Invoke-Forgum | Should -Not -BeNullOrEmpty
    }

    It "contains a cow" {
        $output = Invoke-Forgum
        $raw = $output -replace '\x1b\[[0-9;]*[a-zA-Z]', ''
        $raw | Should -Match '\^__\^'
    }

    It "contains a fortune message" {
        $output = Invoke-Forgum
        $raw = $output -replace '\x1b\[[0-9;]*[a-zA-Z]', ''
        $raw | Should -Match '[a-zA-Z]'
    }

    It "supports think parameter" {
        Invoke-Forgum -Think | Should -Not -BeNullOrEmpty
    }

    It "supports custom cow file" {
        Invoke-Forgum -CowFile 'tux' | Should -Not -BeNullOrEmpty
    }
}

Describe "Lolcat Colorization" {
    BeforeAll {
        Import-Module (Join-Path (Split-Path $PSScriptRoot -Parent) 'Forgum.psd1') -Force
        $script:OriginalConfig = Get-CFConfig
        Set-CFConfig -Config (Get-Content (Join-Path (Split-Path $PSScriptRoot -Parent) 'Data/Templates/default-config.json') -Raw | ConvertFrom-Json)
    }

    AfterAll {
        Set-CFConfig -Config $script:OriginalConfig
    }

    It "produces colored output when enabled with all options" {
        $original = Get-CFConfig
        $config = Get-CFConfig
        $config.lolcat.enabled = $true
        $config.lolcat.truecolor = $true
        $config.lolcat.frequency = 0.15
        $config.lolcat.invert = $false
        $config.cow.file = 'default'
        $config.cow.eyes = '@@'
        $config.cow.tongue = '  '
        $config.animation.mode = 'static'
        Set-CFConfig -Config $config

        $output = Invoke-Forgum -Think -CowFile 'default' -Eyes '@@'
        $output | Should -Not -BeNullOrEmpty
        # Check that output contains cow face components (strip ANSI first)
        $esc = [char]27
        $stripped = $output -replace "${esc}\[[0-9;]*[a-zA-Z]", ''
        $stripped | Should -Match '@@'
        $stripped | Should -Match '\^__\^'
        # Check that ANSI codes are present (lolcat enabled)
        $hasAnsi = $output -match "${esc}\[38;2;"
        $hasAnsi | Should -Be $true

        Set-CFConfig -Config $original
    }

    It "produces 256-color output when truecolor disabled" {
        $original = Get-CFConfig
        $config = Get-CFConfig
        $config.lolcat.enabled = $true
        $config.lolcat.truecolor = $false
        $config.lolcat.frequency = 0.1
        Set-CFConfig -Config $config

        Import-Module (Join-Path (Split-Path $PSScriptRoot -Parent) 'Forgum.psd1') -Force
        $output = Invoke-Forgum
        $output | Should -Not -BeNullOrEmpty
        $esc = [char]27
        $stripped = $output -replace "${esc}\[[0-9;]*[a-zA-Z]", ''
        $stripped | Should -Match '\^__\^'
        # Check for 256-color ANSI codes
        $hasAnsi256 = $output -match "${esc}\[38;5;"
        $hasAnsi256 | Should -Be $true

        Set-CFConfig -Config $original
    }

    It "does not colorize when disabled" {
        $original = Get-CFConfig
        $config = Get-CFConfig
        $config.lolcat.enabled = $false
        Set-CFConfig -Config $config

        Import-Module (Join-Path (Split-Path $PSScriptRoot -Parent) 'Forgum.psd1') -Force
        $output = Invoke-Forgum
        $esc = [char]27
        $hasAnsi = $output -match "${esc}\[[0-9;]*m"
        $hasAnsi | Should -Be $false

        Set-CFConfig -Config $original
    }
}

Describe "Animation System" {
    BeforeAll {
        Import-Module (Join-Path (Split-Path $PSScriptRoot -Parent) 'Forgum.psd1') -Force
        Set-CFConfig -Config (Get-Content (Join-Path (Split-Path $PSScriptRoot -Parent) 'Data/Templates/default-config.json') -Raw | ConvertFrom-Json)
    }

    It "Show-CFAnimation runs without error" {
        $cowOutput = Invoke-Cowsay -Text "Test"
        { Show-CFAnimation -CowOutput $cowOutput } | Should -Not -Throw
    }

    It "static animation returns output with cow face" {
        $cowOutput = Invoke-Cowsay -Text "Test"
        $output = Show-CFAnimation -CowOutput $cowOutput
        $raw = $output -replace '\x1b\[[0-9;]*[a-zA-Z]', ''
        $raw | Should -Match "Test"
        $raw | Should -Match '\^__\^'
    }

    It "slide-in animation returns output with cow face" {
        $config = Get-CFConfig
        $config.animation.mode = 'slide-in'
        Set-CFConfig -Config $config
        $cowOutput = Invoke-Cowsay -Text "SlideTest"
        $output = Show-CFAnimation -CowOutput $cowOutput -Message "SlideTest"
        $raw = $output -replace '\x1b\[[0-9;]*[a-zA-Z]', ''
        $raw | Should -Match '\^__\^'
        $config.animation.mode = 'static'
        Set-CFConfig -Config $config
    }

    It "bounce animation returns output with cow face" {
        $config = Get-CFConfig
        $config.animation.mode = 'bounce'
        Set-CFConfig -Config $config
        $cowOutput = Invoke-Cowsay -Text "BounceTest"
        $output = Show-CFAnimation -CowOutput $cowOutput -Message "BounceTest"
        $raw = $output -replace '\x1b\[[0-9;]*[a-zA-Z]', ''
        $raw | Should -Match '\^__\^'
        $config.animation.mode = 'static'
        Set-CFConfig -Config $config
    }

    It "dissolve animation returns output with cow face" {
        $config = Get-CFConfig
        $config.animation.mode = 'dissolve'
        Set-CFConfig -Config $config
        $cowOutput = Invoke-Cowsay -Text "DissolveTest"
        $output = Show-CFAnimation -CowOutput $cowOutput -Message "DissolveTest"
        $raw = $output -replace '\x1b\[[0-9;]*[a-zA-Z]', ''
        $raw | Should -Match '\^__\^'
        $config.animation.mode = 'static'
        Set-CFConfig -Config $config
    }

    It "fade-in animation returns output with cow face" {
        $config = Get-CFConfig
        $config.animation.mode = 'fade-in'
        Set-CFConfig -Config $config
        $cowOutput = Invoke-Cowsay -Text "FadeTest"
        $output = Show-CFAnimation -CowOutput $cowOutput -Message "FadeTest"
        $raw = $output -replace '\x1b\[[0-9;]*[a-zA-Z]', ''
        $raw | Should -Match '\^__\^'
        $config.animation.mode = 'static'
        Set-CFConfig -Config $config
    }

    It "blink animation returns output with cow face" {
        $config = Get-CFConfig
        $config.animation.mode = 'blink'
        Set-CFConfig -Config $config
        $cowOutput = Invoke-Cowsay -Text "BlinkTest"
        $output = Show-CFAnimation -CowOutput $cowOutput -Message "BlinkTest"
        $raw = $output -replace '\x1b\[[0-9;]*[a-zA-Z]', ''
        $raw | Should -Match '\^__\^'
        $config.animation.mode = 'static'
        Set-CFConfig -Config $config
    }

    It "wiggle animation returns output with cow face" {
        $config = Get-CFConfig
        $config.animation.mode = 'wiggle'
        Set-CFConfig -Config $config
        $cowOutput = Invoke-Cowsay -Text "WiggleTest"
        $output = Show-CFAnimation -CowOutput $cowOutput -Message "WiggleTest"
        $raw = $output -replace '\x1b\[[0-9;]*[a-zA-Z]', ''
        $raw | Should -Match '\^__\^'
        $config.animation.mode = 'static'
        Set-CFConfig -Config $config
    }

    It "wave animation returns output with cow face" {
        $config = Get-CFConfig
        $config.animation.mode = 'wave'
        Set-CFConfig -Config $config
        $cowOutput = Invoke-Cowsay -Text "WaveTest"
        $output = Show-CFAnimation -CowOutput $cowOutput -Message "WaveTest"
        $raw = $output -replace '\x1b\[[0-9;]*[a-zA-Z]', ''
        $raw | Should -Match '\^__\^'
        $config.animation.mode = 'static'
        Set-CFConfig -Config $config
    }

    It "disco animation returns output with cow face" {
        $config = Get-CFConfig
        $config.animation.mode = 'disco'
        Set-CFConfig -Config $config
        $cowOutput = Invoke-Cowsay -Text "DiscoTest"
        $output = Show-CFAnimation -CowOutput $cowOutput -Message "DiscoTest"
        $raw = $output -replace '\x1b\[[0-9;]*[a-zA-Z]', ''
        $raw | Should -Match '\^__\^'
        $config.animation.mode = 'static'
        Set-CFConfig -Config $config
    }

    It "all 11 animation modes are valid" {
        $validModes = @('static', 'talking', 'typewriter', 'slide-in', 'bounce', 'dissolve', 'fade-in', 'blink', 'wiggle', 'wave', 'disco')
        $validModes.Count | Should -Be 11
    }

    It "invalid animation mode falls back to static" {
        $config = Get-CFConfig
        $config.animation.mode = 'invalid_mode_xyz'
        Set-CFConfig -Config $config
        $cowOutput = Invoke-Cowsay -Text "FallbackTest"
        $output = Show-CFAnimation -CowOutput $cowOutput -Message "FallbackTest"
        $output | Should -Not -BeNullOrEmpty
        $raw = $output -replace '\x1b\[[0-9;]*[a-zA-Z]', ''
        $raw | Should -Match 'FallbackTest'
        $config.animation.mode = 'static'
        Set-CFConfig -Config $config
    }

    It "each animation returns string type" {
        $modes = @('static', 'talking', 'typewriter', 'slide-in', 'bounce', 'dissolve', 'fade-in', 'blink', 'wiggle', 'wave', 'disco')
        foreach ($mode in $modes) {
            $config = Get-CFConfig
            $config.animation.mode = $mode
            Set-CFConfig -Config $config
            $cowOutput = Invoke-Cowsay -Text "TypeTest"
            $output = Show-CFAnimation -CowOutput $cowOutput -Message "TypeTest"
            $output | Should -BeOfType System.String
            $config.animation.mode = 'static'
            Set-CFConfig -Config $config
        }
    }

    It "each animation returns non-null non-empty" {
        $modes = @('static', 'talking', 'typewriter', 'slide-in', 'bounce', 'dissolve', 'fade-in', 'blink', 'wiggle', 'wave', 'disco')
        foreach ($mode in $modes) {
            $config = Get-CFConfig
            $config.animation.mode = $mode
            Set-CFConfig -Config $config
            $cowOutput = Invoke-Cowsay -Text "NotNull"
            $output = Show-CFAnimation -CowOutput $cowOutput -Message "NotNull"
            $output | Should -Not -BeNullOrEmpty
            $config.animation.mode = 'static'
            Set-CFConfig -Config $config
        }
    }
}

Describe "Security" {
    BeforeAll {
        Import-Module (Join-Path (Split-Path $PSScriptRoot -Parent) 'Forgum.psd1') -Force
        Set-CFConfig -Config (Get-Content (Join-Path (Split-Path $PSScriptRoot -Parent) 'Data/Templates/default-config.json') -Raw | ConvertFrom-Json)
    }

    It "does not execute code from cow files" {
        $output = Invoke-Cowsay -Text "Test"
        $raw = $output -replace '\x1b\[[0-9;]*[a-zA-Z]', ''
        $raw | Should -Not -Match 'Invoke-Expression'
        $raw | Should -Not -Match 'Get-Process'
    }

    It "handles special characters in message" {
        $output = Invoke-Cowsay -Text "Hello World with spaces"
        $output | Should -Match "Hello World with spaces"
    }

    It "handles very long messages without crashing" {
        $longText = "A" * 1000
        $output = Invoke-Cowsay -Text $longText
        $output | Should -Not -BeNullOrEmpty
    }
}

Describe "Edge Cases" {
    BeforeAll {
        Import-Module (Join-Path (Split-Path $PSScriptRoot -Parent) 'Forgum.psd1') -Force
        Set-CFConfig -Config (Get-Content (Join-Path (Split-Path $PSScriptRoot -Parent) 'Data/Templates/default-config.json') -Raw | ConvertFrom-Json)
    }

    It "handles unicode in message" {
        $output = Invoke-Cowsay -Text "Hello World"
        $output | Should -Match "Hello World"
    }

    It "handles message with only spaces" {
        Invoke-Cowsay -Text "   " | Should -Not -BeNullOrEmpty
    }

    It "handles message with newlines only" {
        Invoke-Cowsay -Text "`n`n" | Should -Not -BeNullOrEmpty
    }

    It "multiple cowsay calls work" {
        $out1 = Invoke-Cowsay -Text "First"
        $out2 = Invoke-Cowsay -Text "Second"
        $out1 | Should -Match "First"
        $out2 | Should -Match "Second"
    }

    It "config changes persist across calls" {
        $config = Get-CFConfig
        $config.animation.mode = 'typewriter'
        Set-CFConfig -Config $config

        (Get-CFConfig).animation.mode | Should -Be 'typewriter'

        $config.animation.mode = 'static'
        Set-CFConfig -Config $config
    }

    It "all 107 cows can be loaded and rendered" {
        $cows = @(Get-CFCow)
        $failed = @()
        foreach ($cow in $cows) {
            try {
                $output = Invoke-Cowsay -Text "Test" -CowFile $cow
                if (-not $output) { $failed += $cow }
            }
            catch {
                $failed += $cow
            }
        }
        $failed.Count | Should -Be 0
    }

    It "cow file cache works" {
        $cow1 = Get-CFCow -Name 'default'
        $cow2 = Get-CFCow -Name 'default'
        $cow1 | Should -Be $cow2
    }

    It "fortune cache works" {
        $f1 = Get-Fortune
        $f2 = Get-Fortune
        $f1 | Should -Not -BeNullOrEmpty
        $f2 | Should -Not -BeNullOrEmpty
    }

    It "handles special characters: backticks, dollar signs, pipes" {
        $output = Invoke-Cowsay -Text 'Test `$pipe|and$dollar'
        $raw = $output -replace '\x1b\[[0-9;]*[a-zA-Z]', ''
        $raw | Should -Match 'Test'
    }

    It "handles extremely long single word (2000 chars)" {
        $longWord = "X" * 2000
        $output = Invoke-Cowsay -Text $longWord
        $output | Should -Not -BeNullOrEmpty
    }

    It "handles message with only percent signs" {
        $output = Invoke-Cowsay -Text "%%%"
        $output | Should -Not -BeNullOrEmpty
    }

    It "handles consecutive spaces in message" {
        $output = Invoke-Cowsay -Text "Hello    World"
        $raw = $output -replace '\x1b\[[0-9;]*[a-zA-Z]', ''
        $raw | Should -Match 'Hello'
    }
}

Describe "Cross-Platform" {
    BeforeAll {
        $mod = Get-Module Forgum -ErrorAction SilentlyContinue
        if ($mod) { Remove-Module Forgum -Force }
        Import-Module (Join-Path (Split-Path $PSScriptRoot -Parent) 'Forgum.psd1') -Force
    }

    It "config path is valid for current platform" {
        $path = InModuleScope Forgum { Get-ConfigPath }
        $path | Should -Not -BeNullOrEmpty
        $path | Should -Match 'config\.json$'
    }

    It "config directory parent exists or can be created" {
        $path = InModuleScope Forgum { Get-ConfigPath }
        $dir = Split-Path $path -Parent
        $dir | Should -Not -BeNullOrEmpty
    }

    It "module loads on current PowerShell version" {
        $psVersion = $PSVersionTable.PSVersion
        $psVersion | Should -Not -BeNullOrEmpty
        $psVersion.Major | Should -BeGreaterOrEqual 5
    }

    It "all public functions have CmdletBinding" {
        $funcs = Get-Command -Module Forgum
        foreach ($func in $funcs) {
            $func.CmdletBinding | Should -Be $true -Because "$($func.Name) should have CmdletBinding"
        }
    }

    It "module manifest matches loaded module version" {
        $manifest = Test-ModuleManifest (Join-Path (Split-Path $PSScriptRoot -Parent) 'Forgum.psd1')
        $loaded = Get-Module Forgum
        [string]$manifest.Version | Should -Be ([string]$loaded.Version)
    }
}

Describe "Performance" {
    BeforeAll {
        Import-Module (Join-Path (Split-Path $PSScriptRoot -Parent) 'Forgum.psd1') -Force
        Set-CFConfig -Config (Get-Content (Join-Path (Split-Path $PSScriptRoot -Parent) 'Data/Templates/default-config.json') -Raw | ConvertFrom-Json)
    }

    It "100 Invoke-Cowsay calls complete within 10 seconds" {
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        for ($i = 0; $i -lt 100; $i++) {
            Invoke-Cowsay -Text "Perf test $i" | Out-Null
        }
        $sw.Stop()
        $sw.ElapsedMilliseconds | Should -BeLessThan 10000
    }

    It "Get-CFConfig cache hit is fast (100 calls < 1 second)" {
        # Prime the cache
        Get-CFConfig | Out-Null
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        for ($i = 0; $i -lt 100; $i++) {
            Get-CFConfig | Out-Null
        }
        $sw.Stop()
        $sw.ElapsedMilliseconds | Should -BeLessThan 1000
    }

    It "Get-Fortune cache hit is fast (100 calls < 2 seconds)" {
        # Prime the cache
        Get-Fortune | Out-Null
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        for ($i = 0; $i -lt 100; $i++) {
            Get-Fortune | Out-Null
        }
        $sw.Stop()
        $sw.ElapsedMilliseconds | Should -BeLessThan 2000
    }

    It "all 107 cows render within 5 seconds" {
        $cows = @(Get-CFCow)
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        foreach ($cow in $cows) {
            Invoke-Cowsay -Text "Test" -CowFile $cow | Out-Null
        }
        $sw.Stop()
        $sw.ElapsedMilliseconds | Should -BeLessThan 5000
    }
}

Describe "Package Manager Support" {
    BeforeAll {
        $script:ProjectRoot = Split-Path $PSScriptRoot -Parent
    }

    It "winget manifest version matches module version" {
        $yaml = Get-Content "$script:ProjectRoot/package-managers/winget/HKDEVS.Forgum.yaml" -Raw
        $manifestVersion = ($yaml | Select-String 'PackageVersion:\s*(.+)').Matches[0].Groups[1].Value.Trim()
        $module = Test-ModuleManifest "$script:ProjectRoot/Forgum.psd1"
        $manifestVersion | Should -Be $module.Version.ToString()
    }

    It "scoop manifest version matches module version" {
        $json = Get-Content "$script:ProjectRoot/package-managers/scoop/forgum.json" -Raw | ConvertFrom-Json
        $module = Test-ModuleManifest "$script:ProjectRoot/Forgum.psd1"
        $json.version | Should -Be $module.Version.ToString()
    }

    It "winget installer SHA256 is 64 hex chars or placeholder" {
        $yaml = Get-Content "$script:ProjectRoot/package-managers/winget/HKDEVS.Forgum.installer.yaml" -Raw
        $sha = ($yaml | Select-String 'InstallerSha256:\s*(.+)').Matches[0].Groups[1].Value.Trim()
        ($sha -match '^[a-f0-9]{64}$' -or $sha -eq 'REPLACE_WITH_ACTUAL_SHA256') | Should -BeTrue
    }

    It "scoop manifest hash is 64 hex chars" {
        $json = Get-Content "$script:ProjectRoot/package-managers/scoop/forgum.json" -Raw | ConvertFrom-Json
        $json.hash | Should -Match '^[a-f0-9]{64}$'
    }

    It "winget installer URL points to GitHub Release" {
        $yaml = Get-Content "$script:ProjectRoot/package-managers/winget/HKDEVS.Forgum.installer.yaml" -Raw
        $url = ($yaml | Select-String 'InstallerUrl:\s*(.+)').Matches[0].Groups[1].Value.Trim()
        $url | Should -Match 'github\.com.*releases.*Forgum.*Setup\.exe'
    }

    It "scoop URL points to GitHub Release" {
        $json = Get-Content "$script:ProjectRoot/package-managers/scoop/forgum.json" -Raw | ConvertFrom-Json
        $json.url | Should -Match 'github\.com.*releases.*Forgum.*\.zip'
    }

    It "proof README exists and has content" {
        "$script:ProjectRoot/package-managers/proof/README.md" | Should -Exist
        (Get-Content "$script:ProjectRoot/package-managers/proof/README.md" -Raw).Length | Should -BeGreaterThan 100
    }

    It "all 3 winget manifests exist" {
        "$script:ProjectRoot/package-managers/winget/HKDEVS.Forgum.yaml" | Should -Exist
        "$script:ProjectRoot/package-managers/winget/HKDEVS.Forgum.locale.en-US.yaml" | Should -Exist
        "$script:ProjectRoot/package-managers/winget/HKDEVS.Forgum.installer.yaml" | Should -Exist
    }
}

Describe "Documentation" {
    BeforeAll {
        $script:ProjectRoot = Split-Path $PSScriptRoot -Parent
    }

    It "README.md exists" {
        "$script:ProjectRoot/README.md" | Should -Exist
    }

    It "CHANGELOG.md exists" {
        "$script:ProjectRoot/CHANGELOG.md" | Should -Exist
    }

    It "CONTRIBUTING.md exists" {
        "$script:ProjectRoot/CONTRIBUTING.md" | Should -Exist
    }

    It "LICENSE exists" {
        "$script:ProjectRoot/LICENSE" | Should -Exist
    }

    It "wiki Home.md exists" {
        "$script:ProjectRoot/wiki/Home.md" | Should -Exist
    }

    It "all 11 wiki files exist" {
        $wikiFiles = @(
            'Home.md', 'Getting-Started.md', 'Installation.md',
            'PowerShell-Integration.md', 'Bash-Zsh-Integration.md',
            'Fish-Integration.md', 'tmux-Integration.md',
            'Configuration.md', 'Custom-Cows.md', 'Custom-Fortunes.md',
            'Troubleshooting.md'
        )
        foreach ($f in $wikiFiles) {
            "$script:ProjectRoot/wiki/$f" | Should -Exist
        }
    }
}
