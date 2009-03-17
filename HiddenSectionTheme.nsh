!ifndef HIDDEN_SECTION_THEME
!define HIDDEN_SECTION_THEME

!include LogicLib.nsh

Section "-HiddenSectionTheme"
	Push $0
	Push $1
	Push $2

	${whereprofilesarray->SizeOf} $1 $1 $0
	IntOp $0 $0 - 1

	${For} $1 0 $0 ; $1 from 0 to size-1
		${whereprofilesarray->Read} $2 $1

		; OTS2 Theme files
		IfFileExists "$2\themes\themeslist.rc" 0 AddThemeFiles
			IfFileExists "$2\themes\themeselect.rc" SkipThemeFiles

		AddThemeFiles:
		SetOutPath  "$2\themes\"
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
	${Next}

	Pop $2
	Pop $1
	Pop $0
SectionEnd

!endif