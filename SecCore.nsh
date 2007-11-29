	Push "$INSTDIR"
	Call KillLS
	Pop $R9

	SetOutPath "$SYSDIR"
	SetOverwrite off

	File ".\msvcp60.dll"
	File ".\msvcrt.dll"
	File ".\msvcp70.dll"
	File ".\msvcp71.dll"
	File ".\msvcr71.dll"
	File ".\msvcr70.dll"

	SetOverwrite on
	SetOutPath "$INSTDIR"

	Push $0
	ReadINIStr $0 "$PLUGINSDIR\ioWhereProfiles.ini" "Field 4" "State" ;Field 4 is Documents and Settings
	IntCmp $0 1 +3 0 0
	ReadINIStr $0 "$PLUGINSDIR\ioWhereProfiles.ini" "Field 3" "State" ;Field 3 is LSDir\Profiles
	IntCmp $0 1 profiles noprofiles

    ; Install to Documents and Settings
    StrCpy $whereprofiles "$APPDATA\LiteStep"
    !insertmacro UNINSTALL.LOG_OPEN_INSTALL
    File ".\LS\step-das\step.rc" ;das = Documents and Settings :p
    !insertmacro UNINSTALL.LOG_CLOSE_INSTALL
    GoTo reg

    ; Install to LSDir\Profiles
    profiles:
    UserInfo::GetName
    Pop $username
    StrCmp $username "" +1 profilesok

    ; If we get here it means no username was found, probably due to installing on 9x when not logged in
    MessageBox MB_OK $(MB_NO_USER)
    GoTo noprofiles

    profilesok:
    StrCpy $whereprofiles "$INSTDIR\Profiles\$username"
    !insertmacro UNINSTALL.LOG_OPEN_INSTALL
    File ".\LS\step-lsdir\step.rc"
    !insertmacro UNINSTALL.LOG_CLOSE_INSTALL
    GoTo reg

    ; Don't install any profiles
    noprofiles:
    StrCpy $whereprofiles "$INSTDIR"
    !insertmacro UNINSTALL.LOG_OPEN_INSTALL
    File ".\LS\step-none\step.rc"
    !insertmacro UNINSTALL.LOG_CLOSE_INSTALL

	reg:
    Pop $0

    ;; Store a few paths in the registry
    WriteRegStr HKLM "Software\${PRODUCT_NAME}\Installer" "LitestepDir" $INSTDIR
    WriteRegStr HKLM "Software\${PRODUCT_NAME}\Installer" "ProfilesDir" $whereprofiles
    WriteRegStr HKLM "Software\${PRODUCT_NAME}\Installer" "PersonalDir" "$whereprofiles\personal"

	!insertmacro UNINSTALL.LOG_OPEN_INSTALL
    File ".\LS\changes.txt"
    File ".\LS\hook.dll"
    File ".\LS\libpng13.dll"
    File ".\LS\license.txt"
    File ".\LS\litestep.exe"
    File ".\LS\lsapi.dll"
    File ".\LS\readme.txt"
    File ".\LS\zlib.dll"
    File ".\LS\zlib1.dll"
    File ".\LS\xPaintClass-1.0.dll"
    !insertmacro UNINSTALL.LOG_CLOSE_INSTALL

    SetOutPath "$INSTDIR\NLM"
    SetOverwrite on
    !insertmacro UNINSTALL.LOG_OPEN_INSTALL
    File ".\LS\NLM\*"
    !insertmacro UNINSTALL.LOG_CLOSE_INSTALL

    Push $0
    ReadINIStr $0 "$PLUGINSDIR\ioHowLS.ini" "Field 4" "State" ;Field 4 is Don't set shell
    IntCmp $0 1 pop 0 0 ;If we're not setting LS as the shell, we're jumpin all the way down
                        ;to "Pop $0"

    ; Check weather we're installing on a 9x or NT based system
    Call GetWindowsVersion
    Pop $R0

    StrCmp $R0 "9x" set9xShell

    ;If we get to this point we're not installing on a 9x based machine
	Call setShellNT
	GoTo pop

	set9xShell:
	Call setShell9x

pop:
    Pop $0

!ifdef PAGE_START_MENU
	; Shortcuts
    !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
    CreateDirectory "$SMPROGRAMS\$ICONS_GROUP"
    ;CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\${PRODUCT_NAME}.lnk" "$INSTDIR\litestep.exe"
    ;CreateShortCut "$DESKTOP\${PRODUCT_NAME}.lnk" "$INSTDIR\litestep.exe"
    CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Set Explorer as Shell.lnk" '"$INSTDIR\utilities\wxlua.exe"' '"$INSTDIR\utilities\LOSS.lua" explorer' "$INSTDIR\losi\SetShellExplorer.ico"
	CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Set LiteStep as Shell.lnk" '"$INSTDIR\utilities\wxlua.exe"' '"$INSTDIR\utilities\LOSS.lua" litestep' "$INSTDIR\losi\SetShellLS.ico"
	CreateShortCut "$DESKTOP\Set Explorer as Shell.lnk" '"$INSTDIR\utilities\wxlua.exe"' '"$INSTDIR\utilities\LOSS.lua" explorer' "$INSTDIR\losi\SetShellExplorer.ico"
	CreateShortCut "$DESKTOP\Set LiteStep as Shell.lnk" '"$INSTDIR\utilities\wxlua.exe"' '"$INSTDIR\utilities\LOSS.lua" litestep' "$INSTDIR\losi\SetShellLS.ico"
	!insertmacro MUI_STARTMENU_WRITE_END
!endif

	SetOverwrite on

	; Install all the modules and their docs
	SetOutPath "$INSTDIR\modules\"
	!insertmacro UNINSTALL.LOG_OPEN_INSTALL
	File /r /x ".svn" ".\LS\modules\*"
	!insertmacro UNINSTALL.LOG_CLOSE_INSTALL

	call backupPersonal

	; Install the personal files
	SetOutPath "$whereprofiles\personal"
	!insertmacro UNINSTALL.LOG_OPEN_INSTALL
	File /r /x ".svn" ".\Personal\personal\*"
	!insertmacro UNINSTALL.LOG_CLOSE_INSTALL

	StrCmp $R9 "LSKilled" 0 wasntRunning
	StrCpy $LogoffFlag "false" ;If LiteStep was previously running there is no need to log off
	wasntRunning: