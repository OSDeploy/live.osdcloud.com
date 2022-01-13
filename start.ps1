function Set-WinPELocalAppData
{
    [CmdletBinding()]
    param()

    if (Get-Item env:LOCALAPPDATA -ErrorAction Ignore)
    {
        Write-Verbose 'System Environment Variable LOCALAPPDATA is already present in this PowerShell session'
    }
    else
    {
        Write-Verbose 'WinPE does not have the LOCALAPPDATA System Environment Variable'
        Write-Verbose 'This can be enabled for this Power Session, but it will not persist'
        Write-Verbose 'Set System Environment Variable LOCALAPPDATA for this PowerShell session'
        [System.Environment]::SetEnvironmentVariable('LOCALAPPDATA',"$env:UserProfile\AppData\Local")

        if (!(Test-Path "$env:UserProfile\Documents\WindowsPowerShell")) {
            New-Item -Path "$env:UserProfile\Documents\WindowsPowerShell" -ItemType Directory -Force | Out-Null
        }

# WinPE PowerShell Profile
$PowerShellProfile = @'
[System.Environment]::SetEnvironmentVariable('LOCALAPPDATA',"$env:UserProfile\AppData\Local")
'@

        Write-Verbose 'Set PowerShell Profile for this WinPE Session'
        $PowerShellProfile | Set-Content -Path "$env:UserProfile\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" -Force -Encoding Unicode
    }
}
function Install-WinPEPackageManagement
{
    [CmdletBinding()]
    param()
    
    Set-WinPELocalAppData

    if (!(Get-Module -Name PackageManagement)){
        $PackageManagementURL = "https://psg-prod-eastus.azureedge.net/packages/packagemanagement.1.4.7.nupkg"
        Invoke-WebRequest -UseBasicParsing -Uri $PackageManagementURL -OutFile "$env:TEMP\packagemanagement.1.4.7.zip"
        $Null = New-Item -Path "$env:TEMP\1.4.7" -ItemType Directory -Force
        Expand-Archive -Path "$env:TEMP\packagemanagement.1.4.7.zip" -DestinationPath "$env:TEMP\1.4.7"
        $Null = New-Item -Path "$env:ProgramFiles\WindowsPowerShell\Modules\PackageManagement" -ItemType Directory -ErrorAction SilentlyContinue
        Move-Item -Path "$env:TEMP\1.4.7" -Destination "$env:ProgramFiles\WindowsPowerShell\Modules\PackageManagement\1.4.7"
        Import-Module PackageManagement -Force
    }
}
function Install-WinPEPowerShellGet
{
    [CmdletBinding()]
    param()

    Set-WinPELocalAppData

    if (!(Get-Module -Name PowerShellGet)){
        $PowerShellGetURL = "https://psg-prod-eastus.azureedge.net/packages/powershellget.2.2.5.nupkg"
        Invoke-WebRequest -UseBasicParsing -Uri $PowerShellGetURL -OutFile "$env:TEMP\powershellget.2.2.5.zip"
        $Null = New-Item -Path "$env:TEMP\2.2.5" -ItemType Directory -Force
        Expand-Archive -Path "$env:TEMP\powershellget.2.2.5.zip" -DestinationPath "$env:TEMP\2.2.5"
        $Null = New-Item -Path "$env:ProgramFiles\WindowsPowerShell\Modules\PowerShellGet" -ItemType Directory -ErrorAction SilentlyContinue
        Move-Item -Path "$env:TEMP\2.2.5" -Destination "$env:ProgramFiles\WindowsPowerShell\Modules\PowerShellGet\2.2.5"
        Import-Module PowerShellGet -Force

        $PSRepository = Get-PSRepository -Name PSGallery

        if ($PSRepository)
        {
            if ($PSRepository.InstallationPolicy -ne 'Trusted')
            {
                Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
            }
        }
    }
}
function Set-WinPEPSGallery
{
    [CmdletBinding()]
    param()

    $PSRepository = Get-PSRepository -Name PSGallery

    if ($PSRepository)
    {
        if ($PSRepository.InstallationPolicy -ne 'Trusted')
        {
            Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
        }
    }
}

