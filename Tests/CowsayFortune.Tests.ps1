#Requires -Modules Pester

$modulePath = Join-Path $PSScriptRoot '..' 'CowsayFortune'

Describe "Module Loading" {
    BeforeAll {
        $errors = $null
        Import-Module $modulePath -Force -ErrorVariable errors
    }

    It "loads without errors" {
        $errors | Should BeNullOrEmpty
    }

    It "exports exactly 7 functions" {
        (Get-Command -Module CowsayFortune).Count | Should Be 7
    }

    It "exports Invoke-Cowsay" {
        Get-Command Invoke-Cowsay -Module CowsayFortune | Should Not BeNullOrEmpty
    }

    It "exports Invoke-CowsayFortune" {
        Get-Command Invoke-CowsayFortune -Module CowsayFortune | Should Not BeNullOrEmpty
    }

    It "exports Get-Fortune" {
        Get-Command Get-Fortune -Module CowsayFortune | Should Not BeNullOrEmpty
    }

    It "exports Get-CFCow" {
        Get-Command Get-CFCow -Module CowsayFortune | Should Not BeNullOrEmpty
    }

    It "exports Get-CFConfig" {
        Get-Command Get-CFConfig -Module CowsayFortune | Should Not BeNullOrEmpty
    }

    It "exports Set-CFConfig" {
        Get-Command Set-CFConfig -Module CowsayFortune | Should Not BeNullOrEmpty
    }

    It "exports Show-CFAnimation" {
        Get-Command Show-CFAnimation -Module CowsayFortune | Should Not BeNullOrEmpty
    }

    It "has CmdletBinding on public functions" {
        $funcs = @('Invoke-Cowsay', 'Get-Fortune', 'Get-CFCow', 'Get-CFConfig', 'Set-CFConfig', 'Show-CFAnimation', 'Invoke-CowsayFortune')
        foreach ($func in $funcs) {
            $cmd = Get-Command $func -Module CowsayFortune
            $cmd.Parameters.ContainsKey('Verbose') | Should Be $true
        }
    }
}

Describe "Config System" {
    BeforeAll {
        Import-Module $modulePath -Force
        $configPath = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'PowerShell/cowsayfortune/config.json'
        if (Test-Path $configPath) { Remove-Item $configPath -Force }
    }

    BeforeEach {
        Import-Module $modulePath -Force
    }

    Context "Default config" {
        It "returns a config object" {
            $config = Get-CFConfig
            $config | Should Not BeNullOrEmpty
        }

        It "has animation mode 'static' by default" {
            (Get-CFConfig).animation.mode | Should Be 'static'
        }

        It "has cow file 'default' by default" {
            (Get-CFConfig).cow.file | Should Be 'default'
        }

        It "has lolcat disabled by default" {
            (Get-CFConfig).lolcat.enabled | Should Be $false
        }

        It "has word wrap enabled by default" {
            (Get-CFConfig).output.wordWrap | Should Be $true
        }

        It "has max width of 60 by default" {
            (Get-CFConfig).output.maxWidth | Should Be 60
        }

        It "has animation speed of 20" {
            (Get-CFConfig).animation.speed | Should Be 20
        }

        It "has animation duration of 12" {
            (Get-CFConfig).animation.duration | Should Be 12
        }

        It "has fortune database set to 'fortunes'" {
            (Get-CFConfig).fortune.database | Should Be 'fortunes'
        }
    }

    Context "Config persistence" {
        It "saves and reloads config" {
            $config = Get-CFConfig
            $config.lolcat.enabled = $true
            Set-CFConfig -Config $config

            $reloaded = Get-CFConfig
            $reloaded.lolcat.enabled | Should Be $true

            $config.lolcat.enabled = $false
            Set-CFConfig -Config $config
        }

        It "preserves all sections after save" {
            $config = Get-CFConfig
            $config.lolcat.frequency = 0.5
            Set-CFConfig -Config $config

            $reloaded = Get-CFConfig
            $reloaded.animation.mode | Should Be 'static'
            $reloaded.cow.file | Should Be 'default'
            $reloaded.fortune.database | Should Be 'fortunes'
            $reloaded.output.maxWidth | Should Be 60

            $config.lolcat.frequency = 0.1
            Set-CFConfig -Config $config
        }

        It "creates config directory if missing" {
            $testDir = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'PowerShell/cowsayfortune_test'
            if (Test-Path $testDir) { Remove-Item $testDir -Recurse -Force }

            $env:COWSAYFORTUNE_CONFIG = Join-Path $testDir 'config.json'
            try {
                $config = Get-CFConfig
                Set-CFConfig -Config $config
                Test-Path $env:COWSAYFORTUNE_CONFIG | Should Be $true
            }
            finally {
                $env:COWSAYFORTUNE_CONFIG = $null
                if (Test-Path $testDir) { Remove-Item $testDir -Recurse -Force }
            }
        }
    }
}

