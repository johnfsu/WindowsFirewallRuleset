
#setup variables:
$Platform = "10.0+" #Windows 10 and above
$Group = "Microsoft Office"
$Profile = "Private, Public"
$Interface = "Wired, Wireless"
$PolicyStore = "localhost"
$OnError = "Stop"
$Deubg = $false

#First remove all existing rules matching group
Remove-NetFirewallRule -PolicyStore $PolicyStore -Group $Group -Direction Outbound -ErrorAction SilentlyContinue
Remove-NetFirewallRule -PolicyStore $PolicyStore -Group $Group -Direction Inbound -ErrorAction SilentlyContinue

#
# Microsoft office rules
#

New-NetFirewallRule -Whatif:$Deubg -ErrorAction $OnError -Platform $Platform `
-DisplayName "Access" -Program "%ProgramFiles%\Microsoft Office\root\Office16\MSACCESS.EXE" `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction Outbound -Protocol TCP -LocalAddress Any -RemoteAddress Internet -LocalPort Any -RemotePort 80, 443 `
-Description ""

New-NetFirewallRule -Whatif:$Deubg -ErrorAction $OnError -Platform $Platform `
-DisplayName "Click to Run" -Program "%ProgramFiles%\Common Files\microsoft shared\ClickToRun\OfficeClickToRun.exe" `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction Outbound -Protocol TCP -LocalAddress Any -RemoteAddress Internet -LocalPort Any -RemotePort 80, 443 `
-Description "Required for updates to work. Click-to-Run is an alternative to the traditional Windows Installer-based (MSI) method
of installing and updating Office, that utilizes streaming and virtualization technology
to reduce the time required to install Office and help run multiple versions of Office on the same computer."

New-NetFirewallRule -Whatif:$Deubg -ErrorAction $OnError -Platform $Platform `
-DisplayName "ClickC2RClient" -Program "%ProgramFiles%\Common Files\microsoft shared\ClickToRun\OfficeC2RClient.exe" `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction Outbound -Protocol TCP -LocalAddress Any -RemoteAddress Internet -LocalPort Any -RemotePort 443 `
-Description "Allows users to check for and install updates for Office on demand."

New-NetFirewallRule -Whatif:$Deubg -ErrorAction $OnError -Platform $Platform `
-DisplayName "Document Cache" -Program "%ProgramFiles%\Microsoft Office\root\Office16\MSOSYNC.EXE" `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction Outbound -Protocol TCP -LocalAddress Any -RemoteAddress Internet -LocalPort Any -RemotePort 443 `
-Description "The Office Document Cache is a concept used in Microsoft Office Upload Center
to give you a way to see the state of files you are uploading to a SharePoint server. "

New-NetFirewallRule -Whatif:$Deubg -ErrorAction $OnError -Platform $Platform `
-DisplayName "Excel" -Program "%ProgramFiles%\Microsoft Office\root\Office16\EXCEL.EXE" `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction Outbound -Protocol TCP -LocalAddress Any -RemoteAddress Internet -LocalPort Any -RemotePort 80, 443 `
-Description ""

New-NetFirewallRule -Whatif:$Deubg -ErrorAction $OnError -Platform $Platform `
-DisplayName "Excel (Mashup Container)" -Program "%ProgramFiles%\Microsoft Office\root\Office16\ADDINS\Microsoft Power Query for Excel Integrated\bin\Microsoft.Mashup.Container.NetFX40.exe" `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction Outbound -Protocol TCP -LocalAddress Any -RemoteAddress Internet -LocalPort Any -RemotePort 80, 443 `
-Description "Used to query data from web in excel."

New-NetFirewallRule -Whatif:$Deubg -ErrorAction $OnError -Platform $Platform `
-DisplayName "Help" -Program "%ProgramFiles%\Microsoft Office\root\Office16\CLVIEW.EXE" `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction Outbound -Protocol TCP -LocalAddress Any -RemoteAddress Internet -LocalPort Any -RemotePort 80, 443 `
-Description ""

New-NetFirewallRule -Whatif:$Deubg -ErrorAction $OnError -Platform $Platform `
-DisplayName "Outlook (HTTP/S)" -Program "%ProgramFiles%\Microsoft Office\root\Office16\OUTLOOK.EXE" `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction Outbound -Protocol TCP -LocalAddress Any -RemoteAddress Internet -LocalPort Any -RemotePort 80, 443 `
-Description ""

New-NetFirewallRule -Whatif:$Deubg -ErrorAction $OnError -Platform $Platform `
-DisplayName "Outlook (IMAP SSL)" -Program "%ProgramFiles%\Microsoft Office\root\Office16\OUTLOOK.EXE" `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction Outbound -Protocol TCP -LocalAddress Any -RemoteAddress Internet -LocalPort Any -RemotePort 993 `
-Description "Incoming mail server over SSL."

New-NetFirewallRule -Whatif:$Deubg -ErrorAction $OnError -Platform $Platform `
-DisplayName "Outlook (IMAP)" -Program "%ProgramFiles%\Microsoft Office\root\Office16\OUTLOOK.EXE" `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction Outbound -Protocol TCP -LocalAddress Any -RemoteAddress Internet -LocalPort Any -RemotePort 143 `
-Description "Incoming mail server."

