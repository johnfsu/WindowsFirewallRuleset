
<#
MIT License

Project: "Windows Firewall Ruleset" serves to manage firewall on Windows systems
Homepage: https://github.com/metablaster/WindowsFirewallRuleset

Copyright (C) 2019, 2020 metablaster zebal@protonmail.ch

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

#
# Unit test for Get-InterfaceAliases
#
. $PSScriptRoot\..\..\Config\ProjectSettings.ps1

# Check requirements for this project
Import-Module -Name $ProjectRoot\Modules\Project.AllPlatforms.System
Test-SystemRequirements

# Includes
. $PSScriptRoot\ContextSetup.ps1
Import-Module -Name $ProjectRoot\Modules\Project.AllPlatforms.Logging
Import-Module -Name $ProjectRoot\Modules\Project.AllPlatforms.Test @Logs
Import-Module -Name $ProjectRoot\Modules\Project.Windows.ComputerInfo @Logs
Import-Module -Name $ProjectRoot\Modules\Project.AllPlatforms.Utility @Logs

# Ask user if he wants to load these rules
Update-Context $TestContext $($MyInvocation.MyCommand.Name -replace ".{4}$") @Logs
if (!(Approve-Execute @Logs)) { exit }

Start-Test

New-Test "Get-InterfaceAliases IPv4"
$Aliases = Get-InterfaceAliases IPv4 @Logs
$Aliases.ToWql()

New-Test "Get-InterfaceAliases IPv6"
$Aliases = Get-InterfaceAliases IPv6 @Logs
$Aliases.ToWql()

New-Test "Get-InterfaceAliases IPv4 -IncludeDisconnected -WildCardOption"
$Aliases = Get-InterfaceAliases IPv4 -IncludeDisconnected -WildCardOption IgnoreCase @Logs
$Aliases.ToWql()

New-Test "Get-InterfaceAliases IPv4 -IncludeVirtual"
$Aliases = Get-InterfaceAliases IPv4 -IncludeVirtual @Logs
$Aliases.ToWql()

New-Test "Get-InterfaceAliases IPv4 -IncludeVirtual -IncludeDisconnected"
$Aliases = Get-InterfaceAliases IPv4 -IncludeVirtual -IncludeDisconnected @Logs
$Aliases.ToWql()

New-Test "Get-InterfaceAliases IPv4 -IncludeVirtual -IncludeDisconnected -ExcludeHardware"
$Aliases = Get-InterfaceAliases IPv4 -IncludeVirtual -IncludeDisconnected -ExcludeHardware @Logs
$Aliases.ToWql()

New-Test "Get-InterfaceAliases IPv4 -IncludeHidden"
$Aliases = Get-InterfaceAliases IPv4 -IncludeHidden @Logs
$Aliases.ToWql()

New-Test "Get-InterfaceAliases IPv4 -IncludeAll"
$Aliases = Get-InterfaceAliases IPv4 -IncludeAll @Logs
$Aliases.ToWql()

New-Test "Get-InterfaceAliases IPv4 -IncludeAll -ExcludeHardware"
$Aliases = Get-InterfaceAliases IPv4 -IncludeAll -ExcludeHardware @Logs
$Aliases.ToWql()

New-Test "Get-TypeName"
$Aliases | Get-TypeName @Logs

Update-Logs
Exit-Test
