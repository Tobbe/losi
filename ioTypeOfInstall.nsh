!insertmacro MUI_HEADER_TEXT "$(TEXT_IO_TITLE_TYPEOFINSTALL)" "$(TEXT_IO_TYPEOFINSTALL)"

WriteINIStr "$PLUGINSDIR\ioTypeOfInstall.ini" "Field 1" "Text" "$(TEXT_IO_TITLE_TYPEOFINSTALL)"
WriteINIStr "$PLUGINSDIR\ioTypeOfInstall.ini" "Field 2" "Text" "$(INSTALL_NORMAL)"
WriteINIStr "$PLUGINSDIR\ioTypeOfInstall.ini" "Field 3" "Text" "$(INSTALL_ADVANCED)"

!insertmacro MUI_INSTALLOPTIONS_DISPLAY "ioTypeOfInstall.ini"
ReadINIStr $0 "$PLUGINSDIR\ioTypeOfInstall.ini" "Field 2" "State"
IntCmp $0 0 install_advanced
	strcpy $advancedInstall "false"
	goto end
install_advanced:
	strcpy $advancedInstall "true"
end: