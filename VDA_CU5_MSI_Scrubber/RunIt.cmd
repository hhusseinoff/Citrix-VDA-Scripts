set scriptdir=%~dp0

REM #### Killing PortICA
powershell.exe -executionpolicy bypass -command "$svcpid = (get-WmiObject win32_service | Where name -eq 'porticaservice').processID; & taskkill.exe /PID $svcpid /F"


REM #### Citrix AppDisk VDA Plugin
MsiExec.exe /X{14A8E72B-ED1F-4E31-992B-30FD832EE5E9} REBOOT=ReallySuppress /qn
ping -n 10 localhost

REM #### Citrix Diagnostics Facility
MsiExec.exe /X{BE4A9835-C3E7-45DD-9059-4B692F254D16} REBOOT=ReallySuppress /qn
ping -n 10 localhost

REM #### Citrix Identity Assertion VDA Plugin
MsiExec.exe /X{F9237670-B044-4EFE-BE8A-491C5B6B8ABC} REBOOT=ReallySuppress /qn
ping -n 10 localhost

REM #### Group Policy Client-Side Extension 7.24.5000.0
MsiExec.exe /X{DEE0A456-35DD-41CD-91D5-7FC9C98320FB} REBOOT=ReallySuppress /qn
ping -n 10 localhost

REM #### Citrix Director VDA Plugin
MsiExec.exe /X{34F7A530-9359-4C46-AE6C-FAA3883EE6E9} REBOOT=ReallySuppress /qn
ping -n 10 localhost

REM #### Citrix Start Menu Disconnect Button
MsiExec.exe /X{BC6EE8CF-832C-4E09-B45E-386F32E12F66} REBOOT=ReallySuppress /qn
ping -n 10 localhost

REM #### Citrix HDX WS x64
MsiExec.exe /X{2D3EDA60-9E70-4D79-A96B-BB2A050FD5A1} REBOOT=ReallySuppress /qn
ping -n 10 localhost

REM #### Machine Management WMI Provider
MsiExec.exe /X{557876FC-600B-490D-94D6-A05CC2C1A6C2} REBOOT=ReallySuppress /qn
ping -n 10 localhost

REM #### Citrix Profile management
MsiExec.exe /X{F44580DA-34D3-412C-9522-663DDCD73135} REBOOT=ReallySuppress /qn
ping -n 10 localhost

REM ####  Citrix Telemetry Service - x64
MsiExec.exe /X{70B0C46F-4EB5-4192-B831-6F85B4C2457B} REBOOT=ReallySuppress /qn
ping -n 10 localhost

REM ####  UpmVDAPlugin
MsiExec.exe /X{60114FA9-BCCE-431A-B395-7D4656ADA3D7} REBOOT=ReallySuppress /qn
ping -n 10 localhost

REM ####  Citrix Universal Print Client
MsiExec.exe /X{7D50D350-6353-45D9-9AD3-7D9A4716C828} REBOOT=ReallySuppress /qn
ping -n 10 localhost

REM ####  Citrix Monitor Service VDA Plugin
MsiExec.exe /X{56CD28AF-E7D5-4918-BB65-5940768DF4FF} REBOOT=ReallySuppress /qn
ping -n 10 localhost

REM ####  Citrix WMI Proxy Plugin
MsiExec.exe /X{F1F0B614-A6E1-4B3B-88C8-35FF07BE40D7} REBOOT=ReallySuppress /qn
ping -n 10 localhost

REM #### Killing PortICA
powershell.exe -executionpolicy bypass -command "$svcpid = (get-WmiObject win32_service | Where name -eq 'porticaservice').processID; & taskkill.exe /PID $svcpid /F"

REM #### Citrix Browser Content Redirection
MsiExec.exe /X{4D54D5F1-3219-4EBF-8364-B7941FC2CB04} REBOOT=ReallySuppress /qn
ping -n 10 localhost


REM #### Citrix Virtual Desktop Agent - x64
MsiExec.exe /X{7F749D26-EEBA-4844-A82D-383CEA1A44E8} REBOOT=ReallySuppress /qn
ping -n 10 localhost


REM #### VDA Uninstall - last action

"C:\Program Files\Citrix\XenDesktopVDASetup\XenDesktopVDASetup.exe" /removeall /quiet /noreboot

ping -n 10 localhost

reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Citrix Virtual Desktop Agent"

if %ERRORLEVEL% EQU 0 goto END

if %ERRORLEVEL% EQU 1 goto FAILED

:END
echo Success
EXIT /B 0

:FAILED
echo Failed
EXIT /B 1
