; Kill litestep if found
Function KillLS
	FindProcDLL::FindProc "litestep.exe"
    StrCmp $R0 1 foundls lsnotfound
    foundls:
        KillProcDLL::KillProc "litestep.exe"
        Sleep 2000
        MessageBox MB_OK $(MB_FOUND_LS)
        StrCpy $R0 "LSKilled"
        GoTo end
    lsnotfound:
		StrCpy $R0 "NoLS"
		
	end:
		Push $R0
FunctionEnd

Function un.KillLS ; For the uninstaller
	FindProcDLL::FindProc "litestep.exe"
    StrCmp $R0 1 foundls lsnotfound
    foundls:
        KillProcDLL::KillProc "litestep.exe"
        Sleep 2000
        MessageBox MB_OK $(MB_FOUND_LS_UNINST)
    lsnotfound:
FunctionEnd