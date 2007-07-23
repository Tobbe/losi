;reverse what we did in setShell9x

Function un.Shell9x
	ClearErrors
	Push $3
	Push $4
	Push $5
	Push $6

	FileOpen $3 "$SYSDIR\system.ini" r ;Open $SYSDIR\system.ini for reading
	FileOpen $4 $TEMP\tmpsys.ini w ;Create a temporary file
	IfErrors done

	read:
		FileRead $3 $5 ;read the next line in to $5
		IfErrors stopread

		StrCpy $6 $5 7 ;get the first 7 chars from $5
		StrCmp $6 ";shell=" 0 +6
			;We have found the ;shell= line
			StrCpy $6 $5 "" 1 ;remove the ;
			FileWrite $4 $6
			FileRead $3 $5 ;We don't want this line, so we're just going to read it and then ignore it
			GoTo read
		FileWrite $4 $5
		GoTo read

	stopread:
	FileClose $3
	FileClose $4

	;Copy our tmpsys.ini to \system\system.ini by writing it there line by line
	FileOpen $3 "$SYSDIR\system.ini" w ;Open system.ini for writing, this erases all the content from the file
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
FunctionEnd