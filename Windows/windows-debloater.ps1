ECHO "debloating microsoft windows`n"

Get-AppxPackage -allusers *3dviewer* | Remove-AppxPackage -allusers
Get-AppxPackage -allusers *3dbuilder* | Remove-AppxPackage -allusers
Get-AppxPackage -allusers *sway* | Remove-AppxPackage -allusers
Get-AppxPackage -allusers *communicationsapps* | Remove-AppxPackage -allusers
Get-AppxPackage -allusers *office* | Remove-AppxPackage -allusers
Get-AppxPackage -allusers *bing* | Remove-AppxPackage -allusers
Get-AppxPackage -allusers *zune* | Remove-AppxPackage -allusers
Get-AppxPackage -allusers *help* | Remove-AppxPackage -allusers
Get-AppxPackage -allusers *skype* | Remove-AppxPackage -allusers
Get-AppxPackage -allusers *maps* | Remove-AppxPackage -allusers
Get-AppxPackage -allusers *solitaire* | Remove-AppxPackage -allusers
Get-AppxPackage -allusers *onenote* | Remove-AppxPackage -allusers
Get-AppxPackage -allusers *people* | Remove-AppxPackage -allusers
Get-AppxPackage -allusers *phone* | Remove-AppxPackage -allusers
Get-AppxPackage -allusers *soundrec* | Remove-AppxPackage -allusers
Get-AppxPackage -allusers *spotify* | Remove-AppxPackage -allusers
Get-AppxPackage -allusers *feedback* | Remove-AppxPackage -allusers
Get-AppxPackage -allusers *Xbox* | Remove-AppxPackage -allusers
Get-AppxPackage -allusers *MixedReality* | Remove-AppxPackage -allusers
Get-AppxPackage -allusers *Getstarted* | Remove-AppxPackage -allusers
Get-AppxPackage -allusers *purchase* | Remove-AppxPackage -allusers
Get-AppxPackage -allusers *wallet* | Remove-AppxPackage -allusers
Get-AppxPackage -allusers *alarm* | Remove-AppxPackage -allusers
Get-AppxPackage -allusers *messaging* | Remove-AppxPackage -allusers
Get-AppxPackage -allusers *networkspeedtest* | Remove-AppxPackage -allusers
Get-AppxPackage -allusers *oneconnect* | Remove-AppxPackage -allusers
Get-AppxPackage -allusers *print3d* | Remove-AppxPackage -allusers
Get-AppxPackage -allusers *windowscamera* | Remove-AppxPackage -allusers
Get-AppxPackage -allusers *windowsphone* | Remove-AppxPackage -allusers
Get-AppxPackage -allusers *EclipseManager* | Remove-AppxPackage -allusers
Get-AppxPackage -allusers *ActiproSoftwareLLC* | Remove-AppxPackage -allusers
Get-AppxPackage -allusers *AdobeSystemsIncorporated.AdobePhotoshopExpress* | Remove-AppxPackage -allusers
Get-AppxPackage -allusers *Duolingo-LearnLanguagesforFree* | Remove-AppxPackage -allusers
Get-AppxPackage -allusers *PandoraMediaInc* | Remove-AppxPackage -allusers
Get-AppxPackage -allusers *CandyCrush* | Remove-AppxPackage -allusers
Get-AppxPackage -allusers *Wunderlist* | Remove-AppxPackage -allusers
Get-AppxPackage -allusers *Flipboard* | Remove-AppxPackage -allusers
Get-AppxPackage -allusers *Twitter* | Remove-AppxPackage -allusers
Get-AppxPackage -allusers *Facebook* | Remove-AppxPackage -allusers
Get-AppxPackage -allusers *Microsoft.Advertising* | Remove-AppxPackage -allusers
Get-AppxPackage -allusers *Microsoft.WhiteBoard* | Remove-AppxPackage -allusers
Get-AppxPackage -allusers Microsoft.549981C3F5F10 | Remove-AppxPackage -allusers
Get-AppxPackage -allusers Microsoft.Windows.CloudExperienceHost | Remove-AppxPackage -allusers
Get-AppxPackage -allusers Microsoft.Windows.PeopleExperienceHost | Remove-AppxPackage -allusers
Get-AppxPackage -allusers Microsoft.Windows.ContentDeliveryManager | Remove-AppxPackage -allusers
Get-AppxPackage -allusers Microsoft.Windows.WindowsTerminal | Remove-AppxPackage -allusers
Get-AppxPackage -allusers Microsoft.Windows.StorePurchaseApp | Remove-AppxPackage -allusers
Get-AppxPackage -allusers Microsoft.Windows.GammingApp | Remove-AppxPackage -allusers

ECHO "uninstalling packages`n"

Get-WindowsPackage -Online -Packagename *Microsoft-Windows-UserExperience-Desktop-Package* | Remove-WindowsPackage -Online
Get-WindowsPackage -Online -Packagename *LanguageFeatures-TextToSpeech* | Remove-WindowsPackage -Online
Get-WindowsPackage -Online -Packagename *LanguageFeatures-Speech* | Remove-WindowsPackage -Online
Get-WindowsPackage -Online -Packagename *LanguageFeatures-OCR* | Remove-WindowsPackage -Online
Get-WindowsPackage -Online -Packagename *LanguageFeatures-handwriting* | Remove-WindowsPackage -Online

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