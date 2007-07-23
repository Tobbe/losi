Function GetExecutablePath
	exch $0 ; Execution string - Top element in stack is now what ever value $0 had before
	push $R0
	push $R1
	push $R2

	StrLen $R0 $0
	IntCmp $R0 2 done done

	StrCpy $R1 $0

	StrCpy $R0 $0 1
	StrCmp $R0 '"' 0 +4
		push $0
		Call GetInQuotes
		pop $0

	ExpandEnvStrings $0 $0

	loop:
		IfFileExists $0 done 0
        ${RIndexOf} $R0 $0 " " ;This will expand to 4 lines because of the macro
        IntCmp $R0 -1 nofile nofile
	    StrCpy $0 $0 -$R0
	GoTo loop
	nofile:
	    StrCpy $0 $R1
	    StrCpy $R0 $0 "" -3
	    StrCmp $R0 " %1" 0 +3
	        StrCpy $0 $0 -3
	        GoTo done
		StrCpy $R0 $0 "" -5
		StrCmp $R0 ' "%1"' 0 done
		    StrCpy $0 $0 -5


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