function Install-WinPEOSDModule
{
    [CmdletBinding()]
    param()
    Install-Module OSD -Force
    Import-Module OSD -Force
}

function Install-WinPEPSGallery
{
    [CmdletBinding()]
    param()

    Set-WinPELocalAppData
    Install-WinPEPackageManagement
    Install-WinPEPowerShellGet
    Set-WinPEPSGallery
}

if ($env:SystemDrive -eq 'X:')
{
    Write-Verbose -Verbose 'https://github.com/OSDeploy/live.osdcloud.com'
    Write-Verbose -Verbose 'Version 22.1.12.1'
    Set-ExecutionPolicy Bypass -Force -Verbose
    Set-WinPELocalAppData

    $script:NuGetBinaryProgramDataPath="$env:ProgramFiles\PackageManagement\ProviderAssemblies"
    $script:NuGetBinaryLocalAppDataPath="$env:LOCALAPPDATA\PackageManagement\ProviderAssemblies"
    # go fwlink for 'https://nuget.org/nuget.exe'
    $script:NuGetClientSourceURL = 'https://go.microsoft.com/fwlink/?LinkID=690216&clcid=0x409'
    $script:NuGetExeName = 'NuGet.exe'
    $script:NuGetExePath = $null
    $script:NuGetProvider = $null

    $script:PSGetProgramDataPath = Microsoft.PowerShell.Management\Join-Path -Path $env:ProgramData -ChildPath 'Microsoft\Windows\PowerShell\PowerShellGet\'
    $nugetExeBasePath = $script:PSGetProgramDataPath
    if(-not (Microsoft.PowerShell.Management\Test-Path -Path $nugetExeBasePath))
    {
        $null = Microsoft.PowerShell.Management\New-Item -Path $nugetExeBasePath `
                                                         -ItemType Directory -Force `
                                                         -ErrorAction SilentlyContinue `
                                                         -WarningAction SilentlyContinue `
                                                         -Confirm:$false -WhatIf:$false
    }
    $nugetExeFilePath = Microsoft.PowerShell.Management\Join-Path -Path $nugetExeBasePath -ChildPath $script:NuGetExeName
    # Download the NuGet.exe from http://nuget.org/NuGet.exe
    $null = Microsoft.PowerShell.Utility\Invoke-WebRequest -Uri $script:NuGetClientSourceURL -OutFile $nugetExeFilePath

    $script:PSGetAppLocalPath = Microsoft.PowerShell.Management\Join-Path -Path $env:LOCALAPPDATA -ChildPath 'Microsoft\Windows\PowerShell\PowerShellGet\'
    $nugetExeBasePath = $script:PSGetAppLocalPath
    if(-not (Microsoft.PowerShell.Management\Test-Path -Path $nugetExeBasePath))
    {
        $null = Microsoft.PowerShell.Management\New-Item -Path $nugetExeBasePath `
                                                         -ItemType Directory -Force `
                                                         -ErrorAction SilentlyContinue `
                                                         -WarningAction SilentlyContinue `
                                                         -Confirm:$false -WhatIf:$false
    }
    $nugetExeFilePath = Microsoft.PowerShell.Management\Join-Path -Path $nugetExeBasePath -ChildPath $script:NuGetExeName
    # Download the NuGet.exe from http://nuget.org/NuGet.exe
    $null = Microsoft.PowerShell.Utility\Invoke-WebRequest -Uri $script:NuGetClientSourceURL -OutFile $nugetExeFilePath

    Install-WinPEPackageManagement
    Install-WinPEPowerShellGet
    Set-WinPEPSGallery
    #Register-PackageSource -Name Nuget -Location 'http://www.nuget.org/api/v2' -ProviderName Nuget -Trusted

    #Find-PackageProvider -Name PowerShellGet | Install-PackageProvider -Force
    #Find-PackageProvider -Name Nuget | Install-PackageProvider -Force
    #Get-PackageProvider Nuget -ForceBootstrap

    if (!(Get-Command 'curl.exe' -ErrorAction SilentlyContinue))
    {
        Write-Warning 'live.osdcloud.com does not include curl.exe yet so you will not be able to use OSDCloud'
    }
}