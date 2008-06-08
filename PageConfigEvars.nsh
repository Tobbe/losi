; Evars pages
!ifndef PAGE_CONFIG_EVARS
!define PAGE_CONFIG_EVARS
	var filemanager
	var texteditor
	var commandprompt
	var audioplayer
	var mediaplayer
	var gfxviewer
	var gfxeditor
	var browser
	var dun
	var email
	var irc
	var ftp
	var im
	var tmp
	
	var configEvars

	!include GetInQuotes.nsh
	!include IndexOf.nsh
	!include GetExecutablePath.nsh
	!include Evars.nsh

	Section "Configure Evars" SecConfigEvars
		StrCpy $configEvars "true"
	SectionEnd

	Page custom ioEvars
	Page custom ioEvars2
	
	Function ioEvars
		; The function below is smart about only doing
		; this if the evar variables aren't already
		; populated.
		; By having this function call before the StrCmp
		; on $configEvars$ the evars will always get
		; good values
		Call PopulateEvarVariables
	
	    StrCmp $configEvars "true" isSel end
	    isSel:
	        Call WriteEvarsToEdit
	
	    	!insertmacro MUI_HEADER_TEXT "$(TEXT_IO_TITLE_EVARS)" "$(TEXT_IO_EVARS)"
	    	!insertmacro MUI_INSTALLOPTIONS_DISPLAY "ioEvars.ini"
		end:
	FunctionEnd
	
	Function ioEvars2
	    StrCmp $configEvars "true" isSel notSel
	    isSel:
	    	!insertmacro MUI_HEADER_TEXT "$(TEXT_IO_TITLE_EVARS)" "$(TEXT_IO_EVARS)"
	    	!insertmacro MUI_INSTALLOPTIONS_DISPLAY "ioEvars2.ini"
	
	    	Call ReadEvarsFromEdit
	
		notSel:
	
		Call WriteEvars
	FunctionEnd
!endif