!ifndef WRITE_UNINSTALLER
!define WRITE_UNINSTALLER
	!include uninstShell9x.nsh
	!include GetWindowsVersion.nsh
	!include unStartExplorer.nsh
	
	!ifdef PAGE_FILE_ASSOC
		!include RegisterExtension.nsh
	!endif

	!insertmacro MUI_UNPAGE_INSTFILES
	
	Section -post
    	WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "" "$INSTDIR\litestep.exe"
    	WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
    	WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "InstallLocation" "$INSTDIR"
    	WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "${UNINST_EXE}"
    	WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$INSTDIR\litestep.exe"
    	WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
    	WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
    	WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
    	WriteRegDWORD ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "NoModify" 1
    	WriteRegDWORD ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "NoRepair" 1
	SectionEnd
	
	Section Uninstall
		Call un.GetWindowsVersion
		Pop $R0
	
		${If} $R0 == "9x"
			Call un.Shell9x
		${Else}
			;; Restore all the original values ;;
			
			; Make sure the old values are still in the registry. If they aren't and we would run this code
			; all the registry settings would be deleted, and we don't want that. Use a registry value that
			; is always defined for the check.
			
			ReadRegStr $0 HKLM "Software\${PRODUCT_NAME}\Installer\Uninstaller" "LMShell"
			${IfNot} $0 == ""
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
			
				; Refresh window's ini files cache
				WriteINIStr "system.ini" "" "" ""
			${EndIf}
		${EndIf}
		
		FindProcDLL::FindProc "litestep.exe"
		Sleep 50
		${If} $R0 == 1
			StrCpy $4 "lsWasRunning"
			Push "$INSTDIR"
			Call un.KillLS
		${Else}
			StrCpy $4 "lsWasNotRunning"
		${EndIf}
		
		; It shouldn't be possible for ls to run at this point, but I have had some
		; weird errors, so I'm going to kill it one more time just to be sure
		KillProcDLL::KillProc "litestep.exe"
		
		; Now it's time to kill LS and bring back explorer.
		
		; We only have to do all of this if Litestep was running in the first
		; place
		${If} $4 == "lsWasRunning"
			DetailPrint "Will now try to start explorer, this will take a few seconds."
			SetDetailsPrint none
			Call un.StartExplorer
			SetDetailsPrint both
			DetailPrint "Continue uninstallation"
		${EndIf}
		
		!ifdef PAGE_FILE_ASSOC
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
		!endif
	
		;; Get regstrings to know where some of the stuff are
		ReadRegStr $whereprofiles HKLM "Software\${PRODUCT_NAME}\Installer" "ProfilesDir"
		ExpandEnvStrings $whereprofiles $whereprofiles
	
		Delete "$INSTDIR\${PRODUCT_NAME}.url"	
		Delete "$DESKTOP\Set Explorer as Shell.lnk"
		Delete "$DESKTOP\Set LiteStep as Shell.lnk"
		
		!ifdef PAGE_START_MENU
			!insertmacro MUI_STARTMENU_GETFOLDER "Application" $ICONS_GROUP
	
			Delete "$SMPROGRAMS\$ICONS_GROUP\Uninstall.lnk"
			Delete "$SMPROGRAMS\$ICONS_GROUP\Website.lnk"
			Delete "$SMPROGRAMS\$ICONS_GROUP\Set Explorer as Shell.lnk"
			Delete "$SMPROGRAMS\$ICONS_GROUP\Set LiteStep as Shell.lnk"
		    
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
		
		
		; Time to check if explorer has started. If it hasn't we need to try 
		; to make it start
		FindProcDLL::FindProc "explorer.exe"
		Sleep 50
		${If} $R0 != 1
			; Explorer still isn't running, try to start it again.
			DetailPrint "Trying to start explorer again"
			Call un.StartExplorer
		${EndIf}
	
	
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

	    DeleteRegKey HKLM "Software\${PRODUCT_NAME}"
	    
	    DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
		DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
		
		!insertmacro UNINSTALL.LOG_UNINSTALL "$whereprofiles\themes"
		!insertmacro UNINSTALL.LOG_UNINSTALL "$INSTDIR\NLM"
		!insertmacro UNINSTALL.LOG_UNINSTALL "$INSTDIR\LOSI"
		!insertmacro UNINSTALL.LOG_UNINSTALL "$INSTDIR\utilities"
		!insertmacro UNINSTALL.LOG_UNINSTALL "$INSTDIR"
		!insertmacro UNINSTALL.LOG_END_UNINSTALL

		; Time to check if explorer has started for the last time. Now
		; we *really* have to make sure it starts
		FindProcDLL::FindProc "explorer.exe"
		Sleep 50
		${If} $R0 != 1
			DetailPrint ""
			DetailPrint ""
			DetailPrint ""
			DetailPrint ""
			DetailPrint ""
			DetailPrint "It seems explorer has a hard time starting."
			DetailPrint "This is the last try to make it start."
			DetailPrint ""
			DetailPrint "Let explorer start. Then it's going to be killed"
			Call un.StartExplorerByKillingExplorer
		${EndIf}

		; This code causes the Add/Remove Program dialog to freeze
		;FindProcDLL::FindProc "explorer.exe"
		;IntCmp $R0 1 +2 ; return code 1 means "Process was found"
		;Exec "explorer.exe"
	SectionEnd
!endif