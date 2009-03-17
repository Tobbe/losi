!ifndef ENUMERATE_USERS_NSH
!define ENUMERATE_USERS_NSH

# Enumerate the local users
# http://nsis.sourceforge.net/User_Management_using_API_calls#Enumerate_all_users
# Small modifications made by me (Tobbe)
#
# Usage:
# !include NSISArray.nsh
# ${EnumerateUsers} "\\ComputerName" "LocalUsersArray"

${Array} "EnumerateUsersArray" 10 ${NSIS_MAX_STRLEN}
${ArrayFunc} Read
${ArrayFunc} Write
${ArrayFunc} Shift
${ArrayFunc} SizeOf
${ArrayFunc} Inited
${ArrayFunc} Clear
${ArrayFunc} Debug

!macro EnumerateUsers SERVER_NAME
	Push $R0
	Push $R1
	Push $R2
	Push $R3
	Push $R4
	!define IndexEnumUsrs "Line${__LINE__}"

	# NET_API_STATUS NetUserEnum(
	#     __in     LPCWSTR servername,
	#     __in     DWORD level,          // 0 - Return user account names.
	#     __in     DWORD filter,         // 2 - Enumerates global user account data on a computer.
	#     __out    LPBYTE *bufptr,
	#     __in     DWORD prefmaxlen,
	#     __out    LPDWORD entriesread,
	#     __out    LPDWORD totalentries,
	#     __inout  LPDWORD resume_handle // If resume_handle is NULL, then no resume handle is stored.
	# );

	# $R1 holds the number of entries processed
	System::Call 'netapi32::NetUserEnum(w "${SERVER_NAME}", i 0, i 2, *i .R0, i ${NSIS_MAX_STRLEN}, *i .R1, *i .R2, i n) i .R3'
	StrCpy $R2 $R0 ; Needed to free the buffer later

	${EnumerateUsersArray->Init}

	# check for error
	StrCmp $R3 0 +1 ${IndexEnumUsrs}-end

	StrCpy $R4 0
	${IndexEnumUsrs}-loop:
		StrCmp $R4 $R1 ${IndexEnumUsrs}-stop +1
		System::Call '*$R0(w.R3)'
		${EnumerateUsersArray->Write} $R4 "$R3"
		IntOp $R0 $R0 + 4 ; Go to next pointer
		IntOp $R4 $R4 + 1
		Goto ${IndexEnumUsrs}-loop
	${IndexEnumUsrs}-stop:

	# Check that the size of the array is equal to the number of users on the computer
	${EnumerateUsersArray->SizeOf} $R7 $R8 $R0
	StrCmp $R0 $R1 ${IndexEnumUsrs}-end
		MessageBox MB_OK|MB_ICONEXCLAMATION 'Could not place all the user accounts into an array!'

	${IndexEnumUsrs}-end:

	# Cleanup
	StrCmp $R2 0 +2
		System::Call 'netapi32.dll::NetApiBufferFree(i R2) i .R0'

	!undef IndexEnumUsrs
	Pop $R4
	Pop $R3
	Pop $R2
	Pop $R1
	Pop $R0
!macroend

!define EnumerateUsers "!insertmacro EnumerateUsers"





${Array} "un.EnumerateUsersArray" 10 ${NSIS_MAX_STRLEN}
${ArrayFunc} Read
${ArrayFunc} Write
${ArrayFunc} SizeOf

!macro un.EnumerateUsers SERVER_NAME
	Push $R0
	Push $R1
	Push $R2
	Push $R3
	Push $R4
	!define IndexEnumUsrs "Line${__LINE__}"

	# $R1 holds the number of entries processed
	System::Call 'netapi32::NetUserEnum(w "${SERVER_NAME}", i 0, i 2, *i .R0, i ${NSIS_MAX_STRLEN}, *i .R1, *i .R2, i n) i .R3'
	StrCpy $R2 $R0 ; Needed to free the buffer later

	${un.EnumerateUsersArray->Init}

	# check for error
	StrCmp $R3 0 +1 ${IndexEnumUsrs}-end

	StrCpy $R4 0
	${IndexEnumUsrs}-loop:
		StrCmp $R4 $R1 ${IndexEnumUsrs}-stop +1
		System::Call '*$R0(w.R3)'
		${un.EnumerateUsersArray->Write} $R4 "$R3"
		IntOp $R0 $R0 + 4 ; Go to next pointer
		IntOp $R4 $R4 + 1
		Goto ${IndexEnumUsrs}-loop
	${IndexEnumUsrs}-stop:

	# Check that the size of the array is equal to the number of users on the computer
	${un.EnumerateUsersArray->SizeOf} $R7 $R8 $R0
	StrCmp $R0 $R1 ${IndexEnumUsrs}-end
		MessageBox MB_OK|MB_ICONEXCLAMATION 'Could not place all the user accounts into an array!'

	${IndexEnumUsrs}-end:

	# Cleanup
	StrCmp $R2 0 +2
		System::Call 'netapi32.dll::NetApiBufferFree(i R2) i .R0'

	!undef IndexEnumUsrs
	Pop $R4
	Pop $R3
	Pop $R2
	Pop $R1
	Pop $R0
!macroend

!define un.EnumerateUsers "!insertmacro un.EnumerateUsers"

!endif