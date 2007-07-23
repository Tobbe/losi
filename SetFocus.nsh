;----------------------------------------------------------------------------
; Title             : Set focus to a control
; Short Name        : SetFocus
; Last Changed      : 22/Feb/2005
; Code Type         : Function
; Code Sub-Type     : One-way Input
;----------------------------------------------------------------------------
; Required          : InstallOptions and System plugins.
; Description       : Sets focus to a control using InstallOptions.
;----------------------------------------------------------------------------
; Function Call     : Push "Page.ini"
;                       Page .ini file where the field can be found.
;
;                     Push "Handle"
;                       Page handle you got when reserving the page.
;
;                     Push "Number"
;                       Field number to set focus.
;
;                     Call SetFocus
;----------------------------------------------------------------------------
; Author            : Diego Pedroso
; Author Reg. Name  : deguix
;----------------------------------------------------------------------------

Function SetFocus

  Exch $0 ; Control Number
  Exch
  Exch $2 ; Page Handle
  Exch
  Exch 2
  Exch $3 ; Page INI File
  Exch 2
  Push $1
  Push $R0
  Push $R1
  Push $R2
  Push $R3
  Push $R4
  Push $R5

  IntOp $1 $0 + 1199
  GetDlgItem $1 $2 $1

  # Send WM_SETFOCUS message
  System::Call "user32::SetFocus(i r1, i 0x0007, i,i)i"

  ReadINIStr $R0 "$3" "Field $0" "Left"
  ReadINIStr $R1 "$3" "Field $0" "Right"
  ReadINIStr $R3 "$3" "Field $0" "Top"
  ReadINIStr $R4 "$3" "Field $0" "Bottom"
  IntOp $R2 $R1 - $R0
  IntOp $R5 $R4 - $R3

  System::Call "user32::CreateCaret(i r0, i, i R2, i R5)i"
  System::Call "user32::ShowCaret(i r0)i"

  Pop $R5
  Pop $R4
  Pop $R3
  Pop $R2
  Pop $R1
  Pop $R0
  Pop $1
  Pop $0
  Pop $2
  Pop $3

FunctionEnd