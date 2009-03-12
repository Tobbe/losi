!ifndef PAGE_WHERE_PROFILES
!define PAGE_WHERE_PROFILES
	!include SetFocus.nsh
	!include WinVer.nsh
	!include LogicLib.nsh

	Page custom ioWhereProfiles

	Function ioWhereProfiles
		Push $R0
		Push $R1

		; Detect the current setting (if LiteStep has been installed before)
		
		StrCpy $R1 "3" ; Active field

		ReadRegStr $R0 HKLM "Software\LOSI\Installer" "ProfilesDir"
		IfErrors checkFolders
		${If} $R0 == "$INSTDIR"
			WriteINIStr "$PLUGINSDIR\ioWhereProfiles.ini" "Field 3" "State" "0"
			WriteINIStr "$PLUGINSDIR\ioWhereProfiles.ini" "Field 2" "State" "1"
			StrCpy $R1 "2"
		${ElseIf} $R0 == "%APPDATA%\Litestep"
			WriteINIStr "$PLUGINSDIR\ioWhereProfiles.ini" "Field 3" "State" "0"
			WriteINIStr "$PLUGINSDIR\ioWhereProfiles.ini" "Field 4" "State" "1"
			StrCpy $R1 "4"
		${EndIf}
		GoTo currentSettingsDetected

		checkFolders:
		ClearErrors
		IfFileExists "$INSTDIR\personal\personal.rc" 0 +4
			WriteINIStr "$PLUGINSDIR\ioWhereProfiles.ini" "Field 3" "State" "0"
			WriteINIStr "$PLUGINSDIR\ioWhereProfiles.ini" "Field 4" "State" "1"
			StrCpy $R1 "4"
		IfFileExists "$APPDATA\Litestep\personal\personal.rc" 0 +4
			WriteINIStr "$PLUGINSDIR\ioWhereProfiles.ini" "Field 3" "State" "0"
			WriteINIStr "$PLUGINSDIR\ioWhereProfiles.ini" "Field 2" "State" "1"
			StrCpy $R1 "2"
	
		currentSettingsDetected:
		StrCmp $advancedInstall "true" 0 end

		!insertmacro MUI_HEADER_TEXT "$(TEXT_IO_TITLE_WHEREPROFILES)" "$(TEXT_IO_WHEREPROFILES)"

		WriteINIStr "$PLUGINSDIR\ioWhereProfiles.ini" "Field 1" "Text" "$(TEXT_IO_TITLE_WHEREPROFILES)"
		WriteINIStr "$PLUGINSDIR\ioWhereProfiles.ini" "Field 2" "Text" "$(PROFILES_NOPROFILES)"
		WriteINIStr "$PLUGINSDIR\ioWhereProfiles.ini" "Field 3" "Text" "$(PROFILES_LSPROFILES)"
		WriteINIStr "$PLUGINSDIR\ioWhereProfiles.ini" "Field 4" "Text" "$(PROFILES_DAS)"

		${IfNot} ${AtLeastWin2000}
			; Remove the "Documents and Settings" profiles option when 
			; installing on anything older than Win2000
			WriteINIStr "$PLUGINSDIR\ioWhereProfiles.ini" "Field 4" "Type" "Label"
			WriteINIStr "$PLUGINSDIR\ioWhereProfiles.ini" "Field 4" "Text" ""
		${EndIf}

		!insertmacro MUI_INSTALLOPTIONS_INITDIALOG "ioWhereProfiles.ini"
		Pop $R0 ;HWND (handle) of dialog
		Push "$PLUGINSDIR\ioWhereProfiles.ini" ;Page .ini file where the field can be found.
		Push "$R0" ;Page handle you got when reserving the page.
		Push "$R1" ;Field number to set focus.
		Call SetFocus

		!insertmacro MUI_INSTALLOPTIONS_SHOW

		end:
		
		Pop $R1
		Pop $R0
	FunctionEnd
!endif