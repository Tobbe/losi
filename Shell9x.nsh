;comment out the current shell= line from system.ini
;add a new shell= line that points to litestep.exe

Function setShell9x
	ClearErrors
	Push $3
	Push $4
	Push $5
	Push $6
	
	FileOpen $3 "$WINDIR\system.ini" r ;Open $WINDIR\system.ini for reading
	FileOpen $4 $TEMP\tmpsys.ini w ;Create a temporary file
	IfErrors done
	
    GetFullPathName /SHORT $R2 $INSTDIR
	
	read:
		FileRead $3 $5 ;read the next line in to $5
		IfErrors stopread
		
		StrCpy $6 $5 6 ;get the first 6 chars from $5
		StrCmp $6 "shell=" 0 +6
			;We have found the shell= line
			FileWrite $4 ";$5" ;Comment it out
			FileWrite $4 'shell="$R2\litestep.exe"' ;Add a new shell= line that points to litestep
			FileWriteByte $4 "13" ;Carriage Return
			FileWriteByte $4 "10" ;Line Feed
			GoTo read
		FileWrite $4 $5
		GoTo read
		
	stopread:
	FileClose $3
	FileClose $4
	
	;Copy our tmpsys.ini to \system\system.ini by writing it there line by line
	FileOpen $3 "$WINDIR\system.ini" w ;Open system.ini for writing, this erases all the content from the file
	FileOpen $4 $TEMP\tmpsys.ini r
	IfErrors done
	
	write:
		FileRead $4 $5 ;read from tmpsys in to $5
		IfErrors stopwrite
		
		FileWrite $3 $5
		GoTo write
		
	stopwrite:
	FileClose $3
	FileClose $4
	
	done:
	Pop $3
	Pop $4
	
	SetRebootFlag true ;We are setting LS as the shell, so the computer should be rebooted
	
FunctionEnd