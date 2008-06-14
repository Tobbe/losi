!ifndef PAGE_START_MENU
!define PAGE_START_MENU
	var ICONS_GROUP
	;!define MUI_STARTMENUPAGE_TEXT_TOP "$(TEXT_STARTMENUPAGE)"
	!define MUI_STARTMENUPAGE_DEFAULTFOLDER "${PRODUCT_NAME}"
	!define MUI_STARTMENUPAGE_REGISTRY_ROOT "${PRODUCT_UNINST_ROOT_KEY}"
	!define MUI_STARTMENUPAGE_REGISTRY_KEY "${PRODUCT_UNINST_KEY}"
	!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "${PRODUCT_STARTMENU_REGVAL}"
	!insertmacro MUI_PAGE_STARTMENU Application $ICONS_GROUP

	Section -StartMenuSection
		SetOutPath $INSTDIR
		!insertmacro MUI_STARTMENU_WRITE_BEGIN Application
		WriteIniStr "$INSTDIR\${PRODUCT_NAME}.url" "InternetShortcut" "URL" "${PRODUCT_WEB_SITE}"
		CreateDirectory "$SMPROGRAMS\$ICONS_GROUP"
		CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Set Explorer as Shell.lnk" '"$INSTDIR\utilities\wxlua.exe"' '"$INSTDIR\utilities\LOSS.lua" explorer' "$INSTDIR\losi\SetShellExplorer.ico"
		CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Set LiteStep as Shell.lnk" '"$INSTDIR\utilities\wxlua.exe"' '"$INSTDIR\utilities\LOSS.lua" litestep' "$INSTDIR\losi\SetShellLS.ico"
		CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Website.lnk" "$INSTDIR\${PRODUCT_NAME}.url"
		CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Uninstall.lnk" "${UNINST_EXE}"
		!insertmacro MUI_STARTMENU_WRITE_END
	SectionEnd
!endif