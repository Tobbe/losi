; NSIS extensions needed to compile this script that 
;    aren't in the default install:
; FindProcDLL   (don't get the optimized for size version, 
; KillProcDLL    I had no luck with that)
; ShutDown
; You will also need the include header "Advanced Uninstall Log NSIS Header"
;   Make sure you get the modified version that has support for localization

!define PAGE_WELCOME
!define PAGE_LICENSE
!define PAGE_PREREQUISITES
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
var PreReqOK
var advancedInstall

;--------------------------------
;Include Modern UI

!include "MUI.nsh"

!include WinMessages.nsh

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
!define MUI_ICON ".\installer.ico"
!define MUI_UNICON ".\installer.ico"
!define MUI_CUSTOMFUNCTION_ABORT customOnUserAbort

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
ReserveFile "ioPreReq.ini"
ReserveFile "test.txt"
ReserveFile "cross.bmp"
ReserveFile "check.bmp"
!insertmacro MUI_RESERVEFILE_INSTALLOPTIONS
!insertmacro MUI_RESERVEFILE_LANGDLL ;Language selection dialog

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

;--------------------------------
;Language Selection Dialog Settings

;Remember the installer language
!define MUI_LANGDLL_REGISTRY_ROOT "${PRODUCT_UNINST_ROOT_KEY}"
!define MUI_LANGDLL_REGISTRY_KEY "${PRODUCT_UNINST_KEY}"
!define MUI_LANGDLL_REGISTRY_VALUENAME "NSIS:Language"

;End Lang. Sel.
;--------------------------------

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

!ifdef PAGE_PREREQUISITES
	!include ieversion.nsh
	!include LogicLib.nsh
	!include WinSxSHasAssembly.nsh
	
	Page custom ioPreReq
	
	Function ioPreReq
		Push $R0
		Push $R1
		Push $R2 ; true if IE => 4 is installed, false if it isn't
		Push $R3 ; true if VC8 dlls are installed, false if they aren't
		Push $R4 ; true if VC8 SP1 dlls are installed, false if they aren't
		Push $R5 ; true if VC9 dlls are installed
		
		; Assume everything is OK
		StrCpy $R2 "true"
		StrCpy $R3 "true"
		StrCpy $R4 "true"
		StrCpy $R5 "true"

		; Check for Internet Explorer >= 4
		Call GetIEVersion
		Pop $R0
		
		${If} $R0 < 4
			StrCpy $R2 "false"
		${EndIf}

		; Look for VC8 DLLs
		Push 'msvcr80.dll'
		Push 'Microsoft.VC80.CRT,version="8.0.50727.42",type="win32",processorArchitecture="x86",publicKeyToken="1fc8b3b9a1e18e3b"'
		Call WinSxS_HasAssembly
		Pop $R0

		${If} $R0 == 0
			; Try another version
			Push 'msvcr80.dll'
			Push 'Microsoft.VC80.CRT,version="8.0.50727.163",type="win32",processorArchitecture="x86",publicKeyToken="1fc8b3b9a1e18e3b"'
			Call WinSxS_HasAssembly
			Pop $R0

			${If} $R0 == 0
				; Try yet another version
				Push 'msvcr80.dll'
				Push 'Microsoft.VC80.CRT,version="8.0.50727.762",type="win32",processorArchitecture="x86",publicKeyToken="1fc8b3b9a1e18e3b"'
				Call WinSxS_HasAssembly
				Pop $R0

				${If} $R0 == 0
					; Try another version again
					Push 'msvcr80.dll'
					Push 'Microsoft.VC80.CRT,version="8.0.50727.1433",type="win32",processorArchitecture="x86",publicKeyToken="1fc8b3b9a1e18e3b"'
					Call WinSxS_HasAssembly
					Pop $R0

					${If} $R0 == 0
						StrCpy $R3 "false"
					${EndIf}
				${EndIf}
			${EndIf}
		${EndIf}

		; Look for VC8 SP1 DLLs
		Push 'msvcr80.dll'
		Push 'Microsoft.VC80.CRT,version="8.0.50727.762",type="win32",processorArchitecture="x86",publicKeyToken="1fc8b3b9a1e18e3b"'
		Call WinSxS_HasAssembly
		Pop $R0

		${If} $R0 == 0
			; Try another version
			Push 'msvcr80.dll'
			Push 'Microsoft.VC80.CRT,version="8.0.50727.1433",type="win32",processorArchitecture="x86",publicKeyToken="1fc8b3b9a1e18e3b"'
			Call WinSxS_HasAssembly
			Pop $R0

			${If} $R0 == 0
				StrCpy $R4 "false"
			${EndIf}
		${EndIf}
		
		; Look for VC9 DLLs
		Push 'msvcr90.dll'
		Push 'Microsoft.VC90.CRT,version="9.0.21022.8",type="win32",processorArchitecture="x86",publicKeyToken="1fc8b3b9a1e18e3b"'
		Call WinSxS_HasAssembly
		Pop $R0

		${If} $R0 == 0
			StrCpy $R5 "false"
		${EndIf}

		!insertmacro MUI_HEADER_TEXT "$(TEXT_IO_TITLE_PREREQ)" "$(TEXT_IO_PREREQ)"

		InitPluginsDir
		SetOutPath $PLUGINSDIR
		File ".\cross.bmp"
		File ".\check.bmp"

		${If} $R2 == "true"
			WriteINIStr "$PLUGINSDIR\ioPreReq.ini" "Field 1" "Text" "$PLUGINSDIR\check.bmp"
		${Else}
			WriteINIStr "$PLUGINSDIR\ioPreReq.ini" "Field 1" "Text" "$PLUGINSDIR\cross.bmp"
		${EndIf}
		
		${If} $R3 == "true"
			WriteINIStr "$PLUGINSDIR\ioPreReq.ini" "Field 3" "Text" "$PLUGINSDIR\check.bmp"
		${Else}
			WriteINIStr "$PLUGINSDIR\ioPreReq.ini" "Field 3" "Text" "$PLUGINSDIR\cross.bmp"
		${EndIf}

		${If} $R4 == "true"
			WriteINIStr "$PLUGINSDIR\ioPreReq.ini" "Field 7" "Text" "$PLUGINSDIR\check.bmp"
		${Else}
			WriteINIStr "$PLUGINSDIR\ioPreReq.ini" "Field 7" "Text" "$PLUGINSDIR\cross.bmp"
		${EndIf}

		${If} $R5 == "true"
			WriteINIStr "$PLUGINSDIR\ioPreReq.ini" "Field 8" "Text" "$PLUGINSDIR\check.bmp"
		${Else}
			WriteINIStr "$PLUGINSDIR\ioPreReq.ini" "Field 8" "Text" "$PLUGINSDIR\cross.bmp"
		${EndIf}
		
		WriteINIStr "$PLUGINSDIR\ioPreReq.ini" "Field 5" "Text" "$(PRE_REQ_NEEDED)"
		WriteINIStr "$PLUGINSDIR\ioPreReq.ini" "Field 2" "Text" "$(PRE_REQ_GTEIE4)"
		WriteINIStr "$PLUGINSDIR\ioPreReq.ini" "Field 4" "Text" "$(PRE_REQ_VC8)"
		WriteINIStr "$PLUGINSDIR\ioPreReq.ini" "Field 6" "Text" "$(PRE_REQ_GOOD)"
		WriteINIStr "$PLUGINSDIR\ioPreReq.ini" "Field 9" "Text" "$(PRE_REQ_VC8SP1)"
		WriteINIStr "$PLUGINSDIR\ioPreReq.ini" "Field 10" "Text" "$(PRE_REQ_VC9)"
		WriteINIStr "$PLUGINSDIR\ioPreReq.ini" "Field 11" "Text" "$(PRE_REQ_URLTEXT)"
		WriteINIStr "$PLUGINSDIR\ioPreReq.ini" "Field 12" "Text" "${PRODUCT_WEB_SITE}/prereq.html"		
		WriteINIStr "$PLUGINSDIR\ioPreReq.ini" "Field 12" "State" "${PRODUCT_WEB_SITE}/prereq.html"		
	
        !insertmacro INSTALLOPTIONS_INITDIALOG "ioPreReq.ini"
        ${If} $R2 == "false"
        ${OrIf} $R3 == "false"
        	GetDlgItem $R1 $HWNDPARENT 1
        	EnableWindow $R1 0
        	StrCpy $PreReqOK "false"
        ${EndIf}
        !insertmacro INSTALLOPTIONS_SHOW
        
        Pop $R1
		Pop $R0	
	FunctionEnd
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
	!include GetExecutablePath.nsh

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

