!ifndef SECTION_LOSI
!define SECTION_LOSI
	!include SectionsInclude.nsh
	
	Section "$(NAME_SecLosi)" SecLosi
	    ; Installer related stuff
		SetOutPath "$INSTDIR\LOSI"
		!insertmacro UNINSTALL.LOG_OPEN_INSTALL
		File ".\LS\losi\*"
		!insertmacro UNINSTALL.LOG_CLOSE_INSTALL
		
		; Install the utilities
	    SetOutPath "$INSTDIR\utilities"
	    !insertmacro UNINSTALL.LOG_OPEN_INSTALL
    	File ".\LS\utilities\*"
    	!insertmacro UNINSTALL.LOG_CLOSE_INSTALL
    	
    	; Write some registry settings that SLI-ThemeManager needs
		WriteRegStr HKCU "Software\Litestep\SLI\ThemeManager" "LitestepDir" "$INSTDIR\"
		WriteRegStr HKCU "Software\Litestep\SLI\ThemeManager" "ThemesDir" "$whereprofiles\themes\"
		WriteRegDword HKCU "Software\Litestep\SLI\ThemeManager" "SecurityTimeout" 2
	SectionEnd
!endif