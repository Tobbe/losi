!ifndef SECTION_THEME
!define SECTION_THEME

!include SectionsInclude.nsh

Section "$(NAME_SecTheme)" SecTheme
	Push $0
	Push $1
	Push $2

	${whereprofilesarray->SizeOf} $1 $1 $0
	IntOp $0 $0 - 1

	${For} $1 0 $0 ; $1 from 0 to size-1
		${whereprofilesarray->Read} $2 $1

		SetOutPath "$2\themes\InstDef"
		; Don't log these files, they are removed the traditional way
		;!insertmacro UNINSTALL.LOG_OPEN_INSTALL
		File /r /x ".svn" ".\Personal\themes\InstDef\*"
	${Next}

	Pop $2
	Pop $1
	Pop $0
SectionEnd

!endif