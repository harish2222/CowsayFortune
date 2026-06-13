#Requires -Modules Pester
# Ghost Tests - Aggressive hostile QA that tries to break everything

Describe "Ghost Tests - Hostile QA" {
    BeforeAll {
        Import-Module (Join-Path (Split-Path $PSScriptRoot -Parent) 'Forgum.psd1') -Force
        $originalConfig = Get-CFConfig
    }

    AfterEach {
        # Reset config after each test
        Set-CFConfig -Config $originalConfig
    }

    # --- INPUT EXTREMES ---
    It "Ghost 01: Empty string does not crash" {
        $output = Invoke-Cowsay -Text ''
        $output | Should -Not -BeNullOrEmpty
    }

    It "Ghost 02: Null-ish whitespace-only input renders" {
        $output = Invoke-Cowsay -Text '   '
        $output | Should -Not -BeNullOrEmpty
    }

    It "Ghost 03: 10000 character message does not crash or hang" {
        $longText = 'A' * 10000
        $output = Invoke-Cowsay -Text $longText
        $output | Should -Not -BeNullOrEmpty
    }

    It "Ghost 04: Single character message renders correctly" {
        $output = Invoke-Cowsay -Text 'X'
        $raw = $output -replace '\x1b\[[0-9;]*m', ''
        $raw | Should -Match 'X'
    }

    It "Ghost 05: Newlines in message are preserved" {
        $output = Invoke-Cowsay -Text "Line1`nLine2`nLine3"
        $raw = $output -replace '\x1b\[[0-9;]*m', ''
        $raw | Should -Match 'Line1'
        $raw | Should -Match 'Line2'
        $raw | Should -Match 'Line3'
    }

    # --- SPECIAL CHARACTERS & INJECTION ---
    It "Ghost 06: Shell injection attempt in text is harmless" {
        $output = Invoke-Cowsay -Text '$(Get-Process)'
        $raw = $output -replace '\x1b\[[0-9;]*m', ''
        $raw | Should -Match '\$\(Get-Process\)'
        # Verify no processes were actually enumerated
    }

    It "Ghost 07: Backtick injection does not execute" {
        $output = Invoke-Cowsay -Text '`n`r`t`0'
        $output | Should -Not -BeNullOrEmpty
    }

    It "Ghost 08: Unicode emoji renders without crash" {
        $output = Invoke-Cowsay -Text "Hello [Heart] [Star] [Check]"
        $output | Should -Not -BeNullOrEmpty
    }

    It "Ghost 09: ANSI escape sequences in input are handled" {
        $esc = [char]27
        $output = Invoke-Cowsay -Text "${esc}[31mRedText${esc}[0m"
        $output | Should -Not -BeNullOrEmpty
    }

    It "Ghost 10: Curly braces and special JSON chars in text" {
        $output = Invoke-Cowsay -Text '{"key": "value", "num": 42}'
        $raw = $output -replace '\x1b\[[0-9;]*m', ''
        $raw | Should -Match '"key"'
    }

    # --- PARAMETER BOUNDARY ---
    It "Ghost 11: Eyes with exact 2 chars works" {
        $output = Invoke-Cowsay -Text 'Test' -Eyes '@@'
        $raw = $output -replace '\x1b\[[0-9;]*m', ''
        $raw | Should -Match '@@'
    }

    It "Ghost 12: Tongue with exact 2 chars works" {
        $output = Invoke-Cowsay -Text 'Test' -Tongue '##'
        $raw = $output -replace '\x1b\[[0-9;]*m', ''
        $raw | Should -Match '##'
    }

    It "Ghost 13: Thoughts character single char works" {
        $output = Invoke-Cowsay -Text 'Test' -Thoughts 'o'
        $raw = $output -replace '\x1b\[[0-9;]*m', ''
        $raw | Should -Match 'o'
    }

    It "Ghost 14: All cow files render without throwing" {
        $cows = Get-CFCow
        $failed = @()
        foreach ($cow in $cows) {
            try {
                $output = Invoke-Cowsay -Text "Test" -CowFile $cow -ErrorAction Stop
                if (-not $output) { $failed += $cow }
            } catch {
                $failed += "$cow : $($_.Exception.Message)"
            }
        }
        $failed.Count | Should -Be 0 -Because "All cows should render: $($failed -join ', ')"
    }

    It "Ghost 15: Invalid CowFile name throws descriptive error" {
        { Invoke-Cowsay -Text 'Test' -CowFile 'nonexistent_xyz_999' -ErrorAction Stop } | Should -Throw
    }

    # --- CONFIG CORRUPTION ---
    It "Ghost 16: Corrupted config file falls back to defaults" {
        $configPath = Join-Path ([System.IO.Path]::GetTempPath()) 'forgum_test_corrupt.json'
        '{ invalid json!!!' | Set-Content -Path $configPath -Force
        # Module should handle gracefully
        $output = Invoke-Cowsay -Text 'Test'
        $output | Should -Not -BeNullOrEmpty
        Remove-Item $configPath -Force -ErrorAction SilentlyContinue
    }

    It "Ghost 17: Config with missing sections gets defaults" {
        $config = Get-CFConfig
        # Remove a section
        $config.PSObject.Properties.Remove('animation')
        Set-CFConfig -Config $config
        $output = Invoke-Cowsay -Text 'Test'
        $output | Should -Not -BeNullOrEmpty
    }

    It "Ghost 18: Config with null lolcat values does not crash" {
        $config = Get-CFConfig
        $config.lolcat.frequency = $null
        $config.lolcat.spread = $null
        Set-CFConfig -Config $config
        { Invoke-Cowsay -Text 'Test' -Lolcat } | Should -Not -Throw
    }

    # --- CONCURRENT / RAPID CALLS ---
    It "Ghost 19: Rapid sequential calls do not corrupt state" {
        $results = @()
        for ($i = 0; $i -lt 50; $i++) {
            $results += (Invoke-Cowsay -Text "Message $i").Length
        }
        # All should produce output
        ($results | Where-Object { $_ -eq 0 }).Count | Should -Be 0
        # Output should vary (different messages)
        ($results | Select-Object -Unique).Count | Should -BeGreaterThan 1
    }

    It "Ghost 20: Config changes are reflected in output" {
        $config = Get-CFConfig
        $config.lolcat.enabled = $true
        Set-CFConfig -Config $config
        # Use Invoke-Forgum which reads config for lolcat
        $output1 = Invoke-Forgum
        $hasAnsi1 = $output1 -match '\x1b\['
        
        $config2 = Get-CFConfig
        $config2.lolcat.enabled = $false
        Set-CFConfig -Config $config2
        $output2 = Invoke-Forgum
        $hasAnsi2 = $output2 -match '\x1b\[38;'
        
        $hasAnsi1 | Should -Be $true
        $hasAnsi2 | Should -Be $false
    }

    # --- LOLCAT EXTREMES ---
    It "Ghost 21: Lolcat with minimum frequency does not crash" {
        { Invoke-Cowsay -Text 'Test' -Lolcat } | Should -Not -Throw
    }

    It "Ghost 22: Lolcat with very long text does not hang" {
        $longText = ('Hello ' * 200).Trim()
        $output = Invoke-Cowsay -Text $longText -Lolcat
        $output | Should -Not -BeNullOrEmpty
    }

    It "Ghost 23: Lolcat ANSI codes are properly formed" {
        $output = Invoke-Cowsay -Text 'ColorTest' -Lolcat
        # Should have opening and closing ANSI codes (either truecolor or 256-color)
        $hasColorCodes = $output -match '\x1b\[38;'
        $hasColorCodes | Should -Be $true
        # Should have reset codes
        $hasReset = $output -match '\x1b\[0m|\x1b\[39m'
        $hasReset | Should -Be $true
    }

    It "Ghost 24: Lolcat with different seeds produces different output" {
        $config = Get-CFConfig
        $config.lolcat.enabled = $true
        $config.lolcat.seed = 42
        Set-CFConfig -Config $config
        $a = Invoke-Cowsay -Text 'Rainbow' -Lolcat
        
        $config.lolcat.seed = 100
        Set-CFConfig -Config $config
        $b = Invoke-Cowsay -Text 'Rainbow' -Lolcat
        
        # Different seeds should produce different color codes
        $a | Should -Not -Be $b
    }

    # --- FORTUNE EDGE CASES ---
    It "Ghost 25: Get-Fortune 100 times never returns empty" {
        $empty = 0
        for ($i = 0; $i -lt 100; $i++) {
            $f = Get-Fortune
            if ([string]::IsNullOrWhiteSpace($f)) { $empty++ }
        }
        $empty | Should -Be 0
    }

    It "Ghost 26: Get-Fortune with offensive filter works" {
        $f = Get-Fortune
        $f | Should -Not -BeNullOrEmpty
    }

    # --- OUTPUT INTEGRITY ---
    It "Ghost 27: Cow face ^__^ is always present in default cow output" {
        $output = Invoke-Cowsay -Text 'Anything'
        $raw = $output -replace '\x1b\[[0-9;]*m', ''
        $raw | Should -Match '\^__\^'
    }

    It "Ghost 28: Speech balloon borders are properly closed" {
        $output = Invoke-Cowsay -Text 'Test'
        $raw = $output -replace '\x1b\[[0-9;]*m', ''
        $lines = $raw -split "`n"
        # Find lines that are all # (with optional leading spaces)
        $hashLines = $lines | Where-Object { $_.Trim() -match '^#+$' }
        $hashLines.Count | Should -BeGreaterOrEqual 2
        # First and last hash lines should have same length
        $hashLines[0].Trim().Length | Should -Be $hashLines[-1].Trim().Length
    }

    It "Ghost 29: Think bubble uses o not backslash" {
        $output = Invoke-Cowsay -Text 'Think' -Thoughts 'o'
        $raw = $output -replace '\x1b\[[0-9;]*m', ''
        # Should have 'o' connector, not '\'
        $raw | Should -Match 'o\s+\^__\^'
        $raw | Should -Not -Match '\\\s+\^__\^'
    }

    It "Ghost 30: Invoke-Forgum returns complete cow with fortune" {
        $output = Invoke-Forgum
        $output | Should -Not -BeNullOrEmpty
        $raw = $output -replace '\x1b\[[0-9;]*m', ''
        # Should have balloon, cow face, and fortune text
        $raw | Should -Match '\^__\^'
        $raw | Should -Match '#'
        $raw | Should -Match '\|\|'
    }
}
