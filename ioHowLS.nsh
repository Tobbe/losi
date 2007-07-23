StrCmp $advancedInstall "true" 0 end

; This option should not be visible on 9x based systems
; Check weather we're installing on a 9x or NT based system
Call GetWindowsVersion
Pop $R0

StrCmp $R0 "9x" end

;If we get to this point we're not installing on a 9x based machine
!insertmacro MUI_HEADER_TEXT "$(TEXT_IO_TITLE_HOWLS)" "$(TEXT_IO_HOWLS)"

WriteINIStr "$PLUGINSDIR\ioHowLS.ini" "Field 1" "Text" "$(TEXT_IO_TITLE_HOWLS)"
WriteINIStr "$PLUGINSDIR\ioHowLS.ini" "Field 2" "Text" "$(INSTALL_ALL)"
WriteINIStr "$PLUGINSDIR\ioHowLS.ini" "Field 3" "Text" "$(INSTALL_CU)"
WriteINIStr "$PLUGINSDIR\ioHowLS.ini" "Field 4" "Text" "$(INSTALL_NOSHELL)"

!insertmacro MUI_INSTALLOPTIONS_DISPLAY "ioHowLS.ini"
end: