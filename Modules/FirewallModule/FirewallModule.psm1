
<#
MIT License

Copyright (c) 2019, 2020 metablaster zebal@protonmail.ch

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
#>

# about: update context for Approve-Execute
# input: rule traffic direction and rule group
# output: none, global context variable is set
# sample: Update-Context $Direction $Group
function Update-Context
{
    param (
        [parameter(Mandatory = $true, Position = 0)]
        [string] $IPVersion,

        [parameter(Mandatory = $true, Position = 1)]
        [string] $Direction,

        [parameter(Mandatory = $false, Position = 2)]
        [string] $Group = $null
    )

    [string] $NewContext = "IPv" + "$IPVersion" + "." + $Direction
    if ($Group)
    {
        $NewContext += " -> " + $Group
    }

    Set-Variable -Name Context -Scope Global -Value $NewContext
}

# about: Used to ask user if he wants to run script.
# input: string to present the user
# output: true if user wants to continue
# sample: Approve-Execute("sample text")
# TODO: implement help [?]
# TODO: make this function more generic
function Approve-Execute
{
    param (
        [parameter(Mandatory = $false)]
        [ValidateLength(2, 3)]
        [string] $DefaultAction = "Yes",

        [parameter(Mandatory = $false)]
        [string] $title = "Executing: " + (Split-Path -Leaf $MyInvocation.ScriptName),

        [parameter(Mandatory = $false)]
        [string] $question = "Do you want to load this ruleset?"
    )

    $choices  = "&Yes", "&No"
    $default = 0
    if ($DefaultAction -like "No") { $default = 1 }

    $title += " [$Context]"
    $decision = $Host.UI.PromptForChoice($title, $question, $choices, $default)

    if ($decision -eq $default)
    {
        return $true
    }

    return $false
}

# about: Show-SDDL returns SDDL based on "object"
# Credits to: https://blogs.technet.microsoft.com/ashleymcglone/2011/08/29/powershell-sid-walker-texas-ranger-part-1/
# sample: see Test\Show-SDDL.ps1 for example
function Show-SDDL
{
    param (
        [Parameter(
            Mandatory = $true,
            valueFromPipelineByPropertyName=$true)] $SDDL
    )

    $SDDLSplit = $SDDL.Split("(")

    Write-Host ""
    Write-Host "SDDL Split:"
    Write-Host "****************"

    $SDDLSplit

    Write-Host ""
    Write-Host "SDDL SID Parsing:"
    Write-Host "****************"

    # Skip index 0 where owner and/or primary group are stored
    for ($i=1;$i -lt $SDDLSplit.Length;$i++)
    {
        $ACLSplit = $SDDLSplit[$i].Split(";")

        if ($ACLSplit[1].Contains("ID"))
        {
            "Inherited"
        }
        else
        {
            $ACLEntrySID = $null

            # Remove the trailing ")"
            $ACLEntry = $ACLSplit[5].TrimEnd(")")

            # Parse out the SID using a handy RegEx
            $ACLEntrySIDMatches = [regex]::Matches($ACLEntry,"(S(-\d+){2,8})")
            $ACLEntrySIDMatches | ForEach-Object {$ACLEntrySID = $_.value}

            If ($ACLEntrySID)
            {
                $ACLEntrySID
            }
            Else
            {
                "Not inherited - No SID"
            }
        }
    }

    return $null
}

# about: Convert SDDL entries to computer accounts
# input: String array of one or more strings of SDDL syntax
# output: String array of computer accounts
# sample: Convert-SDDLToACL $SDDL1, $SDDL2
function Convert-SDDLToACL
{
    param (
        [parameter(Mandatory = $true)]
        [ValidateCount(1, 1000)]
        [ValidateLength(1, 1000)]
        [string[]] $SDDL
    )

    [string[]] $ACL = @()
    foreach ($Entry in $SDDL)
    {
        $ACLObject = New-Object -Type Security.AccessControl.DirectorySecurity
        $ACLObject.SetSecurityDescriptorSddlForm($Entry)
        $ACL += $ACLObject.Access | Select-Object -ExpandProperty IdentityReference | Select-Object -ExpandProperty Value
    }

    return $ACL
}

