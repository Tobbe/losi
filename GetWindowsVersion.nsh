!ifndef GET_WINDOWS_VERSION_NSH
!define GET_WINDOWS_VERSION_NSH

; GetWindowsVersion
;
; Based on Yazno's function, http://yazno.tripod.com/powerpimpit/
; Updated by Joost Verburg
; Modified by Tobbe
;
; Returns on top of stack
;
; Windows Version (9x, NT, or 2k (2k, XP, or 2k3))
; or
; '' (Unknown Windows Version)
;
; Usage:
;   Call GetWindowsVersion
;   Pop $R0
;   ; at this point $R0 is "NT" or whatnot

Function GetWindowsVersion

	Push $R0
	Push $R1

	ClearErrors

	ReadRegStr $R0 HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion" CurrentVersion

	IfErrors 0 lbl_winnt

	; we are not NT
	ReadRegStr $R0 HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion" VersionNumber

	StrCpy $R1 $R0 1
	StrCmp $R1 '4' 0 lbl_error

	StrCpy $R0 '9x'
	Goto lbl_done

	lbl_winnt:

		StrCpy $R1 $R0 1

		StrCmp $R1 '3' lbl_winnt_x
		StrCmp $R1 '4' lbl_winnt_x

		Goto lbl_winnt_2k

		lbl_winnt_x:
			StrCpy $R0 "NT"
			Goto lbl_done

		lbl_winnt_2k:
			Strcpy $R0 '2k'
			Goto lbl_done

	lbl_error:
		Strcpy $R0 ''

	lbl_done:

	Pop $R1
	Exch $R0

FunctionEnd

;Same as GetWindowsVersion, just with a different name for the uninstaller
Function un.GetWindowsVersion

	Push $R0
	Push $R1

	ClearErrors

	ReadRegStr $R0 HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion" CurrentVersion

	IfErrors 0 lbl_winnt

	; we are not NT
	ReadRegStr $R0 HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion" VersionNumber

	StrCpy $R1 $R0 1
	StrCmp $R1 '4' 0 lbl_error

	StrCpy $R0 '9x'
	Goto lbl_done

	lbl_winnt:

		StrCpy $R1 $R0 1

		StrCmp $R1 '3' lbl_winnt_x
		StrCmp $R1 '4' lbl_winnt_x

		Goto lbl_winnt_2k

		lbl_winnt_x:
			StrCpy $R0 "NT"
			Goto lbl_done

		lbl_winnt_2k:
			Strcpy $R0 '2k'
			Goto lbl_done

	lbl_error:
		Strcpy $R0 ''

	lbl_done:

	Pop $R1
	Exch $R0

FunctionEnd

!endif