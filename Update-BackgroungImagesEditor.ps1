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
        [int]$Red = 255,
        [Parameter(ValueFromPipeline=$False,Mandatory=$False)]
        [int]$Green = 255,
        [Parameter(ValueFromPipeline=$False,Mandatory=$False)]
        [int]$Blue = 255,
        [Parameter(ValueFromPipeline=$False,Mandatory=$False)]
        [int]$XOffset = 10,
        [Parameter(ValueFromPipeline=$False,Mandatory=$False)]
        [int]$YOffset = 100
     )
    
     [Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null
    
        $SourceImage = [System.Drawing.Image]::FromFile($SourcePath)
        $SourceImage.Height
        $SourceImage.Width
        $TargetImage = new-object System.Drawing.Bitmap([int]($SourceImage.width)),([int]($SourceImage.height))
        $Image = [System.Drawing.Graphics]::FromImage($TargetImage)
        $Image.SmoothingMode = "AntiAlias"
        $Rectangle = New-Object Drawing.Rectangle 0, 0, $SourceImage.Width, $SourceImage.Height
        $Image.DrawImage($SourceImage, $Rectangle, 0, 0, $SourceImage.Width, $SourceImage.Height, ([Drawing.GraphicsUnit]::Pixel))
        $Font = new-object System.Drawing.Font($TextFont, $TextFontSize)
        $SolidBrush = New-Object Drawing.SolidBrush ([System.Drawing.Color]::FromArgb($Transparency, $Red, $Green, $Blue))
        $Image.DrawString($Message, $Font, $SolidBrush, $XOffset, $YOffset)    
        $TargetImage.save($targetPath, [System.Drawing.Imaging.ImageFormat]::Jpeg)
    
        $SourceImage.Dispose()
        $TargetImage.Dispose()
}
    
       
[xml]$ConfigXML = Get-Content "C:\Code\BackgroundImagesEditor.git\Config.xml"
$GlobalConfigXML = Select-XML -XMl $ConfigXML -XPath '//Config'

$GlobalConfig = $GlobalConfigXML.Node.GetElementsByTagName("Global")

$TextBlockXML = Select-XML -XMl $ConfigXML -XPath '//Config'
$TextBlock = $TextBlockXML.Node.GetElementsByTagName("TextBlock")

[string]$TextMessage = $TextBlock.Text



Function Run-Macros()
{   
    Param(
        [Parameter(ValueFromPipeline=$False, Mandatory=$True)]
        [string]$Text
        )

    $Win32_ComputerSystem = Get-WMIObject -class Win32_ComputerSystem | Select-Object *

    if ($TextMessage -Match ([Regex]::Escape("[Domain]")))
    {# username Macro
        $Domain = $Win32_ComputerSystem.Domain
        $TextMessage  = $TextMessage -replace ([Regex]::Escape("[Domain]")),$Domain
    }

    if ($TextMessage -Match ([Regex]::Escape("[Username]")))
    {# username Macro
        #TODO need to remove Domain from username
        $Domain = $Win32_ComputerSystem.Domain
        $UserName = ($Win32_ComputerSystem.Username).replace("$Domain\","")
        $TextMessage  = $TextMessage -replace ([Regex]::Escape("[Username]")),($UserName)
    }

    if ($TextMessage -Match ([Regex]::Escape("[Manufacturer]")))
    {# username Macro
    
        $TextMessage  = $TextMessage -replace ([Regex]::Escape("[Manufacturer]")),($Win32_ComputerSystem.Manufacturer)
    }

    if ($TextMessage -Match ([Regex]::Escape("[Model]")))
    {# username Macro
    
        $TextMessage  = $TextMessage -replace ([Regex]::Escape("[Model]")),($Win32_ComputerSystem.Model)
    }    

        if ($TextMessage -Match ([Regex]::Escape("[IPAddress]")))
        {#TODO
           # $TextMessage  = $TextMessage -replace ([Regex]::Escape("[IPAddress]")),"192.168.0.1"
        }
        
        if ($TextMessage -Match ([Regex]::Escape("[Hostname]")))
        {#TODO
            $TextMessage  = $TextMessage -replace ([Regex]::Escape("[Hostname]")),(hostname)
        }
        

Return $TextMessage

} 

$TextMessageMacro  = Run-Macros -Text $TextMessage

Update-BackGroundImages -SourcePath $GlobalConfig.ImageSource -TargetPath $GlobalConfig.ImageTarget -Message $TextMessageMacro `
                        -XOffset $TextBlock.XOffset -YOffset $TextBlock.YOffset `
                        -Red $GlobalConfig.Red -Green $GlobalConfig.Green -Blue $GlobalConfig.Blue `
                        -Transparency $GlobalConfig.Transparency `
                        -TextFont $GlobalConfig.Font
