!ifndef PAGE_PREVIOUS_INSTALL
!define PAGE_PREVIOUS_INSTALL
	!include LogicLib.nsh

	Page custom ioPrevInst ioPrevInstLeave

	Function ioPrevInst
		Push $R0
		Push $R1
		Push $R2
		Push $R3
		Push $R4
		Push $R5

		Call DetectPreviousInstall
		Pop $R0

		${If} $R0 == "detected"
			WriteINIStr "$PLUGINSDIR\ioPreviousInstall.ini" "Field 1" "Text" "$(PREVINST_TEXT)"
			WriteINIStr "$PLUGINSDIR\ioPreviousInstall.ini" "Field 2" "Text" "$(PREVINST_CHECKBOX)"
	
			!insertmacro MUI_HEADER_TEXT "$(TEXT_IO_TITLE_PREVINST)" "$(TEXT_IO_PREVINST)"
			!insertmacro INSTALLOPTIONS_INITDIALOG "ioPreviousInstall.ini"
			GetDlgItem $R1 $HWNDPARENT 1
			EnableWindow $R1 0
			StrCpy $abortWarning "false"
			!insertmacro INSTALLOPTIONS_SHOW
		${EndIf}

		Pop $R5
		Pop $R4
		Pop $R3
		Pop $R2
		Pop $R1
		Pop $R0
	FunctionEnd
	
	Function ioPrevInstLeave
		Push $R0
		Push $R1

		ReadINIStr $R0 "$PLUGINSDIR\ioPreviousInstall.ini" "Settings" "State"
		ReadINIStr $R1 "$PLUGINSDIR\ioPreviousInstall.ini" "Field 2" "State"
		${If} $R0 != 0
			GetDlgItem $R0 $HWNDPARENT 1

			${If} $R1 == 1
				StrCpy $abortWarning "true"
				EnableWindow $R0 1
			${Else}
				StrCpy $abortWarning "false"
				EnableWindow $R0 0
			${EndIf}

			Abort
		${EndIf}

		Pop $R1
		Pop $R0
	FunctionEnd

	Function DetectPreviousInstall
		Push $R0
		Push $R1
		Push $R2
		
		ReadRegStr $R2 HKCU "Software\LiteStep\Installer" "LiteStepDir"
		IfErrors 0 +2
		ReadRegStr $R2 HKLM "Software\LOSI\Installer" "LitestepDir"
		ClearErrors

		${If} $R2 == $INSTDIR
			StrCpy $R0 "upgrade"
			GoTo PrevInstDetectionEnd
		${EndIf}

		; remove trailing backslash if there is one
		StrCpy $R1 $R2 1 -1
		StrCmp $R1 "\" 0 +2
		StrCpy $R2 $R2 -1

		${If} $R2 == $INSTDIR
			StrCpy $R0 "upgrade"
			GoTo PrevInstDetectionEnd
		${EndIf}

		StrCpy $R2 "$R2\litestep.exe"
		IfFileExists $R2 PrevInstDetected

		FindProcDLL::FindProc "litestep.exe"
    	StrCmp $R2 1 PrevInstDetected
    	
    	; Check the most common installation directories
    	IfFileExists "C:\LiteStep\litestep.exe" PrevInstDetected
    	IfFileExists "$PROGRAMFILES\LiteStep\litestep.exe" PrevInstDetected
    	
    	; For Win9x
    	ReadINIStr $R2 "$WINDIR\system.ini" "boot" "shell"
    	StrCpy $R2 $R2 "" -12 ; Copy the last twelve characters
    	${If} $R2 == "litestep.exe"
    		GoTo PrevInstDetected
    	${EndIf}

		StrCpy $R0 "notdetected"
		GoTo PrevInstDetectionEnd

		PrevInstDetected:
			StrCpy $R0 "detected"
		PrevInstDetectionEnd:

		Pop $R2
		Pop $R1
		Exch $R0
	FunctionEnd
!endif