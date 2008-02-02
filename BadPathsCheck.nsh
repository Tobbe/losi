Function BadPathsCheck
	StrCmp $INSTDIR $PROGRAMFILES32 badPathFound ; Installing directly to ProgramFiles
	StrCmp $INSTDIR $PROGRAMFILES64 badPathFound ; Installing directly to ProgramFiles
	StrCmp $INSTDIR $WINDIR badPathFound ; Installing directly to the Windows directory
	StrCmp $INSTDIR $SYSDIR badPathFound ; Installing directly to the system directory (C:\Windows\system32)
	StrCmp $INSTDIR $DESKTOP badPathFound ; Installing directly to the desktop directory
	StrCpy $R0 $INSTDIR "" -23
	StrCmp $R0 "\Documents and Settings" badPathFound ; Installing to the Documents and Settings folder
	StrCmp $INSTDIR $DOCUMENTS badPathFound doneBadPathsCheck
	badPathFound:
		MessageBox MB_OK|MB_ICONSTOP "$(BAD_INST_PATH)"
		Abort
	doneBadPathsCheck:
FunctionEnd