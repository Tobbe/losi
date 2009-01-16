!ifndef KILL_FUNCTIONS_NSH
!define KILL_FUNCTIONS_NSH

; Kill litestep if found
Function KillLS
    Pop $R1
    Push $R2
	FindProcDLL::FindProc "litestep.exe"
    StrCmp $R0 1 foundls lsnotfound
    foundls:
        Sleep 50
		Exec "$R1\litestep.exe !quit" ; Be nice when shutting down
		Sleep 2000
		FindProcDLL::FindProc "litestep.exe"
		Sleep 50
		StrCpy $R2 "LSKilled"
    	StrCmp $R0 1 +1 end
    	    Sleep 50
        	KillProcDLL::KillProc "litestep.exe"
        	Sleep 2000
        	FindProcDLL::FindProc "litestep.exe"
        	Sleep 50
        	StrCmp $R0 1 +1 end
        		MessageBox MB_OK $(MB_FOUND_LS_UNINST)
        GoTo end
    lsnotfound:
		StrCpy $R2 "NoLS"
		
	end:
		Exch $R2
FunctionEnd

Function un.KillLS ; For the uninstaller
	Pop $R1
	FindProcDLL::FindProc "litestep.exe"
    StrCmp $R0 1 foundls lsnotfound
    foundls:
        Sleep 50
		Exec "$R1\litestep.exe !quit" ; Be nice when shutting down
		Sleep 2000
		FindProcDLL::FindProc "litestep.exe"
		Sleep 50
    	StrCmp $R0 1 +1 lsnotfound
    	    Sleep 50
        	KillProcDLL::KillProc "litestep.exe"
        	Sleep 2000
        	FindProcDLL::FindProc "litestep.exe"
			Sleep 50
	    	StrCmp $R0 1 +1 lsnotfound
        		MessageBox MB_OK $(MB_FOUND_LS_UNINST)
    lsnotfound:
FunctionEnd

Function un.KillExplorer ; For the uninstaller
	Pop $R1
	FindProcDLL::FindProc "explorer.exe"
    ${If} $R0 == 1
        Sleep 50
		KillProcDLL::KillProc "explorer.exe"
		Sleep 2000
		FindProcDLL::FindProc "explorer.exe"
		Sleep 50
    	${If} $R0 == 1
    	    Sleep 50
        	KillProcDLL::KillProc "explorer.exe"
        	Sleep 50
        ${EndIf}
    ${EndIf}
FunctionEnd

!endif