; NSIS extensions needed to compile this script that 
;    aren't in the default install:
; FindProcDLL   (don't get the optimized for size version, 
; KillProcDLL    I had no luck with that)
; ShutDown
; You will also need the include header "Advanced Uninstall Log NSIS Header"
;   Make sure you get the modified version that has support for localization

!define PAGE_WELCOME
!define PAGE_LICENSE
!define PAGE_TYPE_OF_INSTALL
!define PAGE_SEC_CORE
!define PAGE_SEC_THEME
!define PAGE_SEC_LOSI
!define PAGE_DIRECTORY
!define PAGE_HOW_LS
!define PAGE_WHERE_PROFILES
!define PAGE_START_MENU
!define PAGE_FILE_ASSOC
!define PAGE_CONFIG_EVARS
!define PAGE_SEC_ADDITIONAL_ICONS
!define WRITE_UNINSTALLER

;--------------------------------
;Variables

!ifdef PAGE_CONFIG_EVARS
var filemanager
var texteditor
var commandprompt
var audioplayer
var mediaplayer
var gfxviewer
var gfxeditor
var browser
var dun
var email
var irc
var ftp
var im
var tmp
!endif

var currentShell
var hasStartedLS

var username

var whereprofiles

var advancedInstall

;--------------------------------
;Include Modern UI

!include "MUI.nsh"

!include WinMessages.nsh

; HM NIS Edit Wizard helper defines
!define PRODUCT_NAME "LOSI"
!define PRODUCT_VERSION "0.1"
!define PRODUCT_PUBLISHER "Tobbe"
!define PRODUCT_WEB_SITE "http://tlundberg.com/LOSI"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\litestep.exe"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"
!define PRODUCT_STARTMENU_REGVAL "NSIS:StartMenuDir"

SetCompressor bzip2

;--------------------------------
; Uninstall log
!define INSTDIR_REG_ROOT "${PRODUCT_UNINST_ROOT_KEY}"
!define INSTDIR_REG_KEY "${PRODUCT_UNINST_KEY}"
!define UNINSTALLOG_LOCALIZE
!include AdvUninstLog.nsh
!insertmacro UNATTENDED_UNINSTALL ;Keep all files we didn't install without asking

;--------------------------------
;MUI Settings

!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP ".\header.bmp" ; optional
!define MUI_WELCOMEFINISHPAGE_BITMAP ".\welcomefinish.bmp"
!define MUI_UNWELCOMEFINISHPAGE_BITMAP ".\welcomefinish.bmp"
!define MUI_ABORTWARNING
!define MUI_ICON ".\installer.ico"
!define MUI_UNICON ".\installer.ico"

;--------------------------------
;Pages

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

	Function ioTypeOfInstall
		; Shows a page asking the user if he wants a normal
		; install or an advanced install
		!include ioTypeOfInstall.nsh
	FunctionEnd
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
	!include BadPathsCheck.nsh

    !define MUI_PAGE_CUSTOMFUNCTION_PRE PreDir
    !define MUI_PAGE_CUSTOMFUNCTION_LEAVE BadPathsCheck
	!insertmacro MUI_PAGE_DIRECTORY
!endif

