!ifndef GET_IN_QUOTES_NSH
!define GET_IN_QUOTES_NSH

; Push 'a string containing "quotes"!'
; Call GetInQuotes
; Pop $R0 ; = quotes
;
; If no paired quotes are found, the function will return an empty string.
;
; Written by Stu

Function GetInQuotes
Exch $R0
Push $R1
Push $R2
Push $R3

 StrCpy $R2 -1
 IntOp $R2 $R2 + 1
  StrCpy $R3 $R0 1 $R2
  StrCmp $R3 "" 0 +3
   StrCpy $R0 ""
   Goto Done
  StrCmp $R3 '"' 0 -5

 IntOp $R2 $R2 + 1
 StrCpy $R0 $R0 "" $R2

 StrCpy $R2 0
 IntOp $R2 $R2 + 1
  StrCpy $R3 $R0 1 $R2
  StrCmp $R3 "" 0 +3
   StrCpy $R0 ""
   Goto Done
  StrCmp $R3 '"' 0 -5

 StrCpy $R0 $R0 $R2
 Done:

Pop $R3
Pop $R2
Pop $R1
Exch $R0
FunctionEnd

!endif