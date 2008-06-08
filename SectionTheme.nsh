!ifndef SECTION_THEME
!define SECTION_THEME
	!include SectionsInclude.nsh
	
	Section "Theme" SecTheme
    	SetOutPath "$whereprofiles\themes"
		!insertmacro UNINSTALL.LOG_OPEN_INSTALL
	    File /r /x ".svn" /x "*-empty.rc" ".\Personal\themes\*"
	    !insertmacro UNINSTALL.LOG_CLOSE_INSTALL
	SectionEnd
!endif