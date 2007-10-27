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
	Pop $R1
	FindProcDLL::FindProc "litestep.exe"
    StrCmp $R0 1 foundls lsnotfound
    foundls:
		Exec "$R1\litestep.exe !quit" ; Be nice when shutting down
		Sleep 2000
		FindProcDLL::FindProc "litestep.exe"
    	StrCmp $R0 1 +1 lsnotfound
        	KillProcDLL::KillProc "litestep.exe"
        	Sleep 2000
        	MessageBox MB_OK $(MB_FOUND_LS_UNINST)
    lsnotfound:
FunctionEnd