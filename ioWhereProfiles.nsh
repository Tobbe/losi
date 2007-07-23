StrCmp $advancedInstall "true" 0 end

!insertmacro MUI_HEADER_TEXT "$(TEXT_IO_TITLE_WHEREPROFILES)" "$(TEXT_IO_WHEREPROFILES)"

WriteINIStr "$PLUGINSDIR\ioWhereProfiles.ini" "Field 1" "Text" "$(TEXT_IO_TITLE_WHEREPROFILES)"
WriteINIStr "$PLUGINSDIR\ioWhereProfiles.ini" "Field 2" "Text" "$(PROFILES_NOPROFILES)"
WriteINIStr "$PLUGINSDIR\ioWhereProfiles.ini" "Field 3" "Text" "$(PROFILES_LSPROFILES)"
WriteINIStr "$PLUGINSDIR\ioWhereProfiles.ini" "Field 4" "Text" "$(PROFILES_DAS)"

Call GetWindowsVersion
StrCmp $R0 "9x" modifyFor9x display

modifyFor9x:
;Remove the "Documents and Settings" profiles option when installing on 9x
WriteINIStr "$PLUGINSDIR\ioWhereProfiles.ini" "Field 4" "Type" "Label"
WriteINIStr "$PLUGINSDIR\ioWhereProfiles.ini" "Field 4" "Text" ""

display:
!insertmacro MUI_INSTALLOPTIONS_INITDIALOG "ioWhereProfiles.ini"
pop $R0 ;HWND (handle) of dialog
Push "$PLUGINSDIR\ioWhereProfiles.ini" ;Page .ini file where the field can be found.
Push "$R0" ;Page handle you got when reserving the page.
Push "3" ;Field number to set focus.
Call SetFocus

!insertmacro MUI_INSTALLOPTIONS_SHOW

end: