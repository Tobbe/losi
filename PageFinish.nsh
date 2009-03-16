; Function SetupFinishPage
;
; This function gets called before the finish page is shown. It
; creates different controls on the finish page depending on
; whether the installer thinks a reboot is needed or not.

Function SetupFinishPage
	ReadINIStr $R0 "$PLUGINSDIR\ioHowLS.ini" "Field 4" "State" ;Field 4 is Don't set shell
	; IF (Don't set as shell != TRUE)
	IntCmp $R0 1 +7 ;Tick and disable the "Run Litestep" checkbox when Litestep is set as shell
	StrCmp $hasStartedLS "true" +7
	    WriteINIStr "$PLUGINSDIR\ioSpecial.ini" "Field 4" "State" "1"
		WriteINIStr "$PLUGINSDIR\ioSpecial.ini" "Field 4" "Flags" "DISABLED"
		WriteINIStr "$PLUGINSDIR\ioSpecial.ini" "Field 4" "Top" "-3200"
		WriteINIStr "$PLUGINSDIR\ioSpecial.ini" "Field 4" "Bottom" "-3199"
		GoTo doneSettingUp
	; ELSE IF ($hasStartedLS == TRUE)
	StrCmp $hasStartedLS "true" 0 doneSettingUp
		; Remove the "Run LiteStep" checkbox. LiteStep is already running.
		; The box is not checked, so the "FinishRun" function will not run.
 		WriteINIStr "$PLUGINSDIR\ioSpecial.ini" "Settings" "NumFields" "3"
doneSettingUp:
FunctionEnd

Function FinishRun
    ReadRegDWORD $R7 HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" "AutoRestartShell"
	WriteRegDWORD HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" "AutoRestartShell" 0
	
	${If} $currentShell == "litestep.exe"
		Push "$INSTDIR"
		Call KillLS
	${Else}
		KillProcDLL::KillProc $currentShell
		Sleep 2000
	${EndIf}

	ExecShell open "$INSTDIR\litestep.exe" ;Launch LiteStep

	; Wait for LiteStep to start
	StrCpy $0 "0"
	Sleep 100
	FindProcDLL::FindProc "litestep.exe"
	Pop $1
	IntOp $0 $0 + 1
	StrCmp $0 50 +2
	StrCmp $1 1 +1 -5

	WriteRegDWORD HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" "AutoRestartShell" $R7
FunctionEnd

!define MUI_PAGE_CUSTOMFUNCTION_PRE SetupFinishPage
;!define MUI_PAGE_CUSTOMFUNCTION_SHOW ShowFinishPage
;!define MUI_PAGE_CUSTOMFUNCTION_LEAVE ValidateFinish

!define MUI_FINISHPAGE_NOREBOOTSUPPORT
!define MUI_FINISHPAGE_NOAUTOCLOSE
!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_RUN_TEXT $(RUN_LS)
!define MUI_FINISHPAGE_RUN_NOTCHECKED
!define MUI_FINISHPAGE_RUN_FUNCTION FinishRun

!insertmacro MUI_PAGE_FINISH