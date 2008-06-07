	FindProcDLL::FindProc "litestep.exe"
	Sleep 50
	StrCmp $R0 1 +1 +6
		StrCpy $4 "lsWasRunning"
		Push "$INSTDIR"
		Call un.KillLS
	GoTo +2
		StrCpy $4 "lsWasNotRunning"

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
	
	Call un.GetWindowsVersion
	Pop $R0

	StrCmp $R0 "9x" un9xShell

	;; Restore all the original values ;;
	
	; Make sure the old values are still in the registry. If they aren't and we would run this code
	; all the registry settings would be deleted, and we don't want that. Use a registry value that
	; is always defined for the check.
	
	ReadRegStr $0 HKLM "Software\${PRODUCT_NAME}\Installer\Uninstaller" "LMShell"
	StrCmp $0 "" removefiles
#		ReadRegStr $0 HKLM "Software\${PRODUCT_NAME}\Installer\Uninstaller" "LMBShell"
#		StrCmp $0 "" 0 +2
#			DeleteRegValue HKLM "Software\Microsoft\Windows NT\CurrentVersion\IniFileMapping\system.ini\boot" "Shell"
#		WriteRegStr HKLM "Software\Microsoft\Windows NT\CurrentVersion\IniFileMapping\system.ini\boot" "Shell" $0

		ReadRegDWORD $0 HKLM "Software\${PRODUCT_NAME}\Installer\Uninstaller" "CUDesktopProcess"
		StrCmp $0 "" 0 +3
			DeleteRegValue HKCU "Software\Microsoft\Windows\CurrentVersion\Explorer" "DesktopProcess"
			GoTo +2
		WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Explorer" "DesktopProcess" $0

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
	
		; Refresh window's ini files cashe
		WriteINIStr "system.ini" "" "" ""

		GoTo removefiles

	un9xShell:
	Call un.Shell9x

	removefiles:
	; It shouldn't be possible for ls to run at this point, but I have had some
	; weird errors, so I'm going to kill it one more time just to be sure
	KillProcDLL::KillProc "litestep.exe"

	;; Get regstrings to know where some of the stuff are
	ReadRegStr $whereprofiles HKLM "Software\${PRODUCT_NAME}\Installer" "ProfilesDir"
	ExpandEnvStrings $whereprofiles $whereprofiles

	Delete "$INSTDIR\${PRODUCT_NAME}.url"
	
	!ifdef PAGE_START_MENU
		!insertmacro MUI_STARTMENU_GETFOLDER "Application" $ICONS_GROUP

		Delete "$SMPROGRAMS\$ICONS_GROUP\Uninstall.lnk"
		Delete "$SMPROGRAMS\$ICONS_GROUP\Website.lnk"
		Delete "$SMPROGRAMS\$ICONS_GROUP\Set Explorer as Shell.lnk"
		Delete "$SMPROGRAMS\$ICONS_GROUP\Set LiteStep as Shell.lnk"
		Delete "$DESKTOP\Set Explorer as Shell.lnk"
		Delete "$DESKTOP\Set LiteStep as Shell.lnk"
	    
	    RMDir /REBOOTOK "$SMPROGRAMS\$ICONS_GROUP"
	
		; Set shell folders to all users, so we can delete the All users
		; stuff (it doesn't matter if it isn't there)
		SetShellVarContext all
		Delete "$SMPROGRAMS\$ICONS_GROUP\Uninstall.lnk"
		Delete "$SMPROGRAMS\$ICONS_GROUP\Website.lnk"
		Delete "$SMPROGRAMS\$ICONS_GROUP\Set Explorer as Shell.lnk"
		Delete "$SMPROGRAMS\$ICONS_GROUP\Set LiteStep as Shell.lnk"
		RMDir /REBOOTOK "$SMPROGRAMS\$ICONS_GROUP"
	!endif
	
	Delete "$DESKTOP\Set Explorer as Shell.lnk"
	Delete "$DESKTOP\Set LiteStep as Shell.lnk"


	; Clear all old errors so I can use the error checking for
	; checking that all files are deleted
	ClearErrors

	MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 $(UNINSTALL_THEMES) IDNO +2
	RMDir /r /REBOOTOK "$whereprofiles\themes"

	IfErrors 0 +3
		DetailPrint "$whereprofiles\themes could not be deleted"
		ClearErrors

	MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 $(UNINSTALL_PERSONAL) IDNO +2
	RMDir /r /REBOOTOK "$whereprofiles\personal\"

	IfErrors 0 +3
		DetailPrint "$whereprofiles\personal could not be deleted"
		ClearErrors

	RMDir /REBOOTOK "$whereprofiles" ; By not specifying '/r' this dir will only be deleted if it's completely empty 

	IfErrors 0 +3
		DetailPrint "$whereprofiles could not be deleted"
		ClearErrors

	IfFileExists "$INSTDIR\Profiles" 0 +2 ; An extra delete is needed if the default profiles dir is used
		RMDir /REBOOTOK "$INSTDIR\Profiles" 

	RMDir /r /REBOOTOK "$INSTDIR\modules\"

	IfErrors 0 +3
		DetailPrint "$INSTDIR\modules\ could not be deleted"
		ClearErrors

	; Now it's time to kill LS and bring back explorer. However, I can't
	; just do something like 'ExecShell "open" "explorer.exe"' because
	; that would make the Add/Remove Programs dialog freeze until
	; explorer was killed. It has this check that makes it wait for every
	; subprocess of the installer to quit before you can interact with it
	; again. So the way I make it work now is by using window's built in
	; feature to restart the shell whenever it's unexpectedly killed.
	
	; We only have to do all of this if Litestep was running in the first
	; place
	StrCmp $4 "lsWasRunning" +1 continueDeleting
		; This whole trick wont work if there are any explorer windows open
       	KillProcDLL::KillProc "explorer.exe"
       	Sleep 500

		; Make sure the "restart shell" feature is turned on. (Back up the
		; old value first)
		ReadRegDWORD $0 HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" "AutoRestartShell"
		WriteRegDWORD HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" "AutoRestartShell" 1

		; Make LS the shell
		FileOpen $1 "$INSTDIR\step.rc" w
		FileWrite $1 "LSSetAsShell"
		FileClose $1

		; Start Litestep as a "real" shell (LSSetAsShell forces LS to call SetShellWindow)
		Exec "$INSTDIR\litestep.exe"
		Sleep 2000 ; Give LS two seconds to start

		; Kill Litestep. This should make explorer start
		Push $INSTDIR
		Call un.KillLS

		; Change back the value of "AutoRestartShell"
		WriteRegDWORD HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" "AutoRestartShell" $0
		
		Sleep 2000 ; Give explorer some time to start


	; Now we can continue on with deleting the last LS files
	continueDeleting:
	
	!insertmacro UNINSTALL.LOG_UNINSTALL "$whereprofiles\themes"
	!insertmacro UNINSTALL.LOG_UNINSTALL "$INSTDIR\NLM"
	!insertmacro UNINSTALL.LOG_UNINSTALL "$INSTDIR\LOSI"
	!insertmacro UNINSTALL.LOG_UNINSTALL "$INSTDIR\utilities"
	!insertmacro UNINSTALL.LOG_UNINSTALL "$INSTDIR"
	!insertmacro UNINSTALL.LOG_END_UNINSTALL
    
    DeleteRegKey HKLM "Software\${PRODUCT_NAME}"

	SetAutoClose true

	; This code causes the Add/Remove Program dialog to freeze
	;FindProcDLL::FindProc "explorer.exe"
	;IntCmp $R0 1 +2 ; return code 1 means "Process was found"
	;Exec "explorer.exe"