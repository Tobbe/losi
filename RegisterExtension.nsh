;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; AssociateFile
;;
;; Associate a filetype with a certain program
;;
;; Written by Tobbe for the Litestep OpenSource Installer (LOSI)
;; Based on the code found at http://nsis.sourceforge.net/File_Association
;;
;; Usage (to add an association):
;;   Push ".ext"
;;   Push "Program.ext"
;;   Push "File Opened with program.exe"
;;   Push "$INSTDIR\program.exe" OR Push "$INSTDIR\viewer.exe"
;;   Push "$INSTDIR\program.exe" OR Push "$INSTDIR\editor.exe"
;;   Push "program.exe,1" OR Push "$INSTDIR\file.ico"
;;   Call AssociateFile
;;
;; Usage (to remove an association that has previously been added)
;;   Push ".ext"
;;   Push "Program.ext"
;;   Call un.DeAssociateFile
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function AssociateFile

	; Set up important variables
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	Push "#"

	; The file extension
	Exch 6
	Exch $2

	; General Description, use something unique!
	; (ApplicationName.FileType, CompanyName-ApplicationName.FileType,
	;  or FileType-file might be good choises)
	Exch 5
	Exch $3

	; File Description as seen for example when rightclicking on
	; the file and selecting Properties
	Exch 4
	Exch $4

	; Program used to open the file, use a full pathname
	Exch 3
	Exch $5

	; Program used to edit the file, often the same as used
	; when opening it
	Exch 2
	Exch $6

	; File icon
	Exch
	Exch $7


	; The actual script, should be no need to edit it
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	Push $0
	Push $1

	; back up old value
	!define Index "Line${__LINE__}" ;${__LINE__} resolves to the current linenumber
	ReadRegStr $1 HKCR $2 ""
	StrCmp $1 "" "${Index}-NoBackup"
		StrCmp $1 $3 "${Index}-NoBackup"
			WriteRegStr HKCR $2 "backup_val" $1

	"${Index}-NoBackup:"
		WriteRegStr HKCR $2 "" $3
		ReadRegStr $0 HKCR $3 ""
		StrCmp $0 "" 0 "${Index}-Skip"
			WriteRegStr HKCR $3 "" $4
			WriteRegStr HKCR "$3\shell" "" "open"
			WriteRegStr HKCR "$3\DefaultIcon" "" $7

	"${Index}-Skip:"
		WriteRegExpandStr HKCR "$3\shell\open\command" "" $5
		WriteRegStr HKCR "$3\shell\edit" "" $4
		WriteRegExpandStr HKCR "$3\shell\edit\command" "" $6

		System::Call 'Shell32::SHChangeNotify(i 0x8000000, i 0, i 0, i 0)'
	!undef Index

	; Restore the variables
	Pop $1
	Pop $0
	Pop $7
	Pop $6
	Pop $5
	Pop $4
	Pop $3
	Pop $2
FunctionEnd

Function un.DeAssociateFile

	; Set up important variables
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	Push "#"

	; The file extension
	Exch 2
	Exch $2

	; General Description, use something unique!
	; (ApplicationName.FileType, CompanyName-ApplicationName.FileType,
	;  or FileType-file might be good choises)
	Exch
	Exch $3


	; The actual script, should be no need to edit it
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	Push $0
	Push $1

	;start of restore script
	!define Index "Line${__LINE__}"
	ReadRegStr $1 HKCR $2 ""
	StrCmp $1 $3 0 "${Index}-NoOwn" ; only do this if we own it
		ReadRegStr $1 HKCR $2 "backup_val"
		StrCmp $1 "" 0 "${Index}-Restore" ; if backup="" then delete the whole key
			DeleteRegKey HKCR $2
			DeleteRegKey HKCR $3 ; DUNNO IF I REALLY SHOULD DO THIS!! ;Delete key with association settings
			System::Call 'Shell32::SHChangeNotify(i 0x8000000, i 0, i 0, i 0)'
			Goto "${Index}-NoOwn"

		"${Index}-Restore:"
			WriteRegStr HKCR $2 "" $1
			DeleteRegValue HKCR $2 "backup_val"
			DeleteRegKey HKCR $3 ;Delete key with association settings
			System::Call 'Shell32::SHChangeNotify(i 0x8000000, i 0, i 0, i 0)'

	"${Index}-NoOwn:"
	!undef Index

	; Restore the variables
	Pop $1
	Pop $0
	Pop $3
	Pop $2
FunctionEnd