Function Get-MozillaFirefox {
    <#
        .SYNOPSIS
            Returns downloads for the latest Mozilla Firefox releases.

        .NOTES
            Site: https://stealthpuppy.com
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]),

        [Parameter(Mandatory = $False, Position = 1)]
        [ValidateNotNull()]
        [System.String[]] $Language = @("en-US")
    )

    # Get latest Firefox version
    $Versions = Invoke-RestMethodWrapper -Uri $res.Get.Update.Uri

    # Construct custom object with output details
    ForEach ($currentLanguage in $Language) {
        ForEach ($channel in $res.Get.Update.Channels) {
            ForEach ($platform in $res.Get.Download.Platforms) {

                # Select the download file for the selected platform
                ForEach ($installer in $res.Get.Download.Uri[$channel].GetEnumerator()) {
                    $params = @{
                        Uri = (($res.Get.Download.Uri[$channel][$installer.Key] -replace $res.Get.Download.ReplaceText.Platform, $platform) -replace $res.Get.Download.ReplaceText.Language, $currentLanguage)
                    }
                    $Url = Resolve-InvokeWebRequest @params

                    If ($Null -ne $Url) {
                        # Build object and output to the pipeline
                        $PSObject = [PSCustomObject] @{
                            Version      = $Versions.$channel -replace $res.Get.Download.ReplaceText.Version, ""
                            Architecture = Get-Architecture -String $platform
                            Channel      = $channel
                            Language     = $currentLanguage
                            Type         = [System.IO.Path]::GetExtension($Url).Split(".")[-1]
                            Filename     = (Split-Path -Path $Url -Leaf).Replace('%20', ' ')
                            URI          = $Url
                        }
                        Write-Output -InputObject $PSObject
                    }
                }
            }
        }
    }
}
