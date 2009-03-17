!ifndef ENUM_LOGIN_USERS_NSH
!define ENUM_LOGIN_USERS_NSH

!include EnumerateUsers.nsh
!include LogicLib.nsh
!include IndexOf.nsh
!include NSISArray.nsh

${Array} EnumLoginUsersArray 5 ${NSIS_MAX_STRLEN}
${ArrayFunc} Read
${ArrayFunc} Write
${ArrayFunc} Shift
${ArrayFunc} SizeOf
${ArrayFunc} Swap
${ArrayFunc} Debug

Function EnumLoginUsers
	Push $0 ; Array name -- not used
	Push $1 ; General return values
	Push $2 ; Temp
	Push $3 ; Temp
	Push $4 ; Added user
	Push $5
	Push $6 ; Array index
	Push $7 ; Number of users
	Push $8 ; For loop counter
	Push $9 ; User name

	; Done elsewhere ${EnumLoginUsersArray->Init}
	
	StrCpy $6 0 ; Initialize array index
	StrCpy $4 "FALSE" ; Initialize Added user value
	
	${EnumerateUsers} ""

	${EnumerateUsersArray->SizeOf} $1 $1 $1
	IntOp $7 $1 - 1
	${For} $8 0 $7 ; $8 from 0 to size-1
	    StrCpy $4 "FALSE" ; Reset Added user value
	    
		;NSISArray::Read /NOUNLOAD EnumLoginUsersUserArray $8
		;Pop $9 ; Store user name in $9
		${EnumerateUsersArray->Read} $9 $8

		UserMgr::GetLocalizedStdAccountName "S-1-5-32-544" ; Administrators
	    Pop $1
	    
	    ; Save everything to the right of the last backslash
	    ${RIndexOf} $2 $1 "\"
	    StrLen $3 $1
	    IntOp $3 $3 - $2
    	IntOp $3 $3 + 1
	    StrCpy $1 $1 "" $3

	    UserMgr::IsMemberOfGroup "$9" "$1" ; Is the user in the Administrators group?
	    Pop $1
	    
	    ${If} $1 == "TRUE"
	        UserMgr::HasPrivilege "$9" "SeDenyInteractiveLogonRight"
		    Pop $1
		    
		    ${If} $1 != "TRUE"
				;NSISArray::Write /NOUNLOAD $0 $6 "$9"
				${EnumLoginUsersArray->Write} $6 "$9"
		        IntOp $6 $6 + 1
			${EndIf}
			
            StrCpy $4 "TRUE"
		${EndIf}

		${If} $4 == "FALSE"
			UserMgr::GetLocalizedStdAccountName "S-1-5-32-545" ; Users
		    Pop $1

		    ; Save everything to the right of the last backslash
		    ${RIndexOf} $2 $1 "\"
		    StrLen $3 $1
		    IntOp $3 $3 - $2
	    	IntOp $3 $3 + 1
		    StrCpy $1 $1 "" $3

		    UserMgr::IsMemberOfGroup "$9" "$1" ; Is the user in the Users group?
		    Pop $1

		    ${If} $1 == "TRUE"
		        UserMgr::HasPrivilege "$9" "SeDenyInteractiveLogonRight"
			    Pop $1

			    ${If} $1 != "TRUE"
			        ;NSISArray::Write /NOUNLOAD $0 $6 "$9"
			        ${EnumLoginUsersArray->Write} $6 "$9"
			        IntOp $6 $6 + 1
				${EndIf}

                StrCpy $4 "TRUE"
			${EndIf}
		${EndIf}

		${If} $4 == "FALSE"
			UserMgr::GetLocalizedStdAccountName "S-1-5-32-547" ; Power users
		    Pop $1

		    ; Save everything to the right of the last backslash
		    ${RIndexOf} $2 $1 "\"
		    StrLen $3 $1
		    IntOp $3 $3 - $2
	    	IntOp $3 $3 + 1
		    StrCpy $1 $1 "" $3

		    UserMgr::IsMemberOfGroup "$9" "$1" ; Is the user in the Power users group?
		    Pop $1

		    ${If} $1 == "TRUE"
		        UserMgr::HasPrivilege "$9" "SeDenyInteractiveLogonRight"
			    Pop $1

			    ${If} $1 != "TRUE"
			        ;NSISArray::Write /NOUNLOAD $0 $6 "$9"
			        ${EnumLoginUsersArray->Write} $6 "$9"
			        IntOp $6 $6 + 1
				${EndIf}

				StrCpy $4 "TRUE"
			${EndIf}
		${EndIf}
	${Next}


	; Move the name of the currently logged in used
	; to the start of the array

	UserMgr::GetCurrentUserName
	Pop $1

	${EnumLoginUsersArray->SizeOf} $2 $2 $2
	IntOp $7 $2 - 1
	StrCpy $3 -1
	${For} $8 0 $7 ; $8 from 0 to size-1
		${EnumLoginUsersArray->Read} $9 $8

		${If} $9 == $1
		    StrCpy $3 $8
		    IntOp $8 $7 + 1 ; End loop
		${EndIf}
	${Next}

    ;NSISArray::Swap /NOUNLOAD $0 0 $3
    ${EnumLoginUsersArray->Swap} 0 $3

	Pop $9
	Pop $8
	Pop $7
	Pop $6
	Pop $5
	Pop $4
	Pop $3
	Pop $2
	Pop $1
	Pop $0