!include "LanguageStrings.nsh"

Function .onInit
	StrCpy $PreReqOK "true"
    !ifndef PAGE_WHERE_PROFILES
        StrCpy $whereprofiles "default"
	!endif
	
	UserInfo::GetName
	Pop $username
	ClearErrors ; UserInfo might genrate an error, but we don't care
	
    !insertmacro MUI_LANGDLL_DISPLAY
	
	;prepare log always within .onInit function
	!insertmacro UNINSTALL.LOG_PREPARE_INSTALL
	
	;Extract InstallOptions INI Files
	!insertmacro MUI_INSTALLOPTIONS_EXTRACT "ioPreReq.ini"
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

Function customOnUserAbort
	StrCmp $PreReqOK "false" NoCancelAbort
	MessageBox MB_YESNO|MB_ICONEXCLAMATION "$(ABORT_WARNING)" IDYES NoCancelAbort
		Abort ; causes installer to not quit.
	NoCancelAbort:
FunctionEnd

;--------------------------------
;Installer Sections
!ifdef PAGE_SEC_CORE
    !include GetInQuotes.nsh
    !include IndexOf.nsh
    !include GetExecutablePath.nsh
!endif
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
	    File /r /x ".svn" /x "*-empty.rc" ".\Personal\themes\*"
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

!ifdef PAGE_SEC_ADDITIONAL_ICONS
	Section -AdditionalIcons
		SetOutPath $INSTDIR
		!ifdef PAGE_START_MENU
			!insertmacro MUI_STARTMENU_WRITE_BEGIN Application
			WriteIniStr "$INSTDIR\${PRODUCT_NAME}.url" "InternetShortcut" "URL" "${PRODUCT_WEB_SITE}"
			CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Website.lnk" "$INSTDIR\${PRODUCT_NAME}.url"
			CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Uninstall.lnk" "${UNINST_EXE}"
			!insertmacro MUI_STARTMENU_WRITE_END
		!endif
	SectionEnd
!endif

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

!ifdef PAGE_SEC_CORE
	!include Shell9x.nsh
	!include ShellNT.nsh
	!include BackupPersonal.nsh
	!include GetWindowsVersion.nsh
!endif