New-NetFirewallRule -Whatif:$Deubg -ErrorAction $OnError -Platform $Platform `
-DisplayName "Outlook (POP3 SSL)" -Program "%ProgramFiles%\Microsoft Office\root\Office16\OUTLOOK.EXE" `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction Outbound -Protocol TCP -LocalAddress Any -RemoteAddress Internet -LocalPort Any -RemotePort 110 `
-Description "Incoming mail server over SSL."

New-NetFirewallRule -Whatif:$Deubg -ErrorAction $OnError -Platform $Platform `
-DisplayName "Outlook (POP3)" -Program "%ProgramFiles%\Microsoft Office\root\Office16\OUTLOOK.EXE" `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction Outbound -Protocol TCP -LocalAddress Any -RemoteAddress Internet -LocalPort Any -RemotePort 995 `
-Description "Incoming mail server."

New-NetFirewallRule -Whatif:$Deubg -ErrorAction $OnError -Platform $Platform `
-DisplayName "Outlook (SMTP)" -Program "%ProgramFiles%\Microsoft Office\root\Office16\OUTLOOK.EXE" `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction Outbound -Protocol TCP -LocalAddress Any -RemoteAddress Internet -LocalPort Any -RemotePort 25 `
-Description "Outgoing mail server."

New-NetFirewallRule -Whatif:$Deubg -ErrorAction $OnError -Platform $Platform `
-DisplayName "PowerPoint" -Program "%ProgramFiles%\Microsoft Office\root\Office16\POWERPNT.EXE" `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction Outbound -Protocol TCP -LocalAddress Any -RemoteAddress Internet -LocalPort Any -RemotePort 80, 443 `
-Description ""

New-NetFirewallRule -Whatif:$Deubg -ErrorAction $OnError -Platform $Platform `
-DisplayName "Project" -Program "%ProgramFiles%\Microsoft Office\root\Office16\WINPROJ.EXE" `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction Outbound -Protocol TCP -LocalAddress Any -RemoteAddress Internet -LocalPort Any -RemotePort 80, 443 `
-Description ""

New-NetFirewallRule -Whatif:$Deubg -ErrorAction $OnError -Platform $Platform `
-DisplayName "Publisher" -Program "%ProgramFiles%\Microsoft Office\root\Office16\MSPUB.EXE" `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction Outbound -Protocol TCP -LocalAddress Any -RemoteAddress Internet -LocalPort Any -RemotePort 80, 443 `
-Description ""

New-NetFirewallRule -Whatif:$Deubg -ErrorAction $OnError -Platform $Platform `
-DisplayName "sdxhelper" -Program "%ProgramFiles%\Microsoft Office\root\Office16\SDXHelper.exe" `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction Outbound -Protocol TCP -LocalAddress Any -RemoteAddress Internet -LocalPort Any -RemotePort 80, 443 `
-Description "this executable is used when later Office versions are installed in parallel with an earlier version so that they can peacefully coexist."

New-NetFirewallRule -Whatif:$Deubg -ErrorAction $OnError -Platform $Platform `
-DisplayName "Skype for business" -Program "%ProgramFiles%\Microsoft Office\root\Office16\lync.exe" `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction Outbound -Protocol TCP -LocalAddress Any -RemoteAddress Internet -LocalPort Any -RemotePort 80, 443, 33033 `
-Description "Skype for business, previously lync."

New-NetFirewallRule -Whatif:$Deubg -ErrorAction $OnError -Platform $Platform `
-DisplayName "Telemetry Agent" -Program "%ProgramFiles%\Microsoft Office\root\Office16\msoia.exe" `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction Outbound -Protocol TCP -LocalAddress Any -RemoteAddress Internet -LocalPort Any -RemotePort 443 `
-Description "The telemetry agent collects several types of telemetry data for Office.
https://docs.microsoft.com/en-us/deployoffice/compat/data-that-the-telemetry-agent-collects-in-office"

New-NetFirewallRule -Whatif:$Deubg -ErrorAction $OnError -Platform $Platform `
-DisplayName "Visio" -Program "%ProgramFiles%\Microsoft Office\root\Office16\VISIO.EXE" `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction Outbound -Protocol TCP -LocalAddress Any -RemoteAddress Internet -LocalPort Any -RemotePort 80, 443 `
-Description ""

New-NetFirewallRule -Whatif:$Deubg -ErrorAction $OnError -Platform $Platform `
-DisplayName "Word" -Program "%ProgramFiles%\Microsoft Office\root\Office16\WINWORD.EXE" `
-PolicyStore $PolicyStore -Enabled True -Action Allow -Group $Group -Profile $Profile -InterfaceType $Interface `
-Direction Outbound -Protocol TCP -LocalAddress Any -RemoteAddress Internet -LocalPort Any -RemotePort 80, 443 `
-Description ""
