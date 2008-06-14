!ifndef SECTION_CORE
!define SECTION_CORE
	!include GetInQuotes.nsh
	!include IndexOf.nsh
	!include GetExecutablePath.nsh
	!include BackupPersonal.nsh
	!include Shell9x.nsh
	!include ShellNT.nsh
	!include GetWindowsVersion.nsh
	!include SectionsInclude.nsh

	Section "$(NAME_SecCore)" SecCore
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
		; IF
		StrCmp $whereprofiles "$INSTDIR\Profiles\$username" 0 +3
			WriteRegStr HKLM "Software\${PRODUCT_NAME}\Installer" "ProfilesDir" "$INSTDIR\Profiles\%USERNAME%"
			GoTo +5
		; ELSE IF
		StrCmp $whereprofiles "$APPDATA\LiteStep" 0 +3
			WriteRegStr HKLM "Software\${PRODUCT_NAME}\Installer" "ProfilesDir" "%APPDATA%\Litestep"
			GoTo +2
		; ELSE
			WriteRegStr HKLM "Software\${PRODUCT_NAME}\Installer" "ProfilesDir" $whereprofiles
		WriteRegStr HKLM "Software\${PRODUCT_NAME}\Installer" "PersonalDir" "$whereprofiles\personal"

		; OTS2 Theme files
		IfFileExists "$whereprofiles\themes\themeslist.rc" 0 AddThemeFiles
			IfFileExists "$whereprofiles\themes\themeselect.rc" SkipThemeFiles

		AddThemeFiles:
		SetOutPath  "$whereprofiles\themes\"
		!insertmacro UNINSTALL.LOG_OPEN_INSTALL
		File /oname=themeselect.rc ".\Personal\themes\themeselect-empty.rc"
		File /oname=themeslist.rc ".\Personal\themes\themeslist-empty.rc"
		!insertmacro UNINSTALL.LOG_CLOSE_INSTALL
		SkipThemeFiles:

		SetOutPath "$INSTDIR"
		!insertmacro UNINSTALL.LOG_OPEN_INSTALL
		File ".\LS\changes.txt"
		File ".\LS\hook.dll"
		File ".\LS\libpng13.dll"
		File ".\LS\license.txt"
		File ".\LS\litestep.exe"
		File ".\LS\lsapi.dll"
		File ".\LS\readme.txt"
		File ".\LS\release_notes.txt"
		File ".\LS\zlib1.dll"
		File ".\LS\xPaintClass-1.0.dll"
		!insertmacro UNINSTALL.LOG_CLOSE_INSTALL

		SetOutPath "$INSTDIR\NLM"
		SetOverwrite on
		!insertmacro UNINSTALL.LOG_OPEN_INSTALL
		File ".\LS\NLM\*"
		!insertmacro UNINSTALL.LOG_CLOSE_INSTALL

		ReadIniStr $0 "system.ini" "boot" "shell"
		${ExePath} $0 $0
		${RIndexOf} $R0 $0 '\' ; Macro expands to 4 lines
		; IF
		IntCmp $R0 -1 0 +3 +3
			StrCpy $currentShell $0
			GoTo +5
		; ELSE
			StrLen $R1 $0
			IntOp $R0 $R1 - $R0
			IntOp $R0 $R0 + 1
			StrCpy $currentShell $0 "" $R0
	
		; IF
		StrCmp $currentShell "" 0 +2
			ReadRegStr $currentShell HKLM "Software\Microsoft\Windows NT\CurrentVersion\Winlogon" "Shell"
	
		; IF
		StrCmp $currentShell "" 0 +2
			StrCpy $currentShell "explorer.exe"

		ReadINIStr $R0 "$PLUGINSDIR\ioHowLS.ini" "Field 4" "State" ;Field 4 is Don't set shell
		IntCmp $R0 1 doneSetShell ;If we're not setting LS as the shell, we're jumping down
		                          ;to doneSetShell

			; Check whether we're installing on a 9x or NT based system
			Call GetWindowsVersion
			Pop $R0

			StrCmp $R0 "9x" 0 setNTShell
				Call setShell9x
				GoTo doneSetShell

			setNTShell:
			;If we get to this point we're not installing on a 9x based machine
			Call setShellNT

		doneSetShell:
		Pop $0

		CreateShortCut "$DESKTOP\Set Explorer as Shell.lnk" '"$INSTDIR\utilities\wxlua.exe"' '"$INSTDIR\utilities\LOSS.lua" explorer' "$INSTDIR\losi\SetShellExplorer.ico"
		CreateShortCut "$DESKTOP\Set LiteStep as Shell.lnk" '"$INSTDIR\utilities\wxlua.exe"' '"$INSTDIR\utilities\LOSS.lua" litestep' "$INSTDIR\losi\SetShellLS.ico"

		SetOverwrite on

		; Install all the modules and their docs
		SetOutPath "$INSTDIR\modules\"
		!insertmacro UNINSTALL.LOG_OPEN_INSTALL
		File /r /x ".svn" ".\LS\modules\*"
		!insertmacro UNINSTALL.LOG_CLOSE_INSTALL

		call backupPersonal

		; Install the personal files
		SetOutPath "$whereprofiles\personal"
		; Don't log these files, they are removed the traditional way
		;!insertmacro UNINSTALL.LOG_OPEN_INSTALL
		File /r /x ".svn" ".\Personal\personal\*"
	
		StrCmp $R9 "LSKilled" 0 wasntRunning
			ExecShell open "$INSTDIR\litestep.exe" ;Launch LiteStep
			StrCpy $hasStartedLS "true"
		wasntRunning:
	SectionEnd
!endif
