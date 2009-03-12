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
		${If} ${FileExists} "$INSTDIR\litestep.exe"
			Push "$INSTDIR"
			Call KillLS
			Pop $R9
		${EndIf}

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
		Push $1
		ReadINIStr $0 "$PLUGINSDIR\ioWhereProfiles.ini" "Field 4" "State" ;Field 4 is Documents and Settings
		ReadINIStr $1 "$PLUGINSDIR\ioWhereProfiles.ini" "Field 3" "State" ;Field 3 is LSDir\Profiles

		${If} $0 == 1
			; Install to Documents and Settings
			StrCpy $whereprofiles "$APPDATA\LiteStep"
			!insertmacro UNINSTALL.LOG_OPEN_INSTALL
			File ".\LS\step-das\step.rc" ;das = Documents and Settings :p
			!insertmacro UNINSTALL.LOG_CLOSE_INSTALL
		${ElseIf} $1 == 1
			; Install to LSDir\Profiles
			UserInfo::GetName
			Pop $username
			${If} $username == ""
				; If we get here it means no username was found, probably due to installing on 9x when not logged in
				MessageBox MB_OK $(MB_NO_USER)

				; Don't install any profiles
				StrCpy $0 0
				StrCpy $1 0
			${EndIf}

			StrCpy $whereprofiles "$INSTDIR\Profiles\$username"
			!insertmacro UNINSTALL.LOG_OPEN_INSTALL
			File ".\LS\step-lsdir\step.rc"
			!insertmacro UNINSTALL.LOG_CLOSE_INSTALL
		${EndIf}

		${If} $0 == 0
		${AndIf} $1 == 0
			; Don't install any profiles
			StrCpy $whereprofiles "$INSTDIR"
			!insertmacro UNINSTALL.LOG_OPEN_INSTALL
			File ".\LS\step-none\step.rc"
			!insertmacro UNINSTALL.LOG_CLOSE_INSTALL
		${EndIf}

		Pop $1
		Pop $0

		;; Store a few paths in the registry
		WriteRegStr HKLM "Software\${PRODUCT_NAME}\Installer" "LitestepDir" $INSTDIR

		${If} $whereprofiles == "$INSTDIR\Profiles\$username"
			WriteRegStr HKLM "Software\${PRODUCT_NAME}\Installer" "ProfilesDir" "$INSTDIR\Profiles\%USERNAME%"
		${ElseIf} $whereprofiles == "$APPDATA\LiteStep"
			WriteRegStr HKLM "Software\${PRODUCT_NAME}\Installer" "ProfilesDir" "%APPDATA%\Litestep"
		${Else}
			WriteRegStr HKLM "Software\${PRODUCT_NAME}\Installer" "ProfilesDir" $whereprofiles
		${EndIf}

		WriteRegStr HKLM "Software\${PRODUCT_NAME}\Installer" "PersonalDir" "$whereprofiles\personal"

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

		; Get the current shell
		ReadIniStr $0 "system.ini" "boot" "shell"

		; Strip the path, so we keep only the .exe name
		${ExePath} $0 $0
		${RIndexOf} $R0 $0 '\' ; Macro expands to 4 lines
		
		${If} $R0 == -1
			StrCpy $currentShell $0
		${Else}
			StrLen $R1 $0
			IntOp $R0 $R1 - $R0
			IntOp $R0 $R0 + 1
			StrCpy $currentShell $0 "" $R0
		${EndIf}

		${If} $currentShell == ""
			ReadRegStr $currentShell HKLM "Software\Microsoft\Windows NT\CurrentVersion\Winlogon" "Shell"
		${EndIf}

		${If} $currentShell == ""
			StrCpy $currentShell "explorer.exe"
		${EndIf}

		ReadINIStr $R0 "$PLUGINSDIR\ioHowLS.ini" "Field 4" "State" ;Field 4 is Don't set shell
		${If} $R0 != 1
			; Check whether we're installing on a 9x or NT based system
			Call GetWindowsVersion
			Pop $R0

			${If} $R0 == "9x"
				Call setShell9x
			${Else}
				Call setShellNT
			${EndIf}
		${EndIf}
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

		${If} $R9 == "LSKilled"
			ExecShell open "$INSTDIR\litestep.exe" ;Launch LiteStep
			StrCpy $hasStartedLS "true"
		${EndIf}
	SectionEnd
!endif
