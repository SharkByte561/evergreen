Function Get-MicrosoftWvdBootLoader {
    <#
        .SYNOPSIS
            Get the current version and download URL for the Microsoft Remote Desktop Boot Loader.

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
        [System.String] $Filter
    )

    # Grab the download link headers to find the file name
    try {
        #TODO: turn this into a function
        $params = @{
            Uri             = $res.Get.Uri
            Method          = "Head"
            UseBasicParsing = $True
            ErrorAction     = "Continue"
        }
        $Headers = (Invoke-WebRequest @params).Headers
    }
    catch {
        Throw "$($MyInvocation.MyCommand): Error at: $($res.Get.Uri) with: $($_.Exception.Response.StatusCode)"
    }

    If ($Headers) {
        # Match filename
        $Filename = [RegEx]::Match($Headers['Content-Disposition'], $res.Get.MatchFilename).Captures.Groups[1].Value

        # Match version
        $Version = [RegEx]::Match($Headers['Content-Disposition'], $res.Get.MatchVersion).Captures.Value
        If ($Version.Length -eq 0) { $Version = "Unknown" }

        # Construct the output; Return the custom object to the pipeline
        $PSObject = [PSCustomObject] @{
            Version      = $Version
            Architecture = Get-Architecture -String $Filename
            Date         = $Headers['Last-Modified'] | Select-Object -First 1
            Size         = $Headers['Content-Length'] | Select-Object -First 1
            Filename     = $Filename
            URI          = $res.Get.Uri
        }
        Write-Output -InputObject $PSObject
    }
    Else {
        Throw "$($MyInvocation.MyCommand): Failed to return a header from $($res.Get.Uri)."
    }
}
