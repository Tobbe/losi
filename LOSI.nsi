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
!define PAGE_SEC_POST
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

var LogoffFlag

var username

var whereprofiles

var instCore

var advancedInstall

;--------------------------------
;Include Modern UI

!include "MUI.nsh"

!include WinMessages.nsh

; HM NIS Edit Wizard helper defines
!define PRODUCT_NAME "LOSI"
!define PRODUCT_VERSION "0.0.8"
!define PRODUCT_PUBLISHER "Tobbe"
!define PRODUCT_WEB_SITE "http://tlundberg.com"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\litestep.exe"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"
!define PRODUCT_STARTMENU_REGVAL "NSIS:StartMenuDir"

SetCompressor bzip2

;--------------------------------
;MUI Settings

!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP ".\header.bmp" ; optional
!define MUI_WELCOMEFINISHPAGE_BITMAP ".\welcomefinish.bmp"
!define MUI_UNWELCOMEFINISHPAGE_BITMAP ".\welcomefinish.bmp"
!define MUI_ABORTWARNING
!define MUI_ICON ".\installer.ico"
!define MUI_UNICON ".\installer.ico"
!define MUI_FINISHPAGE_NOAUTOCLOSE

;--------------------------------
;Pages

!include LongPath.nsh
!include "Pages.nsh"

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

Function .onInit
    !ifndef PAGE_WHERE_PROFILES
        StrCpy $whereprofiles "default"
	!endif
	
	!ifndef PAGE_SEC_CORE
	    StrCpy $instCore "true"
	    StrCpy $LogoffFlag "true"
	    ;SetRebootFlag true
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
    ;Extract InstallOptions INI Files
    !insertmacro MUI_INSTALLOPTIONS_EXTRACT "ioTypeOfInstall.ini"
    !insertmacro MUI_INSTALLOPTIONS_EXTRACT "ioHowLS.ini"
    !insertmacro MUI_INSTALLOPTIONS_EXTRACT "ioWhereProfiles.ini"
    !insertmacro MUI_INSTALLOPTIONS_EXTRACT "ioEvars.ini"
    !insertmacro MUI_INSTALLOPTIONS_EXTRACT "ioEvars2.ini"
    !insertmacro MUI_INSTALLOPTIONS_EXTRACT "ioFileAssoc.ini"
FunctionEnd

!ifdef PAGE_TYPE_OF_INSTALL
Function ioTypeOfInstall
	; Shows a page asking the user if he wants a normal
	; install or an advanced install
	!include ioTypeOfInstall.nsh
FunctionEnd
!endif

