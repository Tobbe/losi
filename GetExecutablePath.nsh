!ifndef GET_EXECUTABLE_PATH_NSH
!define GET_EXECUTABLE_PATH_NSH

Function GetExecutablePath
	exch $0 ; Execution string - Top element in stack is now what ever value $0 had before
	push $R0
	push $R1
	push $R2

	StrLen $R0 $0
	IntCmp $R0 2 done done ; If the length of the full path is two or less there
						   ; is nothing we can do, so jump straigt to "done"

	StrCpy $R1 $0 ; $R1 is now the full path plus any extra that were 
	              ; sent to this function

	StrCpy $R0 $0 1
	; If the first character isn't a quote ("), skip the following three lines
	StrCmp $R0 '"' 0 +4
		push $0
		Call GetInQuotes ; If $0 == 'abc "def" ghi' it will return 'def'
		pop $0

	ExpandEnvStrings $0 $0 ; Built in nsis function. Makes i.e. %WINDIR% 
	                       ; become C:\Windows

	loop:
		IfFileExists $0 done 0
		; ${RIndexOf} $R0 $0 " " will search for the first occurrence of a 
		; space (" ") from the right. The position of the space will be saved
		; in $R0. Returns -1 if no space was found.
		${RIndexOf} $R0 $0 " " ;This will expand to 4 lines because of the macro
		IntCmp $R0 -1 nofile nofile
		StrCpy $0 $0 -$R0 ; Remove the space and anything to the right of it
	GoTo loop

	nofile:
		StrCpy $0 $R1 ; Restore the original value
		StrCpy $R0 $0 "" -3 ; Copy the last three characters from $0 to $R0
		StrCmp $R0 " %1" 0 +3
			StrCpy $0 $0 -3 ; Remove " %1" from the end of $0
			GoTo done
		StrCpy $R0 $0 "" -5
		StrCmp $R0 ' "%1"' 0 done
			StrCpy $0 $0 -5 ; Remove ' "%1"' from the end of $0

	done:
	pop $R2
	pop $R1
	pop $R0
	exch $0
FunctionEnd

!macro ExePath Var Str
	Push "${Str}"
	Call GetExecutablePath
	Pop "${Var}"
!macroend

!define ExePath "!insertmacro ExePath"

!endif