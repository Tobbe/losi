	Call un.KillLS

    Call un.GetWindowsVersion
    Pop $R0

    StrCmp $R0 "9x" un9xShell

    ;; Restore all the original values ;;

	StrCmp "a" "b" 0 skip
	ReadRegStr $0 HKLM "Software\${PRODUCT_NAME}\Installer\Uninstaller" "Shell"
    StrCmp $0 "" 0 +2
        DeleteRegValue HKLM "Software\Microsoft\Windows NT\CurrentVersion\IniFileMapping\system.ini\boot" "Shell"
    WriteRegStr HKLM "Software\Microsoft\Windows NT\CurrentVersion\IniFileMapping\system.ini\boot" "Shell" $0

    ReadRegDWORD $0 HKLM "Software\${PRODUCT_NAME}\Installer\Uninstaller" "LMDesktopProcess"
    StrCmp $0 "" 0 +2
        DeleteRegValue HKLM "Software\Microsoft\Windows\CurrentVersion\Explorer" "DesktopProcess"
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Explorer" "DesktopProcess" $0

    ReadRegDWORD $0 HKLM "Software\${PRODUCT_NAME}\Installer\Uninstaller" "LMADesktopProcess"
    StrCmp $0 "" 0 +2
        DeleteRegValue HKLM "Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "DesktopProcess"
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "DesktopProcess" $0

    ReadRegStr $0 HKLM "Software\${PRODUCT_NAME}\Installer\Uninstaller" "LMBrowseNewProcess"
    StrCmp $0 "" 0 +2
        DeleteRegValue HKLM "Software\Microsoft\Windows\CurrentVersion\Explorer\BrowseNewProcess" "BrowseNewProcess"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Explorer\BrowseNewProcess" "BrowseNewProcess" $0

    ReadRegDWORD $0 HKLM "Software\${PRODUCT_NAME}\Installer\Uninstaller" "LMAFDPDefaultValue"
    StrCmp $0 "" 0 +2
        DeleteRegValue HKLM "Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Folder\DesktopProcess" "DefaultValue"
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Folder\DesktopProcess" "DefaultValue" $0

skip:

    ReadRegDWORD $0 HKLM "Software\${PRODUCT_NAME}\Installer\Uninstaller" "CUDesktopProcess"
    StrCmp $0 "" 0 +3
        DeleteRegValue HKCU "Software\Microsoft\Windows\CurrentVersion\Explorer" "DesktopProcess"
        GoTo +2
    WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Explorer" "DesktopProcess" $0

    ReadRegDWORD $0 HKLM "Software\${PRODUCT_NAME}\Installer\Uninstaller" "CUADesktopProcess"
    StrCmp $0 "" 0 +3
        DeleteRegValue HKCU "Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "DesktopProcess"
        GoTo +2
    WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "DesktopProcess" $0

    ReadRegStr $0 HKLM "Software\${PRODUCT_NAME}\Installer\Uninstaller" "CUBrowseNewProcess"
    StrCmp $0 "" 0 +3
        DeleteRegValue HKCU "Software\Microsoft\Windows\CurrentVersion\Explorer\BrowseNewProcess" "BrowseNewProcess"
        GoTo +2
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Explorer\BrowseNewProcess" "BrowseNewProcess" $0

    ReadRegStr $0 HKLM "Software\${PRODUCT_NAME}\Installer\Uninstaller" "LMShell"
    StrCmp $0 "" 0 +3
        DeleteRegValue HKLM "Software\Microsoft\Windows NT\CurrentVersion\Winlogon" "Shell"
        GoTo +2
    WriteRegStr HKLM "Software\Microsoft\Windows NT\CurrentVersion\Winlogon" "Shell" $0

    ReadRegStr $0 HKLM "Software\${PRODUCT_NAME}\Installer\Uninstaller" "CUShell"
    StrCmp $0 "" 0 +3
        DeleteRegValue HKCU "Software\Microsoft\Windows NT\CurrentVersion\Winlogon" "Shell"
        GoTo +2
    WriteRegStr HKCU "Software\Microsoft\Windows NT\CurrentVersion\Winlogon" "Shell" $0

    GoTo removefiles

    un9xShell:
    Call un.Shell9x

    removefiles:

    ;; Get regstrings to know where some of the stuff are
    ReadRegStr $whereprofiles HKLM "Software\${PRODUCT_NAME}\Installer" "ProfilesDir"

    !insertmacro MUI_STARTMENU_GETFOLDER "Application" $ICONS_GROUP

    Delete "$SMPROGRAMS\$ICONS_GROUP\Uninstall.lnk"
    Delete "$SMPROGRAMS\$ICONS_GROUP\Website.lnk"
    Delete "$SMPROGRAMS\$ICONS_GROUP\Set Explorer as Shell.lnk"
    Delete "$SMPROGRAMS\$ICONS_GROUP\Set LiteStep as Shell.lnk"
    Delete "$DESKTOP\Set Explorer as Shell.lnk"
    Delete "$DESKTOP\Set LiteStep as Shell.lnk"
    ;Delete "$DESKTOP\${PRODUCT_NAME}.lnk"
    ;Delete "$SMPROGRAMS\$ICONS_GROUP\${PRODUCT_NAME}.lnk"

    ; Set shell folders to all users, so we can delete the All users
	; stuff (it doesn't matter if it isn't there)
    SetShellVarContext all
    Delete "$SMPROGRAMS\$ICONS_GROUP\Uninstall.lnk"
    Delete "$SMPROGRAMS\$ICONS_GROUP\Website.lnk"
    Delete "$SMPROGRAMS\$ICONS_GROUP\Set Explorer as Shell.lnk"
    Delete "$SMPROGRAMS\$ICONS_GROUP\Set LiteStep as Shell.lnk"
    Delete "$DESKTOP\Set Explorer as Shell.lnk"
    Delete "$DESKTOP\Set LiteStep as Shell.lnk"

	RMDir "$SMPROGRAMS\$ICONS_GROUP"
	MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 $(UNINSTALL_THEMES) IDNO +2
    RMDir /r /REBOOTOK "$whereprofiles\themes"
    MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 $(UNINSTALL_PERSONAL) IDNO +2
    RMDir /r /REBOOTOK "$whereprofiles\personal"
    RMDir    /REBOOTOK "$whereprofiles"
    RMDir /r /REBOOTOK "$INSTDIR\modules\"
    RMDir /r /REBOOTOK "$INSTDIR\NLM\"
    RMDir /r /REBOOTOK "$INSTDIR\losi\"
    RMDir /r /REBOOTOK "$INSTDIR\utilities\"
    RMDir /r /REBOOTOK "$INSTDIR\modules\"

    Delete /REBOOTOK "$INSTDIR\*.*"

    DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
    DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
    
    ; Unregister filetypes
    Push ".lsz"
	Push "LiteStep.lsz"
	call un.DeAssociateFile
	
	Push ".rc"
	Push "LiteStep.rc"
	call un.DeAssociateFile
	
	Push ".mz"
	Push "LiteStep.mz"
	call un.DeAssociateFile
	
	Push ".lua"
	Push "LiteStep.lua"
	call un.DeAssociateFile

    SetRebootFlag true

    SetAutoClose true

    FindProcDLL::FindProc "explorer.exe"
    StrCmp $R0 "" 1 +2
    ExecShell open "explorer.exe"