!ifdef PAGE_HOW_LS
Function ioHowLS
    ; Sets up the page where the user can choose how to
	; install LS (All users, current user, or don't set as shell)
	!include ioHowLS.nsh
FunctionEnd
!endif

!ifdef PAGE_WHERE_PROFILES
Function ioWhereProfiles
	; Sets up the page where the user can choose where
	; to install the profile files (System profiles dir,
	; LS profiles dir, or no profiles)
    !include ioWhereProfiles.nsh
FunctionEnd
!endif

!ifdef PAGE_CONFIG_EVARS
Function ioEvars
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

!ifdef PAGE_FILE_ASSOC
Function ioFileAssoc
	; Sets up the page for associating file types
	; with programs
	!include ioFileAssoc.nsh
FunctionEnd
!endif

;--------------------------------
;Installer Sections

Section "LiteStep files" SecCore
	!ifdef PAGE_SEC_CORE
		StrCpy $instCore "true"
		; Install all the litestep core files and distro specific files.
		; Also sets LS as shell if the user wants to
    	!include SecCore.nsh
    !endif
SectionEnd

Section "Theme" SecTheme
	!ifdef PAGE_SEC_THEME
    	SetOutPath "$whereprofiles\themes\InstDef"
    	File ".\Personal\themes\InstDef\*"

	    SetOutPath "$whereprofiles\themes"
	    File ".\Personal\themes\*"
	!endif
SectionEnd

Section "LOSI files and utilities" SecLosi
	!ifdef PAGE_SEC_LOSI
	    ; Installer related stuff
		SetOutPath "$INSTDIR\LOSI"
		File ".\LS\losi\*"
		
		; Install the utilities
	    SetOutPath "$INSTDIR\utilities"
    	File ".\LS\utilities\*"
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

Function LeavingInstFiles
    Push $0
    ReadINIStr $0 "$PLUGINSDIR\ioHowLS.ini" "Field 4" "State" ;Field 4 is Don't set shell
    IntCmp $0 1 pop 0 0 ;If we're not setting LS as the shell, we shouldn't start it.
		IfRebootFlag done 0
		StrCmp $LogoffFlag "true" done 0
			; If litestep was running when the installer started neither the rebootflag nor
			; the logoffflag will be set
			; If the user choose to install the litestep core the LS he was running would
			; have been killed. If that's the case we need to launch it again. If, how ever,
			; the user didn't choose to install the core we shouldn't start a second
			; instance of litestep.exe
		
			StrCmp $instCore "true" 0 done
	        	ExecShell open "$INSTDIR\litestep.exe" ;Launch LiteStep

		done:
	pop:
	pop $0
FunctionEnd

Section -AdditionalIcons
	!ifdef PAGE_SEC_ADDITIONAL_ICONS
    	SetOutPath $INSTDIR
    	!ifdef PAGE_START_MENU
    		!insertmacro MUI_STARTMENU_WRITE_BEGIN Application
    		WriteIniStr "$INSTDIR\${PRODUCT_NAME}.url" "InternetShortcut" "URL" "${PRODUCT_WEB_SITE}"
    		CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Website.lnk" "$INSTDIR\${PRODUCT_NAME}.url"
    		CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Uninstall.lnk" "$INSTDIR\uninst.exe"
    		!insertmacro MUI_STARTMENU_WRITE_END
		!endif
	!endif
SectionEnd

Section -Post
	!ifdef PAGE_SEC_POST
    	WriteUninstaller "$INSTDIR\uninst.exe"
    	WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "" "$INSTDIR\litestep.exe"
    	WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
    	WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "InstallLocation" "$INSTDIR"
    	WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninst.exe"
    	WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$INSTDIR\litestep.exe"
    	WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
    	WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
    	WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
    	WriteRegDWORD ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "NoModify" 1
    	WriteRegDWORD ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "NoRepair" 1
	!endif
SectionEnd


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Uninstall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!ifdef WRITE_UNINSTALLER
	Function un.onUninstSuccess
	    HideWindow
	    MessageBox MB_ICONINFORMATION|MB_OK "${PRODUCT_NAME} was successfully removed from your computer."
	FunctionEnd

	Function un.onInit
	    !insertmacro MUI_UNGETLANGUAGE
	    MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "Are you sure you want to completely remove ${PRODUCT_NAME} and all of its components?" IDYES +2
	    Abort
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

!ifdef PAGE_CONFIG_EVARS
    !include GetInQuotes.nsh
    !include IndexOf.nsh
    !include GetExecutablePath.nsh
	!include Evars.nsh
!endif
!include FinishPage.nsh
!ifdef PAGE_HOW_LS
    !include GetWindowsVersion.nsh
!endif
!ifdef PAGE_SEC_CORE
	!include Shell9x.nsh
	!include ShellNT.nsh
	!include Kill.nsh
	!include BackupPersonal.nsh
	!include refreshShellIcons.nsh
!endif
!ifdef WRITE_UNINSTALLER
	!include uninstShell9x.nsh
!endif
!include ieversion.nsh
!ifdef PAGE_FILE_ASSOC
	!include RegisterExtension.nsh
	!ifndef PAGE_SEC_CORE
	    !include refreshShellIcons.nsh
	!endif
!endif
!ifdef PAGE_WHERE_PROFILES
	!include SetFocus.nsh
!endif