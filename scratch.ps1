function get-loggedonuser ($computername){
    #https://stackoverflow.com/questions/23219718/powershell-script-to-see-currently-logged-in-users-domain-and-machine-status
        #mjolinor 3/17/10
        
        $regexa = '.+Domain="(.+)",Name="(.+)"$'
        $regexd = '.+LogonId="(\d+)"$'
        
        $logontype = @{
        "0"="Local System"
        "2"="Interactive" #(Local logon)
        "3"="Network" # (Remote logon)
        "4"="Batch" # (Scheduled task)
        "5"="Service" # (Service account logon)
        "7"="Unlock" #(Screen saver)
        "8"="NetworkCleartext" # (Cleartext network logon)
        "9"="NewCredentials" #(RunAs using alternate credentials)
        "10"="RemoteInteractive" #(RDP\TS\RemoteAssistance)
        "11"="CachedInteractive" #(Local w\cached credentials)
        }
        
        $logon_sessions = @(gwmi win32_logonsession -ComputerName $computername)
        $logon_users = @(gwmi win32_loggedonuser -ComputerName $computername)
        
        $session_user = @{}
        
        $logon_users |% {
        $_.antecedent -match $regexa > $nul
        $username = $matches[1] + "\" + $matches[2]
        $_.dependent -match $regexd > $nul
        $session = $matches[1]
        $session_user[$session] += $username
        }
        
        
        $logon_sessions |%{
        $starttime = [management.managementdatetimeconverter]::todatetime($_.starttime)
        
        $loggedonuser = New-Object -TypeName psobject
        $loggedonuser | Add-Member -MemberType NoteProperty -Name "Session" -Value $_.logonid
        $loggedonuser | Add-Member -MemberType NoteProperty -Name "User" -Value $session_user[$_.logonid]
        $loggedonuser | Add-Member -MemberType NoteProperty -Name "Type" -Value $logontype[$_.logontype.tostring()]
        $loggedonuser | Add-Member -MemberType NoteProperty -Name "Auth" -Value $_.authenticationpackage
        $loggedonuser | Add-Member -MemberType NoteProperty -Name "StartTime" -Value $starttime
        
        $loggedonuser
        }
        
        }
    
    get-loggedonuser -computername $(hostname)
    
    
    
    get-WMIObject -class Win32_ComputerSystem | select username
    
    <#
    Add-Type -AssemblyName System.Windows.Forms
    $Monitors = [System.Windows.Forms.Screen]::AllScreens
    
    foreach ($Monitor in $Monitors)
    {
        $DeviceName = (($Monitor.DeviceName).replace("\", "")).replace(".", "")
        $Width = $Monitor.bounds.Width
        $Height = $Monitor.bounds.Height
        Write-Host "$DeviceName - $Width x $height"
    }
    #>

    

$path = "C:\Code\BackgroundImagesEditor.git\result.jpg"
#https://superuser.com/questions/1341997/using-a-uwp-api-namespace-in-powershell
[Windows.System.UserProfile.LockScreen,Windows.System.UserProfile,ContentType=WindowsRuntime] | Out-Null
Add-Type -AssemblyName System.Runtime.WindowsRuntime
$asTaskGeneric = ([System.WindowsRuntimeSystemExtensions].GetMethods() | ? { $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1' })[0]
Function Await($WinRtTask, $ResultType) {
$asTask = $asTaskGeneric.MakeGenericMethod($ResultType)
$netTask = $asTask.Invoke($null, @($WinRtTask))
$netTask.Wait(-1) | Out-Null
$netTask.Result
}
Function AwaitAction($WinRtAction) {
$asTask = ([System.WindowsRuntimeSystemExtensions].GetMethods() | ? { $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and !$_.IsGenericMethod })[0]
$netTask = $asTask.Invoke($null, @($WinRtAction))
$netTask.Wait(-1) | Out-Null
}

[Windows.Storage.StorageFile,Windows.Storage,ContentType=WindowsRuntime] | Out-Null
$image = Await ([Windows.Storage.StorageFile]::GetFileFromPathAsync($path)) ([Windows.Storage.StorageFile])
AwaitAction ([Windows.System.UserProfile.LockScreen]::SetImageFileAsync($image))