; How to install LS (for all users, or just for the current user)
!ifdef PAGE_HOW_LS
	!include GetWindowsVersion.nsh

	Page custom ioHowLS
	
	Function ioHowLS
	    ; Sets up the page where the user can choose how to
		; install LS (All users, current user, or don't set as shell)
		!include ioHowLS.nsh
	FunctionEnd
!endif

; Where to install the user profiles
!ifdef PAGE_WHERE_PROFILES
	!include SetFocus.nsh
	!include GetWindowsVersion.nsh

	Page custom ioWhereProfiles
	
	Function ioWhereProfiles
		; Sets up the page where the user can choose where
		; to install the profile files (System profiles dir,
		; LS profiles dir, or no profiles)
	    !include ioWhereProfiles.nsh
	FunctionEnd
!endif

; Start menu page
!ifdef PAGE_START_MENU
	!include StartMenuSettings.nsh
!endif

; Instfiles page
!insertmacro MUI_PAGE_INSTFILES

; Evars pages
!ifdef PAGE_CONFIG_EVARS
	!include GetInQuotes.nsh
	!include IndexOf.nsh
	!include GetExecutablePath.nsh
	!include Evars.nsh

    var configEvars
	Page custom ioEvars
	Page custom ioEvars2
	
	Function ioEvars
		; The function below is smart about only doing
		; this if the evar variables aren't already
		; populated.
		; By having this function call before the StrCmp
		; on $configEvars$ the evars will always get
		; good values
		Call PopulateEvarVariables
	
	    StrCmp $configEvars "true" isSel end
	    isSel:
	        Call WriteEvarsToEdit
	
	    	!insertmacro MUI_HEADER_TEXT "$(TEXT_IO_TITLE_EVARS)" "$(TEXT_IO_EVARS)"
	    	!insertmacro MUI_INSTALLOPTIONS_DISPLAY "ioEvars.ini"
		end:
	FunctionEnd
	
	Function ioEvars2
	    StrCmp $configEvars "true" isSel notSel
	    isSel:
	    	!insertmacro MUI_HEADER_TEXT "$(TEXT_IO_TITLE_EVARS)" "$(TEXT_IO_EVARS)"
	    	!insertmacro MUI_INSTALLOPTIONS_DISPLAY "ioEvars2.ini"
	
	    	Call ReadEvarsFromEdit
	
		notSel:
	
		Call WriteEvars
	FunctionEnd
!endif

; Associate Files page
!ifdef PAGE_FILE_ASSOC
	!include RegisterExtension.nsh
	!include refreshShellIcons.nsh

    var fileAssoc
	Page custom ioFileAssoc
	
	Function ioFileAssoc
		; Sets up the page for associating file types
		; with programs
		!include ioFileAssoc.nsh
	FunctionEnd
!endif

; Finish page
!include FinishPageSettings.nsh

; Uninstaller pages
!ifdef WRITE_UNINSTALLER
	!include uninstShell9x.nsh
	!include GetWindowsVersion.nsh

	!insertmacro MUI_UNPAGE_INSTFILES
!endif

;--------------------------------
;Language Selection Dialog Settings

;Remember the installer language
!define MUI_LANGDLL_REGISTRY_ROOT "${PRODUCT_UNINST_ROOT_KEY}"
!define MUI_LANGDLL_REGISTRY_KEY "${PRODUCT_UNINST_KEY}"
!define MUI_LANGDLL_REGISTRY_VALUENAME "NSIS:Language"

;End Lang. Sel.
;--------------------------------

!include "LanguageStrings.nsh"

;--------------------------------
;Reserve Files

;These files should be inserted before other files in the data block
;Keep these lines before any File command
;Only for solid compression (by default, solid compression is enabled for BZIP2 and LZMA)

ReserveFile "ioTypeOfInstall.ini"
ReserveFile "ioEvars.ini"
ReserveFile "ioEvars2.ini"
ReserveFile "ioHowLS.ini"
ReserveFile "ioWhereProfiles.ini"
ReserveFile "ioFileAssoc.ini"
!insertmacro MUI_RESERVEFILE_INSTALLOPTIONS

; MUI end ------

;--------------------------------
;General

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"

;Name of installation exe
OutFile "${PRODUCT_NAME}-${PRODUCT_VERSION}.exe"

;Default installation folder
InstallDir "$PROGRAMFILES\LiteStep"

;Get installation folder from registry if available
InstallDirRegKey HKLM "${PRODUCT_DIR_REGKEY}" ""

ShowInstDetails show
ShowUnInstDetails show

!ifdef PAGE_SEC_CORE
    !include GetInQuotes.nsh
    !include IndexOf.nsh
    !include GetExecutablePath.nsh
!endif

Function .onInit
    !ifndef PAGE_WHERE_PROFILES
        StrCpy $whereprofiles "default"
	!endif
	
	UserInfo::GetName
	Pop $username
	ClearErrors ; UserInfo might genrate an error, but we don't care
	
    !insertmacro MUI_LANGDLL_DISPLAY
    
    Call GetIEVersion
	Pop $R0
	
	IntCmp $R0 4 good 0 good
		MessageBox MB_OK $(IE4)
		Abort $(IE4)
		
	good:
	
	;prepare log always within .onInit function
	!insertmacro UNINSTALL.LOG_PREPARE_INSTALL
	
	;Extract InstallOptions INI Files
    !insertmacro MUI_INSTALLOPTIONS_EXTRACT "ioTypeOfInstall.ini"
    !insertmacro MUI_INSTALLOPTIONS_EXTRACT "ioHowLS.ini"
    !insertmacro MUI_INSTALLOPTIONS_EXTRACT "ioWhereProfiles.ini"
    !insertmacro MUI_INSTALLOPTIONS_EXTRACT "ioEvars.ini"
    !insertmacro MUI_INSTALLOPTIONS_EXTRACT "ioEvars2.ini"
    !insertmacro MUI_INSTALLOPTIONS_EXTRACT "ioFileAssoc.ini"
FunctionEnd

Function .onInstSuccess
         ;Alwasy create/update log within the .onInstSuccess function
         !insertmacro UNINSTALL.LOG_UPDATE_INSTALL
FunctionEnd

;--------------------------------
;Installer Sections

Section "LiteStep files" SecCore
	!ifdef PAGE_SEC_CORE
		; Install all the litestep core files and distro specific files.
		; Also sets LS as shell if the user wants to
    	!include SecCore.nsh
    !endif
SectionEnd

Section "Theme" SecTheme
	!ifdef PAGE_SEC_THEME
    	SetOutPath "$whereprofiles\themes"
		!insertmacro UNINSTALL.LOG_OPEN_INSTALL
	    File /r /x ".svn" ".\Personal\themes\*"
	    !insertmacro UNINSTALL.LOG_CLOSE_INSTALL
	!endif
SectionEnd

Section "LOSI files and utilities" SecLosi
	!ifdef PAGE_SEC_LOSI
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
	!endif
SectionEnd

Section "Associate files" SecFileAssoc
	!ifdef PAGE_FILE_ASSOC
		StrCpy $fileAssoc "true"
	!endif
SectionEnd

Section "Configure Evars" SecConfigEvars
	!ifdef PAGE_CONFIG_EVARS
		StrCpy $configEvars "true"
	!endif
SectionEnd

Section -AdditionalIcons
	!ifdef PAGE_SEC_ADDITIONAL_ICONS
    	SetOutPath $INSTDIR
    	!ifdef PAGE_START_MENU
    		!insertmacro MUI_STARTMENU_WRITE_BEGIN Application
    		WriteIniStr "$INSTDIR\${PRODUCT_NAME}.url" "InternetShortcut" "URL" "${PRODUCT_WEB_SITE}"
    		CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Website.lnk" "$INSTDIR\${PRODUCT_NAME}.url"
    		CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Uninstall.lnk" "${UNINST_EXE}"
    		!insertmacro MUI_STARTMENU_WRITE_END
		!endif
	!endif
SectionEnd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Uninstall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!ifdef WRITE_UNINSTALLER
	Section -post
    	WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "" "$INSTDIR\litestep.exe"
    	WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
    	WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "InstallLocation" "$INSTDIR"
    	WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "${UNINST_EXE}"
    	WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$INSTDIR\litestep.exe"
    	WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
    	WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
    	WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
    	WriteRegDWORD ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "NoModify" 1
    	WriteRegDWORD ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "NoRepair" 1
	SectionEnd
    
	Function un.onUninstSuccess
	    HideWindow
	    MessageBox MB_ICONINFORMATION|MB_OK $(UNINSTALL_SUCCESS)
	FunctionEnd

	Function un.onInit
	    !insertmacro MUI_UNGETLANGUAGE
	    MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 $(UNINSTALL_CONFIRM) IDYES +2
	    Abort
	    !insertmacro UNINSTALL.LOG_BEGIN_UNINSTALL
	FunctionEnd

	Section Uninstall
		!include Uninstall.nsh
	SectionEnd
!endif


;--------------------------------
;Descriptions

;Assign language strings to sections
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${SecCore} $(DESC_SecCore)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecTheme} $(DESC_SecTheme)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecLosi} $(DESC_SecLosi)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecFileAssoc} $(DESC_SecFileAssoc)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecConfigEvars} $(DESC_SecConfigEvars)
!insertmacro MUI_FUNCTION_DESCRIPTION_END

!include LongPath.nsh
!include PreFunctions.nsh
!include FinishPage.nsh
!include Kill.nsh
!include ieversion.nsh

!ifdef PAGE_SEC_CORE
	!include Shell9x.nsh
	!include ShellNT.nsh
	!include BackupPersonal.nsh
	!include GetWindowsVersion.nsh
!endif