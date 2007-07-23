Function setShellNT
    ; Check to see if this is the first time LS is installed on this computer
    ReadRegStr $0 HKLM "Software\${PRODUCT_NAME}\Installer\Uninstaller" "CUDesktopProcess"
    StrCmp $0 "" 0 setAsShell
        ; First I read the original settings, then I write those to another place in the reg, so I can
        ; restore the registry when uninstalling. Then I write the new settings to the registry.
        # ReadRegStr $0 HKLM "Software\Microsoft\Windows NT\CurrentVersion\IniFileMapping\system.ini\boot" "Shell"
        # WriteRegStr HKLM "Software\${PRODUCT_NAME}\Installer\Uninstaller" "Shell" $0
        # ReadRegDWORD $0 HKLM "Software\Microsoft\Windows\CurrentVersion\Explorer" "DesktopProcess"
        # WriteRegDWORD HKLM "Software\${PRODUCT_NAME}\Installer\Uninstaller" "LMDesktopProcess" $0
        # ReadRegDWORD $0 HKLM "Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "DesktopProcess"
        # WriteRegDWORD HKLM "Software\${PRODUCT_NAME}\Installer\Uninstaller" "LMADesktopProcess" $0
        # ReadRegStr $0 HKLM "Software\Microsoft\Windows\CurrentVersion\Explorer\BrowseNewProcess" "BrowseNewProcess"
        # WriteRegStr HKLM "Software\${PRODUCT_NAME}\Installer\Uninstaller" "LMBrowseNewProcess" $0
        # ReadRegDWORD $0 HKLM "Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Folder\DesktopProcess" "DefaultValue"
        # WriteRegDWORD HKLM "Software\${PRODUCT_NAME}\Installer\Uninstaller" "LMAFDPDefaultValue" $0
        ReadRegStr $0 HKLM "Software\Microsoft\Windows NT\CurrentVersion\Winlogon" "Shell"
        #WriteRegStr HKLM "Software\${PRODUCT_NAME}\Installer\Uninstaller" "LMShell" $0
        WriteRegStr HKLM "Software\${PRODUCT_NAME}\Installer\Uninstaller" "LMShell" "explorer.exe" # <-- ugly! Only temporary
        
        ReadRegDWORD $0 HKCU "Software\Microsoft\Windows\CurrentVersion\Explorer" "DesktopProcess"
        WriteRegDWORD HKLM "Software\${PRODUCT_NAME}\Installer\Uninstaller" "CUDesktopProcess" $0
        
        ReadRegDWORD $0 HKCU "Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "DesktopProcess"
        WriteRegDWORD HKLM "Software\${PRODUCT_NAME}\Installer\Uninstaller" "CUADesktopProcess" $0
        
        ReadRegStr $0 HKCU "Software\Microsoft\Windows\CurrentVersion\Explorer\BrowseNewProcess" "BrowseNewProcess"
        WriteRegStr HKLM "Software\${PRODUCT_NAME}\Installer\Uninstaller" "CUBrowseNewProcess" $0
        
        ReadRegStr $0 HKCU "Software\Microsoft\Windows NT\CurrentVersion\Winlogon" "Shell"
        WriteRegStr HKLM "Software\${PRODUCT_NAME}\Installer\Uninstaller" "CUShell" $0

	setAsShell:
    ; Stop explorer, the filemanager, from taking over as shell
    ;Local Machine Desktop Process
    # WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Explorer" "DesktopProcess" 1
    ;Local Machine Advanced Desktop Process
    # WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "DesktopProcess" 1
    ;Local Machine Browse New Process
    # WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Explorer\BrowseNewProcess" "BrowseNewProcess" "yes"
    ;Local Machine Advanced Folder Desktop Process Default Value
    # WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Folder\DesktopProcess" "DefaultValue" 1
    
    ;Current User Desktop Process
    WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Explorer" "DesktopProcess" 1
    ;Current User Advanced Desktop Process
    WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "DesktopProcess" 1
    ;Current User Browse New Process
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Explorer\BrowseNewProcess" "BrowseNewProcess" "yes"

    ReadINIStr $0 "$PLUGINSDIR\ioHowLS.ini" "Field 2" "State" ;Field 2 is All Users
    IntCmp $0 1 +3 0 0


	# 2006-09-03
	# I can't remember what all this code does, but it does look wrong to have ioWhereProfiles here
	# so I'm commenting that line out and writing a new line that reads from ioHowLS instead
	# ReadINIStr $0 "$PLUGINSDIR\ioWhereProfiles.ini" "Field 3" "State" ;Field 3 is Current User
	ReadINIStr $0 "$PLUGINSDIR\ioHowLS.ini" "Field 3" "State" ;Field 3 is Current User
    IntCmp $0 1 +2 end

    ; -- Set as shell for all users -- ;
#	WriteRegStr HKLM "Software\Microsoft\Windows NT\CurrentVersion\Winlogon" "Shell" "$INSTDIR\LiteStep.exe"
#
#   ; Delete any user specific shell if it is set
#   DeleteRegValue HKCU "Software\Microsoft\Windows NT\CurrentVersion\Winlogon" "Shell"
#   ClearErrors ; If the key didn't exist, and it wont in many cases, there'll be an
#               ; error that I want to get rid of
#
#   ; Tell Windows there might be a shell setting in HKCU
#   #WriteRegStr HKLM "Software\Microsoft\Windows NT\CurrentVersion\IniFileMapping\system.ini\boot" "Shell" "USR:Software\Microsoft\Windows NT\CurrentVersion\Winlogon"
#   WriteRegStr HKLM "Software\Microsoft\Windows NT\CurrentVersion\IniFileMapping\system.ini\boot" "Shell" "SYS:Microsoft\Windows NT\CurrentVersion\Winlogon"
#
#   ; Set shell folders to all users - only admins can do this
	SetShellVarContext all
#	GoTo end

    ; -- Set as shell for current user only -- ;
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