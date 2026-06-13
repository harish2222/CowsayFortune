function Invoke-Cowsay {
    <#
    .SYNOPSIS
        Displays a cow saying a message.
    .DESCRIPTION
        Renders an ASCII cow with a speech balloon containing the message.
        Supports custom cow files, eyes, tongue, and thinking mode.
        Optionally applies rainbow lolcat colorization.
    .PARAMETER Text
        The message for the cow to say.
    .PARAMETER CowFile
        Name of the cow file to use (default: 'default').
    .PARAMETER Eyes
        Two-character eye string (default: 'oo').
    .PARAMETER Tongue
        Two-character tongue string (default: '  ').
    .PARAMETER Thoughts
        Character for the thought bubble connector (default: '\').
    .PARAMETER Lolcat
        Enable rainbow lolcat colorization for this invocation.
    .EXAMPLE
        Invoke-Cowsay -Text "Hello World"
    .EXAMPLE
        Invoke-Cowsay -Text "Hello World" -Lolcat
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(ValueFromPipeline)]
        [AllowEmptyString()]
        [string]$Text = '',

        [ValidateNotNullOrEmpty()]
        [string]$CowFile = 'default',

        [ValidateNotNullOrEmpty()]
        [ValidateLength(2,2)]
        [string]$Eyes = 'oo',

        [ValidateLength(2,2)]
        [string]$Tongue = '  ',

        [string]$Thoughts = '\',

        [switch]$Lolcat
    )

    process {
        $config = Get-CFConfig

        # Resolve random cow if configured
        if ($config.cow.random) {
            $cowsPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'Data/Cows'
            $cowFiles = Get-ChildItem -Path $cowsPath -Filter '*.cow' -ErrorAction SilentlyContinue
            if (-not $cowFiles) { throw "No cow files found in $cowsPath" }
            $CowFile = ($cowFiles | Get-Random).BaseName
        }

        # Resolve cow mode presets (eyes/tongue overrides)
        if ($config.cow.mode) {
            $modes = @{
                'b' = @{ eyes = '=='; tongue = '  ' }
                'd' = @{ eyes = 'xx'; tongue = 'U ' }
                'g' = @{ eyes = '$$'; tongue = '  ' }
                'p' = @{ eyes = '@@'; tongue = '  ' }
                's' = @{ eyes = '**'; tongue = 'U ' }
                't' = @{ eyes = '--'; tongue = '  ' }
                'w' = @{ eyes = 'OO'; tongue = '  ' }
                'y' = @{ eyes = '..'; tongue = '  ' }
            }
            if ($modes.ContainsKey($config.cow.mode)) {
                if (-not $PSBoundParameters.ContainsKey('Eyes'))   { $Eyes   = $modes[$config.cow.mode].eyes }
                if (-not $PSBoundParameters.ContainsKey('Tongue')) { $Tongue = $modes[$config.cow.mode].tongue }
            }
        } else {
            if (-not $PSBoundParameters.ContainsKey('Eyes'))   { $Eyes   = if ($config.cow.eyes)   { $config.cow.eyes }   else { 'oo' } }
            if (-not $PSBoundParameters.ContainsKey('Tongue')) { $Tongue = if ($config.cow.tongue) { $config.cow.tongue } else { '  ' } }
        }

        # Build the cow template with variable substitutions
        $cowTemplate = Read-CowFile -CowName $CowFile
        $message = Format-CowMessage -Text $Text -MaxWidth $config.output.maxWidth

        # Apply substitutions using StringBuilder for performance
        $sb = [System.Text.StringBuilder]::new($cowTemplate)
        [void]$sb.Replace('$thoughts', $Thoughts)
        [void]$sb.Replace('$eyes', $Eyes)
        [void]$sb.Replace('${eyes}', $Eyes)
        [void]$sb.Replace('$tongue', $Tongue)
        [void]$sb.Replace('${tongue}', $Tongue)

        # Replace single-char eye placeholders ($eye) on the first matching line only
        $result = $sb.ToString()
        if ($Eyes.Length -ge 2) {
            $lines = $result -split "`n"
            $eyeReplaced = $false
            $newLines = [System.Collections.Generic.List[string]]::new($lines.Count)

            foreach ($line in $lines) {
                if (-not $eyeReplaced -and $line -match '\$eye') {
                    $replaced = $line -replace '\$eye', $Eyes[0]
                    $replaced = $replaced -replace '\$eye', $Eyes[1]
                    $newLines.Add($replaced)
                    $eyeReplaced = $true
                } else {
                    $newLines.Add($line)
                }
            }
            $result = $newLines -join "`n"
        }

        $output = "$message`n$result"

        # Apply lolcat if explicitly requested via -Lolcat switch
        if ($Lolcat) {
            $output = Format-Lolcat -Text $output `
                -Frequency $config.lolcat.frequency `
                -Truecolor:$config.lolcat.truecolor
        }

        return $output
    }
}