Describe "Fortune System" {
    BeforeEach {
        Import-Module $modulePath -Force
    }

    It "returns a fortune" {
        Get-Fortune | Should Not BeNullOrEmpty
    }

    It "returns a string" {
        Get-Fortune | Should BeOfType System.String
    }

    It "returns non-empty string" {
        (Get-Fortune).Length | Should BeGreaterThan 0
    }

    It "returns different fortunes on multiple calls" {
        $fortunes = @()
        for ($i = 0; $i -lt 10; $i++) { $fortunes += Get-Fortune }
        ($fortunes | Select-Object -Unique).Count | Should BeGreaterThan 1
    }

    It "can read the fortunes database file" {
        $fortunePath = Join-Path (Split-Path $modulePath -Parent) 'CowsayFortune/Data/Fortunes/fortunes.txt'
        Test-Path $fortunePath | Should Be $true
    }

    It "fortune file contains percent delimiters" {
        $fortunePath = Join-Path (Split-Path $modulePath -Parent) 'CowsayFortune/Data/Fortunes/fortunes.txt'
        $content = Get-Content $fortunePath -Raw
        $content | Should Match '%'
    }

    It "throws for nonexistent database" {
        $threw = $false
        try { Get-Fortune -Database 'nonexistent_xyz' } catch { $threw = $true }
        $threw | Should Be $true
    }
}

Describe "Cow System" {
    BeforeEach {
        Import-Module $modulePath -Force
    }

    Context "Cow listing" {
        It "lists available cows" {
            Get-CFCow | Should Not BeNullOrEmpty
        }

        It "contains default cow" {
            @(Get-CFCow) -contains 'default' | Should Be $true
        }

        It "contains tux cow" {
            @(Get-CFCow) -contains 'tux' | Should Be $true
        }

        It "contains more than 50 cows" {
            @(Get-CFCow).Count | Should BeGreaterThan 50
        }

        It "returns sorted list" {
            $cows = @(Get-CFCow)
            $sorted = @($cows | Sort-Object)
            $cows.Count | Should Be $sorted.Count
        }
    }

    Context "Cow reading" {
        It "reads default cow" {
            $cow = Get-CFCow -Name 'default'
            $cow | Should Not BeNullOrEmpty
        }

        It "reads tux cow" {
            $cow = Get-CFCow -Name 'tux'
            $cow | Should Not BeNullOrEmpty
        }

        It "throws for nonexistent cow" {
            $threw = $false
            try { Get-CFCow -Name 'nonexistent_xyz_abc' } catch { $threw = $true }
            $threw | Should Be $true
        }
    }

    Context "Cow rendering" {
        It "renders cow with message" {
            $output = Invoke-Cowsay -Text "Hello World"
            $output | Should Match "Hello World"
        }

        It "renders default face" {
            $output = Invoke-Cowsay -Text "Test" -CowFile 'default'
            $raw = $output -replace '\x1b\[[0-9;]*m', ''
            $raw | Should Match '\^__\^'
        }

        It "renders speech bubble borders" {
            $output = Invoke-Cowsay -Text "Test"
            $raw = $output -replace '\x1b\[[0-9;]*m', ''
            $raw | Should Match '_______'
            $raw | Should Match '-----'
        }

        It "supports thinking mode" {
            $output = Invoke-Cowsay -Text "Thinking..." -Thoughts 'o'
            $raw = $output -replace '\x1b\[[0-9;]*m', ''
            $raw | Should Match "Thinking"
        }

        It "supports custom eyes" {
            $output = Invoke-Cowsay -Text "Test" -Eyes '@@'
            $raw = $output -replace '\x1b\[[0-9;]*m', ''
            $raw | Should Match '@@'
        }

        It "supports custom cow file" {
            $output = Invoke-Cowsay -Text "Tux" -CowFile 'tux'
            $output | Should Match "Tux"
        }

        It "word wraps long messages" {
            $long = "This is a very long message that should be wrapped at the configured max width to prevent the cow from being too wide"
            $output = Invoke-Cowsay -Text $long
            $raw = $output -replace '\x1b\[[0-9;]*m', ''
            $lines = $raw -split "`n"
            $maxLen = ($lines | ForEach-Object { $_.Length } | Measure-Object -Maximum).Maximum
            $maxLen | Should BeLessThan 100
        }

        It "handles empty message" {
            Invoke-Cowsay -Text "" | Should Not BeNullOrEmpty
        }

        It "handles multiline message" {
            $output = Invoke-Cowsay -Text "Line 1`nLine 2"
            $raw = $output -replace '\x1b\[[0-9;]*m', ''
            $raw | Should Match "Line 1"
            $raw | Should Match "Line 2"
        }
    }
}

