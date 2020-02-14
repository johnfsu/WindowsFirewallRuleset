
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

. $PSScriptRoot\..\..\..\..\UnloadModules.ps1

# Check requirements for this project
Import-Module -Name $PSScriptRoot\..\..\..\..\Modules\System
Test-SystemRequirements

# Includes
. $PSScriptRoot\..\DirectionSetup.ps1
. $PSScriptRoot\..\..\IPSetup.ps1
Import-Module -Name $RepoDir\Modules\UserInfo
Import-Module -Name $RepoDir\Modules\ProgramInfo
Import-Module -Name $RepoDir\Modules\FirewallModule

#
# Setup local variables:
#
$Group = "Software - Thuderbird"
$Profile = "Private, Public"

# Ask user if he wants to load these rules
Update-Context "IPv$IPVersion" $Direction $Group
if (!(Approve-Execute)) { exit }

# First remove all existing rules matching group
Remove-NetFirewallRule -PolicyStore $PolicyStore -Group $Group -Direction $Direction -ErrorAction SilentlyContinue

#
# Thunderbird installation directories
#
$ThunderbirdRoot = "%ProgramFiles%\Mozilla Thunderbird"

#
# Rules for Mozilla Thunderbird mail client
#

# Test if installation exists on system
if ((Test-Installation "Thuderbird" ([ref] $ThunderbirdRoot)) -or $Force)
{
	$Program = "$ThunderbirdRoot\thunderbird.exe"
	Test-File $Program
	New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
	-DisplayName "Mozilla thunderbird - HTTP/HTTPS" -Service Any -Program $Program `
	-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
	-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 80, 443 `
	-LocalUser $UserAccountsSDDL `
	-Description "" | Format-Output

	New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
	-DisplayName "Mozilla thunderbird - IMAP SSL" -Service Any -Program $Program `
	-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
	-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 993 `
	-LocalUser $UserAccountsSDDL `
	-Description "Incoming mail server over SSL" | Format-Output

	New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
	-DisplayName "Mozilla thunderbird - IMAP" -Service Any -Program $Program `
	-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
	-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 143 `
	-LocalUser $UserAccountsSDDL `
	-Description "Incoming mail server" | Format-Output

	New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
	-DisplayName "Mozilla thunderbird - POP3 SSL" -Service Any -Program $Program `
	-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
	-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 110 `
	-LocalUser $UserAccountsSDDL `
	-Description "Incoming mail server over SSL" | Format-Output

	New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
	-DisplayName "Mozilla thunderbird - POP3" -Service Any -Program $Program `
	-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
	-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 995 `
	-LocalUser $UserAccountsSDDL `
	-Description "Incomming mail server" | Format-Output

	New-NetFirewallRule -Confirm:$Execute -Whatif:$Debug -ErrorAction $OnError -Platform $Platform `
	-DisplayName "Mozilla thunderbird - SMTP" -Service Any -Program $Program `
	-PolicyStore $PolicyStore -Enabled False -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
	-Direction $Direction -Protocol TCP -LocalAddress Any -RemoteAddress Internet4 -LocalPort Any -RemotePort 465 `
	-LocalUser $UserAccountsSDDL `
	-Description "Outgoing mail server" | Format-Output
}
