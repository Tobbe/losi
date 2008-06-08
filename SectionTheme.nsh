!ifndef SECTION_THEME
!define SECTION_THEME
	!include SectionsInclude.nsh
	
	Section "$(NAME_SecTheme)" SecTheme
    	SetOutPath "$whereprofiles\themes"
    	; Don't log these files, they are removed the traditional way
		;!insertmacro UNINSTALL.LOG_OPEN_INSTALL
	    File /r /x ".svn" /x "*-empty.rc" ".\Personal\themes\*"
	SectionEnd
!endif