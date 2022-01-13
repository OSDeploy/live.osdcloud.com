# https://github.com/OSDeploy/live.osdcloud.com

# LOCALAPPDATA System Environment Variable
if (Get-Item env:LOCALAPPDATA -ErrorAction Ignore)
{
    Write-Verbose -Verbose 'System Environment Variable LOCALAPPDATA is already present in this PowerShell session'
}
else
{
    Write-Verbose 'WinPE does not have the LOCALAPPDATA System Environment Variable'
    Write-Verbose 'This can be enabled for this Power Session, but it will not persist'
    Write-Verbose -Verbose 'Set System Environment Variable LOCALAPPDATA for this PowerShell session'
    [System.Environment]::SetEnvironmentVariable('LOCALAPPDATA',"$env:UserProfile\AppData\Local")
}