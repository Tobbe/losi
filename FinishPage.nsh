; Function SetupFinishPage
;
; This function gets called before the finish page is shown. It
; creates different controls on the finish page depending on
; whether the installer thinks a reboot is needed or not.

Function SetupFinishPage
	ReadINIStr $R0 "$PLUGINSDIR\ioHowLS.ini" "Field 4" "State" ;Field 4 is Don't set shell
	IntCmp $R0 1 +2 ;Remove the "Run Litestep" checkbox when Litestep is set as shell
	    StrCpy $INSTDIR "C:\Program\Litestep"
		;WriteINIStr "$PLUGINSDIR\ioSpecial.ini" "Settings" "NumFields" "3"
FunctionEnd

Function FinishRun
	; IF
	StrCmp $currentShell "litestep.exe" 0 +4
	    Push "$INSTDIR"
		Call KillLS
		GoTo execLS
	; ELSE
		KillProcDLL::KillProc $currentShell
		Sleep 2000
execLS:
	ExecShell open "$INSTDIR\litestep.exe" ;Launch LiteStep
FunctionEnd