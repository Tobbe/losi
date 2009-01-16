!ifndef UN_START_EXPLORER_NSH
!define UN_START_EXPLORER_NSH

!include Kill.nsh

; I can't just do something like 'ExecShell "open" "explorer.exe"' because
; that would make the Add/Remove Programs dialog freeze until explorer was 
; killed.  It has this check that makes it wait for every subprocess of the 
; installer to quit before you can interact with it again.  So the way I make it 
; work now is by using window's built in feature to restart the shell whenever 
; it's unexpectedly killed.

Function un.StartExplorer
	; This whole trick wont work if there are any explorer windows open
	Call un.KillExplorer
	Sleep 500

	; Make sure the "restart shell" feature is turned on. (Back up the old 
	; value first)
	ReadRegDWORD $0 HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" "AutoRestartShell"
	WriteRegDWORD HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" "AutoRestartShell" 1

	; Make LS the shell
	FileOpen $1 "$INSTDIR\step.rc" w
	FileWrite $1 "LSSetAsShell"
	FileClose $1

	; Start Litestep as a "real" shell (LSSetAsShell forces LS to call SetShellWindow)
	Exec "$INSTDIR\litestep.exe"
	Sleep 2000 ; Give LS two seconds to start

	FindProcDLL::FindProc "litestep.exe"
	Sleep 50
	${If} $R0 != 1
		; LS still isn't running, wait another second
		Sleep 1000
	${EndIf}

	; Kill Litestep. This should make explorer start
	Push $INSTDIR
	Call un.KillLS
	
	; Give Windows a couple of seconds to realize its shell just died.
	Sleep 2000
	
	FindProcDLL::FindProc "explorer.exe"
	Sleep 50
	${If} $R0 != 1
		; Explorer still isn't running, wait another second
		Sleep 1000
	${EndIf}

	; Change back the value of "AutoRestartShell"
	WriteRegDWORD HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" "AutoRestartShell" $0
FunctionEnd

Function un.StartExplorerByKillingExplorer
	; Make sure the "restart shell" feature is turned on. (Back up the old 
	; value first)
	ReadRegDWORD $0 HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" "AutoRestartShell"
	WriteRegDWORD HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" "AutoRestartShell" 1
	
	Exec "explorer.exe"
	
	; Wait for explorer.exe to start
	StrCpy $R1 0
	${While} $R1 < 10
		FindProcDLL::FindProc "explorer.exe"
		${If} $R0 == 1
			StrCpy $R1 10
		${Else}
			Sleep 1000
			IntOp $R1 $R1 + 1
		${EndIf}
	${EndWhile}

	KillProcDLL::KillProc "explorer.exe"
	
	Sleep 2000 ; Give explorer some time to die
	
	; Wait for explorer to start again.
	; Now when it starts it will not be owned by the uninstaller's process
	; and we will not freeze the add/remove programs dialog.
	StrCpy $R1 0
	${While} $R1 < 8
		FindProcDLL::FindProc "explorer.exe"
		${If} $R0 == 1
			StrCpy $R1 10
		${Else}
			Sleep 1000
			IntOp $R1 $R1 + 1
		${EndIf}
	${EndWhile}
	
	; Change back the value of "AutoRestartShell"
	WriteRegDWORD HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" "AutoRestartShell" $0
FunctionEnd
	
!endif