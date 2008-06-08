!ifndef PAGE_DIRECTORY
!define PAGE_DIRECTORY
	!include BadPathsCheck.nsh

    !define MUI_PAGE_CUSTOMFUNCTION_PRE PreDir
    !define MUI_PAGE_CUSTOMFUNCTION_LEAVE BadPathsCheck
	!insertmacro MUI_PAGE_DIRECTORY
!endif