Write-Verbose -Verbose 'https://github.com/OSDeploy/live.osdcloud.com'
Write-Verbose -Verbose 'Version 22.1.12.1'

if ($env:SystemDrive -eq 'X:')
{
    Set-ExecutionPolicy Bypass -Force -Verbose
}
function Set-LocalAppData
{
    [CmdletBinding()]
    param()
    [System.Environment]::SetEnvironmentVariable('LOCALAPPDATA',"$env:UserProfile\AppData\Local")

    Write-Verbose 'Set-LocalAppData complete'
}
Write-Verbose -Verbose 'Set-LocalAppData will set the System Environment'