# 2007-12-23
# To do all this without rebooting or even logging off, this is what needs to be done:
#   Change the Shell value in IniFileMappings, something like this:
#       WriteRegStr HKLM "Software\Microsoft\Windows NT\CurrentVersion\IniFileMapping\system.ini\boot" "Shell" "USR:Software\Microsoft\Windows NT\CurrentVersion\Winlogon"
#   Refresh Windows' ini files cache, something like this:
#       WritePrivateProfileString(NULL, NULL, NULL, "system.ini") [C code]
#       WriteINIStr "system.ini"     <-- might work
#   Change to the new shell, something like this:
#       WritePrivateProfileString("boot", "shell", <path to shell>, "system.ini") [C code]
#       WriteINIStr "system.ini" "boot" "shell" <path to shell>    <-- probably works

Function setShellNT
	; Check to see if this is the first time LS is installed on this computer.
	; We don't want to overwrite previous values
	ReadRegStr $0 HKLM "Software\${PRODUCT_NAME}\Installer\Uninstaller" "CUDesktopProcess"
	StrCmp $0 "" 0 setAsShell
		ReadRegStr $0 HKLM "Software\Microsoft\Windows NT\CurrentVersion\IniFileMapping\system.ini\boot" "Shell"
		WriteRegStr HKLM "Software\${PRODUCT_NAME}\Installer\Uninstaller" "LMBShell" $0

		ReadRegStr $0 HKLM "Software\Microsoft\Windows NT\CurrentVersion\Winlogon" "Shell"
		WriteRegStr HKLM "Software\${PRODUCT_NAME}\Installer\Uninstaller" "LMShell" $0

		ReadRegDWORD $0 HKCU "Software\Microsoft\Windows\CurrentVersion\Explorer" "DesktopProcess"
		WriteRegDWORD HKLM "Software\${PRODUCT_NAME}\Installer\Uninstaller" "CUDesktopProcess" $0

		ReadRegStr $0 HKCU "Software\Microsoft\Windows NT\CurrentVersion\Winlogon" "Shell"
		WriteRegStr HKLM "Software\${PRODUCT_NAME}\Installer\Uninstaller" "CUShell" $0

	setAsShell:
    ;Current User Desktop Process
    WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Explorer" "DesktopProcess" 1

    ReadINIStr $0 "$PLUGINSDIR\ioHowLS.ini" "Field 2" "State" ;Field 2 is All Users
	ReadINIStr $1 "$PLUGINSDIR\ioHowLS.ini" "Field 3" "State" ;Field 3 is Current User

	${If} $0 == 1
	${OrIf} $1 == 1
		${If} $0 == 1
			; All users

			; Set shell folders to all users - only admins can do this
			SetShellVarContext all

			; Make sure the shell redirecion value is SYS: (the default)
			WriteRegStr HKLM "Software\Microsoft\Windows NT\CurrentVersion\IniFileMapping\system.ini\boot" "Shell" "SYS:Microsoft\Windows NT\CurrentVersion\Winlogon"

			; Refresh window's ini files cashe
			WriteINIStr "system.ini" "" "" ""
		${Else}
			; Current User

			; Tell Windows there might be a shell setting in HKCU
			WriteRegStr HKLM "Software\Microsoft\Windows NT\CurrentVersion\IniFileMapping\system.ini\boot" "Shell" "USR:Software\Microsoft\Windows NT\CurrentVersion\Winlogon"

			; Refresh window's ini files cashe
			WriteINIStr "system.ini" "" "" ""
		${EndIf}

		; Change to the new shell
		WriteINIStr "system.ini" "boot" "shell" "$INSTDIR\litestep.exe"
	${EndIf}
FunctionEnd