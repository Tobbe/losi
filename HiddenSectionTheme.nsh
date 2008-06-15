!ifndef HIDDEN_SECTION_THEME
!define HIDDEN_SECTION_THEME
	!include LogicLib.nsh

	Section "-HiddenSectionTheme"
		; OTS2 Theme files
		IfFileExists "$whereprofiles\themes\themeslist.rc" 0 AddThemeFiles
			IfFileExists "$whereprofiles\themes\themeselect.rc" SkipThemeFiles
	
		AddThemeFiles:
		SetOutPath  "$whereprofiles\themes\"
		!insertmacro UNINSTALL.LOG_OPEN_INSTALL
		SetOverwrite off
		!ifdef SECTION_THEME
		${If} ${SectionIsSelected} ${SecTheme}
			File ".\Personal\themes\themeselect.rc"
			File ".\Personal\themes\themeslist.rc"
		${Else}
		!endif
			File /oname=themeselect.rc ".\Personal\themes\themeselect-empty.rc"
			File /oname=themeslist.rc ".\Personal\themes\themeslist-empty.rc"
		!ifdef SECTION_THEME
		${EndIf}
		!endif
		SetOverwrite on
		!insertmacro UNINSTALL.LOG_CLOSE_INSTALL
		SkipThemeFiles:
	SectionEnd
!endif