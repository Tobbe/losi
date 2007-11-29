; Function SetupFinishPage
;
; This function gets called before the finish page is shown. It
; creates different controls on the finish page depending on
; whether the installer thinks a reboot is needed or not.

Function SetupFinishPage
    IfRebootFlag reboot noreboot
noreboot:
	; If we end up here the installer didn't think a reboot was
	; necesary. No option to reboot will be created.
	
	StrCmp $LogoffFlag "true" logoff nologoff
	
	logoff:
    	WriteINIStr "$PLUGINSDIR\ioSpecial.ini" "Settings" "NumFields" "4"
    	
    	WriteINIStr "$PLUGINSDIR\ioSpecial.ini" "Field 3" "Text" "$(TEXT_LOGOFF)"

    	WriteINIStr "$PLUGINSDIR\ioSpecial.ini" "Field 4" "Type" "CheckBox"
    	WriteINIStr "$PLUGINSDIR\ioSpecial.ini" "Field 4" "Flags" "Notify"
    	WriteINIStr "$PLUGINSDIR\ioSpecial.ini" "Field 4" "Text" "$(FINISH_LOGOFF)"
    	
    	GoTo donesetup
    	
	nologoff:
        WriteINIStr "$PLUGINSDIR\ioSpecial.ini" "Settings" "NumFields" "3"
        
        GoTo donesetup
    
reboot:
    WriteINIStr "$PLUGINSDIR\ioSpecial.ini" "Settings" "NumFields" "8"
    WriteINIStr "$PLUGINSDIR\ioSpecial.ini" "Field 4" "Flags" "GROUP|Notify"
    WriteINIStr "$PLUGINSDIR\ioSpecial.ini" "Field 5" "Flags" "Notify"
    
donesetup:
FunctionEnd

; Function ValidateFinish
;
; This function gets called when the user has pressed any
; of the controls on the finishpage. Depending on what the
; user pressed different actions will be taken.
Function ValidateFinish
    ReadINIStr $0 "$PLUGINSDIR\ioSpecial.ini" "Settings" "State" ;What caused this function to be called?

    StrCmp $0 0 finish ;The "Finish" button
    Abort

finish:
	; The user pressed the finish button. Now we need to act on the
	; users selections.

    IfRebootFlag 0 runpage
    
    ;The "Reboot now" radiobutton
    ReadINIStr $0 "$PLUGINSDIR\ioSpecial.ini" "Field 4" "State"
    StrCmp $0 1 done 0
    SetRebootFlag false ;The user wanted to manualy reboot later

    GoTo done

runpage:
    StrCmp $LogoffFlag "true" logoff done

	logoff:
    	ReadINIStr $0 "$PLUGINSDIR\ioSpecial.ini" "Field 4" "State"
    	StrCmp $0 1 0 done ;Check if the user wants to log off or not
			ShutDown::LogOff /NOSAFE
			Quit

done:
FunctionEnd

Function ShowFinishPage

    Push $0 ;hwnd

    GetDlgItem $0 $MUI_HWND 1203
	SetCtlColors $0 0x000000 0xFFFFFF
	
	GetDlgItem $0 $MUI_HWND 1204
	SetCtlColors $0 0x000000 0xFFFFFF

	Pop $0

FunctionEnd