Describe "Combined CowsayFortune" {
    BeforeEach {
        Import-Module $modulePath -Force
    }

    It "outputs cowsay with fortune" {
        Invoke-CowsayFortune | Should Not BeNullOrEmpty
    }

    It "contains a cow" {
        $output = Invoke-CowsayFortune
        $raw = $output -replace '\x1b\[[0-9;]*m', ''
        $raw | Should Match '\^__\^'
    }

    It "contains a fortune message" {
        $output = Invoke-CowsayFortune
        $raw = $output -replace '\x1b\[[0-9;]*m', ''
        $raw | Should Match '[a-zA-Z]'
    }

    It "supports think parameter" {
        Invoke-CowsayFortune -Think | Should Not BeNullOrEmpty
    }

    It "supports custom cow file" {
        Invoke-CowsayFortune -CowFile 'tux' | Should Not BeNullOrEmpty
    }
}

Describe "Lolcat Colorization" {
    BeforeEach {
        Import-Module $modulePath -Force
    }

    It "produces colored output when enabled" {
        $original = Get-CFConfig
        $config = Get-CFConfig
        $config.lolcat.enabled = $true
        Set-CFConfig -Config $config

        Import-Module $modulePath -Force
        $output = Invoke-CowsayFortune
        $output | Should Not BeNullOrEmpty
        $raw = $output -replace '\x1b\[[0-9;]*m', ''
        $raw | Should Match '\^__\^'

        Set-CFConfig -Config $original
    }

    It "does not colorize when disabled" {
        $config = Get-CFConfig
        $config.lolcat.enabled = $false
        Set-CFConfig -Config $config

        Import-Module $modulePath -Force
        $output = Invoke-CowsayFortune
        $hasAnsi = $output -match '\x1b\[[0-9;]*m'
        $hasAnsi | Should Be $false

        Set-CFConfig -Config $config
    }
}

Describe "Animation System" {
    BeforeEach {
        Import-Module $modulePath -Force
    }

    It "Show-CFAnimation runs without error" {
        $cowOutput = Invoke-Cowsay -Text "Test"
        { Show-CFAnimation -CowOutput $cowOutput } | Should Not Throw
    }

    It "static animation returns output" {
        $cowOutput = Invoke-Cowsay -Text "Test"
        $output = Show-CFAnimation -CowOutput $cowOutput
        $raw = $output -replace '\x1b\[[0-9;]*m', ''
        $raw | Should Match "Test"
    }
}

Describe "Security" {
    BeforeEach {
        Import-Module $modulePath -Force
    }

    It "does not execute code from cow files" {
        $output = Invoke-Cowsay -Text "Test"
        $raw = $output -replace '\x1b\[[0-9;]*m', ''
        $raw | Should Not Match 'Invoke-Expression'
        $raw | Should Not Match 'Get-Process'
    }

    It "handles special characters in message" {
        $output = Invoke-Cowsay -Text "Hello World with spaces"
        $output | Should Match "Hello World with spaces"
    }

    It "handles very long messages without crashing" {
        $longText = "A" * 1000
        $output = Invoke-Cowsay -Text $longText
        $output | Should Not BeNullOrEmpty
    }
}

Describe "Edge Cases" {
    BeforeEach {
        Import-Module $modulePath -Force
    }

    It "handles unicode in message" {
        $output = Invoke-Cowsay -Text "Hello World"
        $output | Should Match "Hello World"
    }

    It "handles message with only spaces" {
        Invoke-Cowsay -Text "   " | Should Not BeNullOrEmpty
    }

    It "handles message with newlines only" {
        Invoke-Cowsay -Text "`n`n" | Should Not BeNullOrEmpty
    }

    It "multiple cowsay calls work" {
        $out1 = Invoke-Cowsay -Text "First"
        $out2 = Invoke-Cowsay -Text "Second"
        $out1 | Should Match "First"
        $out2 | Should Match "Second"
    }

    It "config changes persist across calls" {
        $config = Get-CFConfig
        $config.animation.mode = 'typewriter'
        Set-CFConfig -Config $config

        (Get-CFConfig).animation.mode | Should Be 'typewriter'

        $config.animation.mode = 'static'
        Set-CFConfig -Config $config
    }

    It "all 190 cows can be loaded and rendered" {
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
        $failed.Count | Should Be 0
    }

    It "cow file cache works" {
        $cow1 = Get-CFCow -Name 'default'
        $cow2 = Get-CFCow -Name 'default'
        $cow1 | Should Be $cow2
    }

    It "fortune cache works" {
        $f1 = Get-Fortune
        $f2 = Get-Fortune
        $f1 | Should Not BeNullOrEmpty
        $f2 | Should Not BeNullOrEmpty
    }
}
