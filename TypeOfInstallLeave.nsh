Function TypeOfInstallLeave
    ReadINIStr $0 "$PLUGINSDIR\ioSpecial.ini" "Settings" "State" ;What caused this function to be called?
	MessageBox MB_OK $0
    StrCmp $0 0 finish ;The "Finish" button
    Abort

finish:
	;Do stuff here

FunctionEnd