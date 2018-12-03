Function Update-BackGroundImages(){
[CmdletBinding()]
     Param (
        [Parameter(ValueFromPipeline=$False, Mandatory=$True)]
        [string]$SourcePath,
        [Parameter(ValueFromPipeline=$False,Mandatory=$True)]
        [string]$TargetPath,
        [Parameter(ValueFromPipeline=$False,Mandatory=$True)]
        [string]$Message,
        [Parameter(ValueFromPipeline=$False,Mandatory=$False)]
        [int]$Transparency = 255,
        [Parameter(ValueFromPipeline=$False,Mandatory=$False)]
        [String]$TextFont = "Verdana",
        [Parameter(ValueFromPipeline=$False,Mandatory=$False)]
        [int]$TextFontSize = 25,
        [Parameter(ValueFromPipeline=$False,Mandatory=$False)]
        [int]$R = 255,
        [Parameter(ValueFromPipeline=$False,Mandatory=$False)]
        [int]$G = 255,
        [Parameter(ValueFromPipeline=$False,Mandatory=$False)]
        [int]$B = 255
     )
    
     [Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null
    
        $SourceImage = [System.Drawing.Image]::FromFile($SourcePath)
        $SourceImage.Height
        $SourceImage.Width
        $TargetImage = new-object System.Drawing.Bitmap([int]($SourceImage.width)),([int]($SourceImage.height))
        $Image = [System.Drawing.Graphics]::FromImage($TargetImage)
        $Image.SmoothingMode = "AntiAlias"
        #$Rectangle = New-Object Drawing.Rectangle 0, 0, $SourceImage.Width, $SourceImage.Height
        $Rectangle = New-Object Drawing.Rectangle 0, 0, 1600, 900
        $Image.DrawImage($SourceImage, $Rectangle, 0, 0, $SourceImage.Width, $SourceImage.Height, ([Drawing.GraphicsUnit]::Pixel))
        $Font = new-object System.Drawing.Font($TextFont, $TextFontSize)
        $SolidBrush = New-Object Drawing.SolidBrush ([System.Drawing.Color]::FromArgb($Transparency, $R, $G, $B))
        $Image.DrawString($Message, $Font, $SolidBrush, 10, 100)    
        $TargetImage.save($targetPath, [System.Drawing.Imaging.ImageFormat]::Jpeg)
    
        $SourceImage.Dispose()
        $TargetImage.Dispose()
}
    
    
     
    
    Update-BackGroundImages -SourcePath C:\Code\BackgroundImagesEditor.git\img0.jpg -TargetPath C:\Code\BackgroundImagesEditor.git\result.jpg -Message "Testing123" 


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




Add-Type -AssemblyName System.Windows.Forms
$Monitors = [System.Windows.Forms.Screen]::AllScreens

foreach ($Monitor in $Monitors)
{
	$DeviceName = (($Monitor.DeviceName).replace("\", "")).replace(".", "")
	$Width = $Monitor.bounds.Width
	$Height = $Monitor.bounds.Height
	Write-Host "$DeviceName - $Width x $height"
}