# 2007-12-23
# To do all this without rebooting or even logging off, this is what needs to be done:
#   Change the Shell value in IniFileMappings, something like this:
#       WriteRegStr HKLM "Software\Microsoft\Windows NT\CurrentVersion\IniFileMapping\system.ini\boot" "Shell" "USR:Software\Microsoft\Windows NT\CurrentVersion\Winlogon"
#   Refresh window's ini files cashe, something like this:
#       WritePrivateProfileString(NULL, NULL, NULL, "system.ini") [C code]
#       WriteINIStr "system.ini"     <-- might work
#   Change to the new shell, something like this:
#       WritePrivateProfileString("boot", "shell", <path to shell>, "system.ini") [C code]
#       WriteINIStr "system.ini" "boot" "shell" <path to shell>    <-- probably works

Function setShellNT
    ; Check to see if this is the first time LS is installed on this computer
    ReadRegStr $0 HKLM "Software\${PRODUCT_NAME}\Installer\Uninstaller" "CUDesktopProcess"
    StrCmp $0 "" 0 setAsShell
        ReadRegStr $0 HKLM "Software\Microsoft\Windows NT\CurrentVersion\Winlogon" "Shell"
        #WriteRegStr HKLM "Software\${PRODUCT_NAME}\Installer\Uninstaller" "LMShell" $0
        WriteRegStr HKLM "Software\${PRODUCT_NAME}\Installer\Uninstaller" "LMShell" "explorer.exe" # <-- ugly! Only temporary
																								   # I want to reset to the
																								   # shell the user had before
																								   # he/she installed LS
        
        ReadRegDWORD $0 HKCU "Software\Microsoft\Windows\CurrentVersion\Explorer" "DesktopProcess"
        WriteRegDWORD HKLM "Software\${PRODUCT_NAME}\Installer\Uninstaller" "CUDesktopProcess" $0
        
        ReadRegDWORD $0 HKCU "Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "DesktopProcess"
        WriteRegDWORD HKLM "Software\${PRODUCT_NAME}\Installer\Uninstaller" "CUADesktopProcess" $0
        
        ReadRegStr $0 HKCU "Software\Microsoft\Windows\CurrentVersion\Explorer\BrowseNewProcess" "BrowseNewProcess"
        WriteRegStr HKLM "Software\${PRODUCT_NAME}\Installer\Uninstaller" "CUBrowseNewProcess" $0
        
        ReadRegStr $0 HKCU "Software\Microsoft\Windows NT\CurrentVersion\Winlogon" "Shell"
        WriteRegStr HKLM "Software\${PRODUCT_NAME}\Installer\Uninstaller" "CUShell" $0

	setAsShell:
    ;Current User Desktop Process
    WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Explorer" "DesktopProcess" 1
    ;Current User Advanced Desktop Process
    WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "DesktopProcess" 1
    ;Current User Browse New Process
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Explorer\BrowseNewProcess" "BrowseNewProcess" "yes"

    ReadINIStr $0 "$PLUGINSDIR\ioHowLS.ini" "Field 2" "State" ;Field 2 is All Users
    IntCmp $0 1 +3 0 0

	ReadINIStr $0 "$PLUGINSDIR\ioHowLS.ini" "Field 3" "State" ;Field 3 is Current User
    IntCmp $0 1 +2 end

	; Set shell folders to all users - only admins can do this
	SetShellVarContext all

    ; -- Set as shell -- ;
    WriteRegStr HKCU "Software\Microsoft\Windows NT\CurrentVersion\Winlogon" "Shell" "$INSTDIR\LiteStep.exe"
    
    ; See if we're going to have to change anything in HKLM
    ReadRegStr $0 HKLM "Software\Microsoft\Windows NT\CurrentVersion\IniFileMapping\system.ini\boot" "Shell"
    StrCmp $0 "USR:Software\Microsoft\Windows NT\CurrentVersion\Winlogon" +3
        SetRebootFlag true
        GoTo +2

		StrCpy $LogoffFlag "true"
    
    ; Tell Windows there might be a shell setting in HKCU
    WriteRegStr HKLM "Software\Microsoft\Windows NT\CurrentVersion\IniFileMapping\system.ini\boot" "Shell" "USR:Software\Microsoft\Windows NT\CurrentVersion\Winlogon"
end:
FunctionEnd