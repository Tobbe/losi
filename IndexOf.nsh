; IndexOf & RIndexOf: Find index of character in string
; -----------------------------------------------------
;
; These two functions find the index of a character in a string from left (IndexOf)
; or from the right (RIndexOf). For the default behaviour of StrCpy, IndexOf returns
; the character index as zero-based, whereas RIndexOf does not (starts at 1 from
; the end).
;
; Usage:
; ------
; ${IndexOf}  $R0 "blah" "a" ; $R0 = 2
; ${RIndexOf} $R0 "blah" "b" ; $R0 = 4
;
; Written by Stu

!if 1 = 2 ;I don't need this function, the installer doesn't currently use it. 2007-01-20
Function IndexOf
  Exch $R0
  Exch
  Exch $R1
  Push $R2
  Push $R3

    StrCpy $R3 $R0
    StrCpy $R0 -1
    IntOp $R0 $R0 + 1
      StrCpy $R2 $R3 1 $R0
      StrCmp $R2 "" +2
      StrCmp $R2 $R1 +2 -3

    StrCpy $R0 -1

  Pop $R3
  Pop $R2
  Pop $R1
  Exch $R0
FunctionEnd

!macro IndexOf Var Str Char
  Push "${Char}"
  Push "${Str}"
    Call IndexOf
  Pop "${Var}"
!macroend

!define IndexOf "!insertmacro IndexOf"
!endif

Function RIndexOf
  Exch $R0
  Exch
  Exch $R1
  Push $R2
  Push $R3

    StrCpy $R3 $R0
    StrCpy $R0 0
    IntOp $R0 $R0 + 1
      StrCpy $R2 $R3 1 -$R0
      StrCmp $R2 "" +2
      StrCmp $R2 $R1 +2 -3

    StrCpy $R0 -1

  Pop $R3
  Pop $R2
  Pop $R1
  Exch $R0
FunctionEnd

!macro RIndexOf Var Str Char
  Push "${Char}"
  Push "${Str}"
    Call RIndexOf
  Pop "${Var}"
!macroend

!define RIndexOf "!insertmacro RIndexOf"