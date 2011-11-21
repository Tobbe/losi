; How to install LS (for all users, or just for the current user)
!ifndef PAGE_HOW_LS
!define PAGE_HOW_LS
	!include GetWindowsVersion.nsh

	Page custom ioHowLS
	
	Function ioHowLS
		StrCmp $advancedInstall "true" 0 end

		; This option should not be visible on 9x based systems
		; Check weather we're installing on a 9x or NT based system
		${If} ${IsNT}
			;If we get to this point we're not installing on a 9x based machine
			!insertmacro MUI_HEADER_TEXT "$(TEXT_IO_TITLE_HOWLS)" "$(TEXT_IO_HOWLS)"
		
			WriteINIStr "$PLUGINSDIR\ioHowLS.ini" "Field 1" "Text" "$(TEXT_IO_TITLE_HOWLS)"
			WriteINIStr "$PLUGINSDIR\ioHowLS.ini" "Field 2" "Text" "$(INSTALL_ALL)"
			WriteINIStr "$PLUGINSDIR\ioHowLS.ini" "Field 3" "Text" "$(INSTALL_CU)"
			WriteINIStr "$PLUGINSDIR\ioHowLS.ini" "Field 4" "Text" "$(INSTALL_NOSHELL)"
		
			!insertmacro MUI_INSTALLOPTIONS_INITDIALOG "ioHowLS.ini"
			Pop $R0 ;HWND (handle) of dialog
			Push "$PLUGINSDIR\ioHowLS.ini" ;Page .ini file where the field can be found.
			Push "$R0" ;Page handle you got when reserving the page.
			Push "3"   ;Field number to set focus.
			Call SetFocus

			!insertmacro MUI_INSTALLOPTIONS_SHOW
        	${EndIf}
		end:
	FunctionEnd
!endif