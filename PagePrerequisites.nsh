!ifndef PAGE_PREREQUISITES
!define PAGE_PREREQUISITES
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
			StrCpy $abortWarning "false"
		${EndIf}
		!insertmacro INSTALLOPTIONS_SHOW

		Pop $R5
		Pop $R4
		Pop $R3
		Pop $R2
		Pop $R1
		Pop $R0	
	FunctionEnd
!endif