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

    SetOutPath "$INSTDIR"
    SetOverwrite on

    Push $0
    ReadINIStr $0 "$PLUGINSDIR\ioWhereProfiles.ini" "Field 4" "State" ;Field 4 is Documents and Settings
    IntCmp $0 1 +3 0 0
    ReadINIStr $0 "$PLUGINSDIR\ioWhereProfiles.ini" "Field 3" "State" ;Field 3 is LSDir\Profiles
    IntCmp $0 1 profiles noprofiles

    ; Install to Documents and Settings
    StrCpy $whereprofiles "$APPDATA\LiteStep"
    MessageBox MB_OK "$whereprofiles"
    File ".\LS\step-das\step.rc" ;das = Documents and Settings :p
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
    File ".\LS\step-lsdir\step.rc"
    GoTo reg

    ; Don't install any profiles
    noprofiles:
    StrCpy $whereprofiles "$INSTDIR"
    File ".\LS\step-none\step.rc"

	reg:
    Pop $0

    ;; Store a few paths in the registry
    WriteRegStr HKLM "Software\${PRODUCT_NAME}\Installer" "LSDir" $INSTDIR
    WriteRegStr HKLM "Software\${PRODUCT_NAME}\Installer" "ProfilesDir" $whereprofiles
    WriteRegStr HKLM "Software\${PRODUCT_NAME}\Installer" "PersonalDir" "$whereprofiles\personal"

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

    SetOutPath "$INSTDIR\NLM"
    SetOverwrite on
    File ".\LS\NLM\*"

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
    CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Set Explorer as Shell.lnk" '$INSTDIR\utilities\setshell.exe' -explorer "$INSTDIR\losi\SetShellExplorer.ico"
	CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Set LiteStep as Shell.lnk" '$INSTDIR\utilities\setshell.exe' -litestep "$INSTDIR\losi\SetShellLS.ico"
	CreateShortCut "$DESKTOP\Set Explorer as Shell.lnk" '$INSTDIR\utilities\setshell.exe' -explorer "$INSTDIR\losi\SetShellExplorer.ico"
	CreateShortCut "$DESKTOP\Set LiteStep as Shell.lnk" '$INSTDIR\utilities\setshell.exe' -litestep "$INSTDIR\losi\SetShellLS.ico"
	!insertmacro MUI_STARTMENU_WRITE_END
!endif

    SetOverwrite on

	; Install all the modules and their docs
    SetOutPath "$INSTDIR\modules\docs\lsxcommand-1.9.3"
    File ".\LS\modules\docs\lsxcommand-1.9.3\*"

    SetOutPath "$INSTDIR\modules\docs\popup2-2.1.7"
    File ".\LS\modules\docs\popup2-2.1.7\*"

    SetOutPath "$INSTDIR\modules\docs\vtray-1.10"
    File ".\LS\modules\docs\vtray-1.10\*"

    SetOutPath "$INSTDIR\modules\docs\xtaskbar-1.1.5"
    File ".\LS\modules\docs\xtaskbar-1.1.5\*"

    SetOutPath "$INSTDIR\modules\docs\"
    File ".\LS\modules\docs\*"

    SetOutPath "$INSTDIR\modules\"
    File ".\LS\modules\*"

    ; Install the utilities
    SetOutPath "$INSTDIR\utilities"
    File ".\LS\utilities\*"


    ; Install the personal files

    call backupPersonal

    SetOutPath "$whereprofiles\personal\jkey"
    File ".\Personal\personal\jkey\*"

    SetOutPath "$whereprofiles\personal\lsxcommand"
    File ".\Personal\personal\lsxcommand\*"

    SetOutPath "$whereprofiles\personal\rainlendar\languages"
    File ".\Personal\personal\rainlendar\languages\*"

    SetOutPath "$whereprofiles\personal\rainlendar"
    File ".\Personal\personal\rainlendar\*"

    SetOutPath "$whereprofiles\personal"
    File ".\Personal\personal\*"

    ; Installer related stuff
    SetOutPath "$INSTDIR\losi"
    File ".\LS\losi\*"

    StrCmp $R9 "LSKilled" 0 wasntRunning
    StrCpy $LogoffFlag "false" ;If LiteStep was previously running there is no need to log off
	wasntRunning: