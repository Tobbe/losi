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
	Push $0
	${whereprofilesarray->Read} $0 0
	${If} $0 == "$INSTDIR\Profiles\$username"
		WriteRegStr HKCU "Software\Litestep\SLI\ThemeManager" "ThemesDir" "$INSTDIR\Profiles\%USERNAME%\themes\"
	${ElseIf} $0 == "$APPDATA\LiteStep"
		WriteRegStr HKCU "Software\Litestep\SLI\ThemeManager" "ThemesDir" "%APPDATA%\LiteStep\themes\"
	${Else}
		WriteRegStr HKCU "Software\Litestep\SLI\ThemeManager" "ThemesDir" "$0\themes\"
	${EndIf}
	Pop $0
	
	WriteRegStr HKCU "Software\Litestep\SLI\ThemeManager" "LitestepDir" "$INSTDIR\"
	WriteRegDword HKCU "Software\Litestep\SLI\ThemeManager" "SecurityTimeout" 2
SectionEnd

!endif