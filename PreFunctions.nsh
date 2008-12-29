Function PreAdvanced
	; Only run this check if the TypeOfInstall page is used
	!ifdef PAGE_TYPE_OF_INSTALL
	StrCmp $advancedInstall "true" +2
	Abort
	!endif
FunctionEnd

Function PreDir
	Push $R0
	Push $R1
    ${LongPath} $R0 $INSTDIR
    StrCpy $R1 $R0 "" -1 ; Copy the last character of $R0 to $R1
    StrCmp $R1 "\" 0 +3 ;Make sure the path ends with exactly one backslash (\)
    	StrCpy $INSTDIR "$R0"
    	GoTo +2
		StrCpy $INSTDIR "$R0\"
FunctionEnd