# about: Write informational note with 'NOTE:' label and green text
# input: string to write
# output: informational message: NOTE: sample note
# sample: Write-Note "sample note"
function Write-Note
{
    param (
        [parameter(Mandatory = $true)]
        [string[]] $Notes
    )

    Write-Host "NOTE: $($Notes[0])" -ForegroundColor Green -BackgroundColor Black

    # Skip 'NOTE:' tag for all subsequent messages
    for ($Index = 1; $Index -lt $Notes.Count; ++$Index)
    {
        Write-Host $Notes[$Index] -ForegroundColor Green -BackgroundColor Black
    }
}

# about: Custom Write-Warning which also sets global warning sttus
# input: string to write and wether to update warning status
# output: warning message: WARNING: sample warning
# sample: Set-Warning "sample warning"
function Set-Warning
{
    param (
        [parameter(Mandatory = $true)]
        [string] $Message,
        [parameter(Mandatory = $false)]
        [bool] $Status = $true
    )

    # First show the warning before any possible error happens
    $Warning = "WARNING: $Message"
    Set-Variable -Name WarningStatus -Scope Global -Value ($WarningStatus -or $Status)
    Write-Host $Warning -ForegroundColor Yellow -BackgroundColor Black

    # Append warning to log file
    $LogsFolder = $RepoDir + "\Logs"
    $FileName = "Warning_$(Get-Date -Format "dd.MM.yy HH")h.log"
    $LogFile = "$LogsFolder\$FileName"

    if (!(Test-Path -PathType Container -Path $LogsFolder))
    {
        New-Item -ItemType Directory -Path $LogsFolder -ErrorAction Stop| Out-Null
    }

    if (!(Test-Path -PathType Leaf -Path $LogFile))
    {
        New-Item -ItemType File -Path $LogFile -ErrorAction Stop| Out-Null
    }

    # Include time in file
    $Warning = "WARNING: $(Get-Date -Format "HH:mm")h $Message"
    Add-Content -Path $LogFile -Value $Warning
}

# about: list all generated errors and clear error variable
# input: none
# output: list of errors
# sample: Save-Errors
function Save-Errors
{
    if ($global:Error.Count -eq 0)
    {
        Write-Note "No errors detected"
        return
    }

    # Write all errors to log file
    $LogsFolder = $RepoDir + "\Logs"
    $FileName = "Error_$(Get-Date -Format "dd.MM.yy HH")h.log"
    $LogFile = "$LogsFolder\$FileName"

    if (!(Test-Path -PathType Container -Path $LogsFolder))
    {
        New-Item -ItemType Directory -Path $LogsFolder -ErrorAction Stop| Out-Null
    }

    if (!(Test-Path -PathType Leaf -Path $LogFile))
    {
        New-Item -ItemType File -Path $LogFile -ErrorAction Stop| Out-Null
    }

    # Include time in file
    $Time = "$(Get-Date -Format "HH:mm")h"

    $AllErrors = @()
    foreach ($Err in $global:Error)
    {
        $AllErrors += "ERROR: $Time $Err`nSTACKTRACE: $($Err.ScriptStackTrace)`n"
    }

    Add-Content -Path $LogFile -Value $AllErrors
    Write-Note "All errors were saved to:", $LogsFolder, "you can review these logs to see which scripts need to be fixed and where"

    $global:Error.Clear()
}

# about: Scan all scripts in repository and get windows service names involved in rules
# input: Root folder name which to scan
# output: None, file with the list of services is made
# sample: Get-NetworkServices C:\PathToRepo
function Get-NetworkServices
{
    param (
        [parameter(Mandatory = $true)]
        [string] $Folder
    )

    if (!(Test-Path -Path $Folder))
    {
        Set-Warning "Unable to locate path '$Folder'"
        return
    }

    # Recusively get powershell scripts in input folder
    $Files = Get-ChildItem -Path $Folder -Recurse -Filter *.ps1
    if (!$Files)
    {
        Set-Warning "No powershell script files found in '$Folder'"
        return
    }

    $Content = @()
    # Filter out service names from each powershell file in input folder
    $Files | Foreach-Object {
        Get-Content $_.FullName | Where-Object {
            if ($_ -match "(?<= -Service )(.*)(?= -Program)")
            {
                $Content += $Matches[0]
            }
        }
    }

    if (!$Content)
    {
        Set-Warning "No matches found in any of the bellow files:"
        Write-Host "$($Files | Select-Object -ExpandProperty Name)"
        return
    }

    # Get rid of duplicate matches and known bad values
    $Content = $Content | Select-Object -Unique
    $Content = $Content | Where-Object { $_ -ne '$Service' -and $_ -ne "Any" }

    # File name where to save all matches
    $File = "$PSScriptRoot\..\..\Rules\NetworkServices.txt"

    # If output file exists clear it
    # otherwise create a new file
    if (Test-Path -Path $File)
    {
        Clear-Content -Path $File
    }
    else
    {
        New-Item -ItemType File -Path $File| Out-Null
    }

    # Save filtered services to a new file
    Add-Content -Path $File -Value $Content
    Write-Note "$($Content.Count) services involved in firewall rules"
}


