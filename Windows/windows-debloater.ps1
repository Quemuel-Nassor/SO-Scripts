#command to enable powershell script execution
#Set-ExecutionPolicy -ExecutionPolicy unrestricted

ECHO "debloating microsoft windows`n"

Get-AppxPackage -allusers *3dviewer* | Remove-AppxPackage
Get-AppxPackage -allusers *3dbuilder* | Remove-AppxPackage
Get-AppxPackage -allusers *sway* | Remove-AppxPackage
Get-AppxPackage -allusers *communicationsapps* | Remove-AppxPackage
Get-AppxPackage -allusers *office* | Remove-AppxPackage
Get-AppxPackage -allusers *bing* | Remove-AppxPackage
Get-AppxPackage -allusers *zune* | Remove-AppxPackage
Get-AppxPackage -allusers *help* | Remove-AppxPackage
Get-AppxPackage -allusers *skype* | Remove-AppxPackage
Get-AppxPackage -allusers *maps* | Remove-AppxPackage
Get-AppxPackage -allusers *solitaire* | Remove-AppxPackage
Get-AppxPackage -allusers *onenote* | Remove-AppxPackage
Get-AppxPackage -allusers *people* | Remove-AppxPackage
Get-AppxPackage -allusers *phone* | Remove-AppxPackage
Get-AppxPackage -allusers *soundrec* | Remove-AppxPackage
Get-AppxPackage -allusers *spotify* | Remove-AppxPackage
Get-AppxPackage -allusers *feedback* | Remove-AppxPackage
Get-AppxPackage -allusers *Xbox* | Remove-AppxPackage
Get-AppxPackage -allusers *MixedReality* | Remove-AppxPackage
Get-AppxPackage -allusers *Getstarted* | Remove-AppxPackage
Get-AppxPackage -allusers *purchase* | Remove-AppxPackage
Get-AppxPackage -allusers *wallet* | Remove-AppxPackage
Get-AppxPackage -allusers *alarm* | Remove-AppxPackage
Get-AppxPackage -allusers *messaging* | Remove-AppxPackage
Get-AppxPackage -allusers *networkspeedtest* | Remove-AppxPackage
Get-AppxPackage -allusers *oneconnect* | Remove-AppxPackage
Get-AppxPackage -allusers *print3d* | Remove-AppxPackage
Get-AppxPackage -allusers *windowscamera* | Remove-AppxPackage
Get-AppxPackage -allusers *windowsphone* | Remove-AppxPackage
Get-AppxPackage -allusers *EclipseManager* | Remove-AppxPackage
Get-AppxPackage -allusers *ActiproSoftwareLLC* | Remove-AppxPackage
Get-AppxPackage -allusers *AdobeSystemsIncorporated.AdobePhotoshopExpress* | Remove-AppxPackage
Get-AppxPackage -allusers *Duolingo-LearnLanguagesforFree* | Remove-AppxPackage
Get-AppxPackage -allusers *PandoraMediaInc* | Remove-AppxPackage
Get-AppxPackage -allusers *CandyCrush* | Remove-AppxPackage
Get-AppxPackage -allusers *Wunderlist* | Remove-AppxPackage
Get-AppxPackage -allusers *Flipboard* | Remove-AppxPackage
Get-AppxPackage -allusers *Twitter* | Remove-AppxPackage
Get-AppxPackage -allusers *Facebook* | Remove-AppxPackage
Get-AppxPackage -allusers *Whatsapp* | Remove-AppxPackage
Get-AppxPackage -allusers *Linkedin* | Remove-AppxPackage
Get-AppxPackage -allusers *Microsoft.Advertising* | Remove-AppxPackage
Get-AppxPackage -allusers *Microsoft.WhiteBoard* | Remove-AppxPackage
Get-AppxPackage -allusers Microsoft.549981C3F5F10 | Remove-AppxPackage
Get-AppxPackage -allusers Microsoft.Windows.CloudExperienceHost | Remove-AppxPackage
Get-AppxPackage -allusers Microsoft.Windows.PeopleExperienceHost | Remove-AppxPackage
Get-AppxPackage -allusers Microsoft.Windows.ContentDeliveryManager | Remove-AppxPackage
Get-AppxPackage -allusers Microsoft.Windows.WindowsTerminal | Remove-AppxPackage
Get-AppxPackage -allusers Microsoft.Windows.StorePurchaseApp | Remove-AppxPackage
Get-AppxPackage -allusers Microsoft.Windows.GammingApp | Remove-AppxPackage

ECHO "uninstalling packages`n"

Get-WindowsPackage -Online -Packagename *Microsoft-Windows-UserExperience-Desktop-Package* | Remove-WindowsPackage -Online -NoRestart
Get-WindowsPackage -Online -Packagename *LanguageFeatures-TextToSpeech* | Remove-WindowsPackage -Online -NoRestart
Get-WindowsPackage -Online -Packagename *LanguageFeatures-Speech* | Remove-WindowsPackage -Online -NoRestart
Get-WindowsPackage -Online -Packagename *LanguageFeatures-OCR* | Remove-WindowsPackage -Online -NoRestart
Get-WindowsPackage -Online -Packagename *LanguageFeatures-handwriting* | Remove-WindowsPackage -Online -NoRestart

ECHO "disabling background apps`n"

REG ADD HKLM\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications /V GlobalUserDisabled /T REG_DWORD /D 1 /F

ECHO "disabling fast startup and hibernation`n"

REG ADD HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power /V HiberbootEnabled /T REG_DWORD /D 0 /F
POWERCFG /H OFF

ECHO "compacting windows installation`n"

Compact.exe /CompactOS:always

ECHO "disabling startup apps`n"

#REG DELETE HKLM\Software\Microsoft\Windows\CurrentVersion\Run

ECHO "disabling unrequired services`n"

#windows search indexer
# Set-Service -Name "WSearch" -Status stopped -StartupType disabled 

#superfetch, improves apps performance
Set-Service -Name "SysMain" -Status stopped -StartupType disabled 

#microsoft store user service
Set-Service -Name "UserDataSvc_2d922" -Status stopped -StartupType disabled 

#DVR broadcast
Set-Service -Name "BcastDVRUserService" -Status stopped -StartupType disabled 

#sync mail, calendar, etc..
Set-Service -Name "OneSyncSvc" -Status stopped -StartupType disabled 

#windows insider service
Set-Service -Name "wisvc" -Status stopped -StartupType disabled 

ECHO "for more visit link bellow"
ECHO "https://github.com/Sycnex/Windows10Debloater/tree/master`n"

read-host “Press ENTER to continue...”
