!include PreFunctions.nsh

; Welcome page
!ifdef PAGE_WELCOME
	!insertmacro MUI_PAGE_WELCOME
!endif

; License page
!ifdef PAGE_LICENSE
	!define MUI_LICENSEPAGE_CHECKBOX
	!insertmacro MUI_PAGE_LICENSE ".\license.rtf"
!endif

; Normal/Advanced install
!ifdef PAGE_TYPE_OF_INSTALL
	Page custom ioTypeOfInstall
!endif

; Components page
!ifdef PAGE_SEC_CORE
    !define MUI_PAGE_CUSTOMFUNCTION_PRE PreAdvanced
	!insertmacro MUI_PAGE_COMPONENTS
!else ifdef PAGE_SEC_THEME
    !define MUI_PAGE_CUSTOMFUNCTION_PRE PreAdvanced
    !insertmacro MUI_PAGE_COMPONENTS
!else ifdef PAGE_SEC_LOSI
    !define MUI_PAGE_CUSTOMFUNCTION_PRE PreAdvanced
    !insertmacro MUI_PAGE_COMPONENTS
!endif

; Directory page
!ifdef PAGE_DIRECTORY
    !define MUI_PAGE_CUSTOMFUNCTION_PRE PreDir
	!insertmacro MUI_PAGE_DIRECTORY
!endif

; How to install LS (for all users, or just for the current user)
!ifdef PAGE_HOW_LS
	Page custom ioHowLS
!endif

; Where to install the user profiles
!ifdef PAGE_WHERE_PROFILES
	Page custom ioWhereProfiles
!endif

; Start menu page
!ifdef PAGE_START_MENU
    #!define MUI_PAGE_CUSTOMFUNCTION_PRE PreAdvanced
	!include StartMenuSettings.nsh
!endif

; Instfiles page
!define MUI_PAGE_CUSTOMFUNCTION_LEAVE LeavingInstFiles
!insertmacro MUI_PAGE_INSTFILES

; Associate Files page
!ifdef PAGE_FILE_ASSOC
    var fileAssoc
	Page custom ioFileAssoc
!endif

; Evars pages
!ifdef PAGE_CONFIG_EVARS
    var configEvars
	Page custom ioEvars
	Page custom ioEvars2
!endif

; Finish page
!include FinishPageSettings.nsh

; Uninstaller pages
!ifdef WRITE_UNINSTALLER
	!insertmacro MUI_UNPAGE_INSTFILES
!endif