# about: format firewall rule output for display
# input: CimInstance from Net-NewFirewallRule
# outbput: formatted text
# sample: Net-NewFirewallRule ... | Format-Output
function Format-Output
{
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true,
        ValueFromPipeline = $true)]
        [Microsoft.Management.Infrastructure.CimInstance] $Rule
    )

    process
    {
        Write-Host "Load Rule: [$($Rule | Select-Object -ExpandProperty Group)] -> $($Rule | Select-Object -ExpandProperty DisplayName)" -ForegroundColor Cyan
    }
}

# about: set vertical screen buffer to recommended value
function Set-ScreenBuffer
{
    $psHost = Get-Host
    $psWindow = $psHost.UI.RawUI
    $NewSize = $psWindow.BufferSize

    $NewBuffer = (Get-Variable -Name RecommendedBuffer -Scope Script).Value

    if ($NewSize.Height -lt $NewBuffer)
    {
        Write-Warning "Your screen buffer of $($NewSize.Height) is below recommended $NewBuffer to preserve all execution output"

        $Choices  = "&Yes", "&No"
        $Default = 0
        $Title = "Increase Screen Buffer"
        $Question = "Would you like to increase screen buffer to $($NewBuffer)?"
        $Decision = $Host.UI.PromptForChoice($Title, $Question, $Choices, $Default)

        if ($Decision -eq $Default)
        {
            $NewSize.Height = $NewBuffer
            $psWindow.BufferSize = $NewSize
            Write-Note "Screen buffer changed to $NewBuffer"
        }
    }
}

#
# Module variables
#

# Windows 10 and above
New-Variable -Name Platform -Option Constant -Scope Global -Value "10.0+"
# Machine where to apply rules (default: Local Group Policy)
New-Variable -Name PolicyStore -Option Constant -Scope Global -Value "localhost"
# Stop executing commandlet if error
New-Variable -Name OnError -Option Constant -Scope Global -Value "Stop"
# To add rules to firewall for real set to false
New-Variable -Name Debug -Scope Global -Value $false
# To prompt for each rule set to true
New-Variable -Name Execute -Scope Global -Value $false
# Most used program
New-Variable -Name ServiceHost -Option Constant -Scope Global -Value "%SystemRoot%\System32\svchost.exe"
# Default network interface card, change this to NIC which your PC uses
New-Variable -Name Interface -Option Constant -Scope Global -Value "Wired, Wireless"
# Global execution context, used in Approve-Execute
New-Variable -Name Context -Scope Global -Value "Context not set"
# Global variable to tell if all scripts ran clean
New-Variable -Name WarningStatus -Scope Global -Value $false
# To force loading rules regardless of presence of program set to true
New-Variable -Name Force -Scope Global -Value $true
# Recommended vertical screen buffer value, to ensure user can scroll back all the output
New-Variable -Name RecommendedBuffer -Scope Script -Value 3000
# Repository root directory
New-Variable -Name RepoDir -Scope Global -Option Constant -Value (Resolve-Path -Path "$PSScriptRoot\..\.." | Select-Object -ExpandProperty Path)

#
# Function exports
#

Export-ModuleMember -Function Approve-Execute
Export-ModuleMember -Function Update-Context
Export-ModuleMember -Function Convert-SDDLToACL
Export-ModuleMember -Function Show-SDDL
Export-ModuleMember -Function Write-Note
Export-ModuleMember -Function Get-NetworkServices
Export-ModuleMember -Function Format-Output
Export-ModuleMember -Function Save-Errors
Export-ModuleMember -Function Set-Warning
Export-ModuleMember -Function Set-ScreenBuffer

#
# Variable exports
#

Export-ModuleMember -Variable Platform
Export-ModuleMember -Variable PolicyStore
Export-ModuleMember -Variable OnError
Export-ModuleMember -Variable Debug
Export-ModuleMember -Variable Execute
Export-ModuleMember -Variable ServiceHost
Export-ModuleMember -Variable Interface

Export-ModuleMember -Variable Context
Export-ModuleMember -Variable WarningStatus
Export-ModuleMember -Variable RepoDir