FunctionEnd

!macro EnumLoginUsers
	Call EnumLoginUsers
!macroend

!define EnumLoginUsers "!insertmacro EnumLoginUsers"



${Array} un.EnumLoginUsersArray 5 ${NSIS_MAX_STRLEN}
${ArrayFunc} Read
${ArrayFunc} Write
${ArrayFunc} Shift
${ArrayFunc} SizeOf
${ArrayFunc} Swap

Function un.EnumLoginUsers
	Push $0 ; Array name -- not used
	Push $1 ; General return values
	Push $2 ; Temp
	Push $3 ; Temp
	Push $4 ; Added user
	Push $5
	Push $6 ; Array index
	Push $7 ; Number of users
	Push $8 ; For loop counter
	Push $9 ; User name

	${un.EnumLoginUsersArray->Init}
	
	StrCpy $6 0 ; Initialize array index
	StrCpy $4 "FALSE" ; Initialize Added user value
	
	${un.EnumerateUsers} ""

	${un.EnumerateUsersArray->SizeOf} $1 $1 $1
	IntOp $7 $1 - 1
	${For} $8 0 $7 ; $8 from 0 to size-1
	    StrCpy $4 "FALSE" ; Reset Added user value
	    
		;NSISArray::Read /NOUNLOAD EnumLoginUsersUserArray $8
		;Pop $9 ; Store user name in $9
		${un.EnumerateUsersArray->Read} $9 $8

		UserMgr::GetLocalizedStdAccountName "S-1-5-32-544" ; Administrators
	    Pop $1
	    
	    ; Save everything to the right of the last backslash
	    ${un.RIndexOf} $2 $1 "\"
	    StrLen $3 $1
	    IntOp $3 $3 - $2
    	IntOp $3 $3 + 1
	    StrCpy $1 $1 "" $3

	    UserMgr::IsMemberOfGroup "$9" "$1" ; Is the user in the Administrators group?
	    Pop $1
	    
	    ${If} $1 == "TRUE"
	        UserMgr::HasPrivilege "$9" "SeDenyInteractiveLogonRight"
		    Pop $1
		    
		    ${If} $1 != "TRUE"
				${un.EnumLoginUsersArray->Write} $6 "$9"
		        IntOp $6 $6 + 1
			${EndIf}
			
            StrCpy $4 "TRUE"
		${EndIf}

		${If} $4 == "FALSE"
			UserMgr::GetLocalizedStdAccountName "S-1-5-32-545" ; Users
		    Pop $1

		    ; Save everything to the right of the last backslash
		    ${un.RIndexOf} $2 $1 "\"
		    StrLen $3 $1
		    IntOp $3 $3 - $2
	    	IntOp $3 $3 + 1
		    StrCpy $1 $1 "" $3

		    UserMgr::IsMemberOfGroup "$9" "$1" ; Is the user in the Users group?
		    Pop $1

		    ${If} $1 == "TRUE"
		        UserMgr::HasPrivilege "$9" "SeDenyInteractiveLogonRight"
			    Pop $1

			    ${If} $1 != "TRUE"
			        ${un.EnumLoginUsersArray->Write} $6 "$9"
			        IntOp $6 $6 + 1
				${EndIf}

                StrCpy $4 "TRUE"
			${EndIf}
		${EndIf}

		${If} $4 == "FALSE"
			UserMgr::GetLocalizedStdAccountName "S-1-5-32-547" ; Power users
		    Pop $1

		    ; Save everything to the right of the last backslash
		    ${un.RIndexOf} $2 $1 "\"
		    StrLen $3 $1
		    IntOp $3 $3 - $2
	    	IntOp $3 $3 + 1
		    StrCpy $1 $1 "" $3

		    UserMgr::IsMemberOfGroup "$9" "$1" ; Is the user in the Power users group?
		    Pop $1

		    ${If} $1 == "TRUE"
		        UserMgr::HasPrivilege "$9" "SeDenyInteractiveLogonRight"
			    Pop $1

			    ${If} $1 != "TRUE"
			        ${un.EnumLoginUsersArray->Write} $6 "$9"
			        IntOp $6 $6 + 1
				${EndIf}

				StrCpy $4 "TRUE"
			${EndIf}
		${EndIf}
	${Next}


	; Move the name of the currently logged in used
	; to the start of the array

	UserMgr::GetCurrentUserName
	Pop $1

	${un.EnumLoginUsersArray->SizeOf} $2 $2 $2
	IntOp $7 $2 - 1
	StrCpy $3 -1
	${For} $8 0 $7 ; $8 from 0 to size-1
		${un.EnumLoginUsersArray->Read} $9 $8

		${If} $9 == $1
		    StrCpy $3 $8
		    IntOp $8 $7 + 1 ; End loop
		${EndIf}
	${Next}

    ${un.EnumLoginUsersArray->Swap} 0 $3

	Pop $9
	Pop $8
	Pop $7
	Pop $6
	Pop $5
	Pop $4
	Pop $3
	Pop $2
	Pop $1
	Pop $0
FunctionEnd

!macro un.EnumLoginUsers
	Call un.EnumLoginUsers
!macroend

!define un.EnumLoginUsers "!insertmacro un.EnumLoginUsers"

!endif