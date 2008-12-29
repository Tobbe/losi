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
	!include nsDialogs.nsh
	!include LogicLib.nsh
	!include winmessages.nsh
	!include SectionsInclude.nsh
	!include NSISArray.nsh
	
	${Array} EvarNames 13 ${NSIS_MAX_STRLEN} ; 13 different evars
	${ArrayFunc} WriteList
	${ArrayFunc} Read
	${ArrayFunc} Inited
	
	${Array} EvarPaths 13 ${NSIS_MAX_STRLEN}
	${ArrayFunc} WriteList
	${ArrayFunc} Read
	${ArrayFunc} Write
	
	${Array} InputHwnds 13 ${NSIS_MAX_STRLEN}
	${ArrayFunc} Read
	${ArrayFunc} Write

	Section "$(NAME_SecConfigEvars)" SecConfigEvars
		StrCpy $configEvars "true"
	SectionEnd

	Page custom ioEvars saveToArray1
	Page custom ioEvars2 saveToArray2
	
	Function saveToArray1
		; This is needed to save anything that's manually typed in to the
	    ; file path input fields
		${For} $R0 0 6
	    	${InputHwnds->Read} $R1 $R0
			System::Call "user32::SendMessage(i $R1, i ${WM_GETTEXT}, i ${NSIS_MAX_STRLEN}, t .R2)"
	    	${EvarPaths->Write} $R0 $R2
	    ${Next}
	FunctionEnd
	
	Function saveToArray2
		; This is needed to save anything that's manually typed in to the
	    ; file path input fields
		${For} $R0 7 12
	    	${InputHwnds->Read} $R1 $R0
			System::Call "user32::SendMessage(i $R1, i ${WM_GETTEXT}, i ${NSIS_MAX_STRLEN}, t .R2)"
	    	${EvarPaths->Write} $R0 $R2
	    ${Next}
	FunctionEnd
	
	Function ioEvars
		${EvarNames->Init}
		${EvarPaths->Init}
		${InputHwnds->Init}

		; The function below is smart about only doing
		; this if the evar variables aren't already
		; populated.
		; By having this function call before the
		; $configEvars check the evars will always get
		; good values
		Call PopulateEvarVariables
	
		${If} $configEvars == "true"
			${EvarNames->WriteList} '"File Manager:" \
			                         "Text Editor:" \
			                         "Command Prompt:" \
			                         "Audio Player:" \
			                         "Media Player:" \
			                         "Graphics Viewer:" \ 
			                         "Graphics Editor:" \
			                         "Browser:" \
			                         "Dial-up Networking:" \
			                         "E-Mail Client:" \
			                         "IRC Client:" \
			                         "FTP:" \
			                         "Instant Messaging:"'
		
			${EvarPaths->WriteList} '"$filemanager" \
			                         "$texteditor" \
			                         "$commandprompt" \
			                         "$audioplayer" \
			                         "$mediaplayer" \
			                         "$gfxviewer" \ 
			                         "$gfxeditor" \
			                         "$browser" \
			                         "$dun" \
			                         "$email" \
			                         "$irc" \
			                         "$ftp" \
			                         "$im"'

	        ;Call WriteEvarsToEdit
	        
	        nsDialogs::Create /NOUNLOAD 1018
			Pop $R0

	        ${For} $R0 0 6
	        	IntOp $R9 $R0 * 14
	        	IntOp $R8 $R9 + 1
	        	
	        	${EvarNames->Read} $R7 $R0
	        	${EvarPaths->Read} $R6 $R0
	        	
	        	${NSD_CreateLabel} 0 $R8u 96 12u $R7
	        	
				${NSD_CreateFileRequest} 100 $R9u 322 12u "$R6"
				Pop $R1
				${InputHwnds->Write} $R0 $R1

		        ${NSD_CreateBrowseButton} 426 $R9u 24 12u "..."
				Pop $R2

				GetFunctionAddress $R3 FileBrowse
				nsDialogs::OnClick /NOUNLOAD $R2 $R3		
				nsDialogs::SetUserData /NOUNLOAD $R2 $R0
			${Next}
	
	    	!insertmacro MUI_HEADER_TEXT "$(TEXT_IO_TITLE_EVARS)" "$(TEXT_IO_EVARS)"
	    	;!insertmacro MUI_INSTALLOPTIONS_DISPLAY "ioEvars.ini"
	    	
	    	GetFunctionAddress $R0 SaveToArray1
	    	nsDialogs::OnBack /NOUNLOAD $R0
	    	
	    	nsDialogs::Show	    		
		${EndIf}
	FunctionEnd
	
	Function ioEvars2
	    ${If} $configEvars == "true"
	    	nsDialogs::Create /NOUNLOAD 1018
			Pop $R0

	        ${For} $R0 7 12
	        	IntOp $R9 $R0 - 7  ; This will make $R9 go from 0 to 6
	        	IntOp $R9 $R9 * 14 ; This will make $R9 go from 0 to 84
	        	IntOp $R8 $R9 + 1  ; This will make $R8 = $R9 + 1
	        	
	        	${EvarNames->Read} $R7 $R0
	        	${EvarPaths->Read} $R6 $R0
	        	
	        	${NSD_CreateLabel} 0 $R8u 96 12u $R7
	        	
				${NSD_CreateFileRequest} 100 $R9u 322 12u "$R6"
				Pop $R1
				${InputHwnds->Write} $R0 $R1

		        ${NSD_CreateBrowseButton} 426 $R9u 24 12u "..."
				Pop $R2

				GetFunctionAddress $R3 FileBrowse
				nsDialogs::OnClick /NOUNLOAD $R2 $R3		
				nsDialogs::SetUserData /NOUNLOAD $R2 $R0
			${Next}
	    
	    	!insertmacro MUI_HEADER_TEXT "$(TEXT_IO_TITLE_EVARS)" "$(TEXT_IO_EVARS)"
	    	;!insertmacro MUI_INSTALLOPTIONS_DISPLAY "ioEvars2.ini"
			
			GetFunctionAddress $R0 SaveToArray2
	    	nsDialogs::OnBack /NOUNLOAD $R0
			
			nsDialogs::Show
			
	    	;Call ReadEvarsFromEdit
	    	${EvarPaths->Read} $filemanager 0
	    	${EvarPaths->Read} $texteditor 1
	    	${EvarPaths->Read} $commandprompt 2
	    	${EvarPaths->Read} $audioplayer 3
	    	${EvarPaths->Read} $mediaplayer 4
	    	${EvarPaths->Read} $gfxviewer 5
	    	${EvarPaths->Read} $gfxeditor 6
	    	${EvarPaths->Read} $browser 7
	    	${EvarPaths->Read} $dun 8
	    	${EvarPaths->Read} $email 9
	    	${EvarPaths->Read} $irc 10
	    	${EvarPaths->Read} $ftp 11
	    	${EvarPaths->Read} $im 12	
		${EndIf}
	
		Call WriteEvars
	FunctionEnd
	
	Function FileBrowse
		Pop $R9
		nsDialogs::GetUserData /NOUNLOAD $R9
		Pop $R9
		
		${InputHwnds->Read} $R0 $R9
		
		System::Call "user32::SendMessage(i $R0, i ${WM_GETTEXT}, i ${NSIS_MAX_STRLEN}, t .R1)"
		
		StrLen $R2 "$WINDIR"
		StrCpy $R3 $R1 $R2
		
		${If} "$R3" == "$WINDIR"
			StrCpy $R2 "$PROGRAMFILES"
		${Else}
			StrCpy $R3 $R1 2 1
			${IfNot} $R3 == ":\"
				StrCpy $R2 "$PROGRAMFILES"
			${Else}
				StrCpy $R2 $R1
			${EndIf}
		${EndIf}

		tSFD::SelectFileDialog /NOUNLOAD open $R2 "*.exe|*.exe"
		Pop $R2
		${If} $R2 != ""
			SendMessage $R0 ${WM_SETTEXT} 0 STR:$R2
			${EvarPaths->Write} $R9 $R2
		${EndIf}
	FunctionEnd
!endif