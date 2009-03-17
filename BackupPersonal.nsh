!include LogicLib.nsh

Function backupPersonal
	Push $0
	Push $1
	Push $2
	Push $3

	StrCpy $3 "not_asked"

	${whereprofilesarray->SizeOf} $R1 $R2 $R3
	IntOp $0 $R3 - 1

	${For} $1 0 $0 ; $1 from 0 to size-1
		${whereprofilesarray->Read} $2 $1

		${If} ${FileExists} "$2\personal\personal.rc"

			; We got here, that means there are old personal files
			; that we maybe should backup...

			${If} $3 == "not_asked"
				MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON1 $(BACKUP_PERSONAL) IDNO end
				StrCpy $3 "asked"
			${EndIf}

			CreateDirectory "$2\personal\backup"
			CopyFiles "$2\personal\*" "$2\personal\backup\"

			StrCpy $langWhereProfiles $2

			MessageBox MB_OK $(BACKUP_DONE)
		${EndIf}
	${Next}

	end:

	Pop $3
	Pop $2
	Pop $1
	Pop $0
FunctionEnd