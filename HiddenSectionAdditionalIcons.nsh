!ifndef PAGE_SEC_ADDITIONAL_ICONS
!define PAGE_SEC_ADDITIONAL_ICONS
	Section -AdditionalIcons
		SetOutPath $INSTDIR
		!ifdef PAGE_START_MENU
			!insertmacro MUI_STARTMENU_WRITE_BEGIN Application
			WriteIniStr "$INSTDIR\${PRODUCT_NAME}.url" "InternetShortcut" "URL" "${PRODUCT_WEB_SITE}"
			CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Website.lnk" "$INSTDIR\${PRODUCT_NAME}.url"
			CreateShortCut "$SMPROGRAMS\$ICONS_GROUP\Uninstall.lnk" "${UNINST_EXE}"
			!insertmacro MUI_STARTMENU_WRITE_END
		!endif
	SectionEnd
!endif