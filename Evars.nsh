Function WriteEvars
    ;-----------------------
    ;Check for empty strings and replace them with "..."

    StrCmp $filemanager "" 0 +2 ;Check if $filemanager is empty
        StrCpy $filemanager '"..."' ;If it was we change it to "..."
    StrCmp $filemanager " " 0 +2 ;Check if $filemanager is a single whitespace
        StrCpy $filemanager '"..."' ;If it was we change it to "..."
    StrCmp $filemanager '"' 0 +2 ;Check if $filemanager is just a "
        StrCpy $filemanager '"..."' ;If it was we change it to "..."

    StrCmp $texteditor "" 0 +2 ;Check if $texteditor is empty
        StrCpy $texteditor '"..."' ;If it was we change it to "..."
    StrCmp $texteditor " " 0 +2 ;Check if $texteditor is a single whitespace
        StrCpy $texteditor '"..."' ;If it was we change it to "..."
    StrCmp $texteditor '"' 0 +2 ;Check if $texteditor is just a "
        StrCpy $texteditor '"..."' ;If it was we change it to "..."

    StrCmp $commandprompt "" 0 +2 ;Check if $commandprompt is empty
        StrCpy $commandprompt '"..."' ;If it was we change it to "..."
    StrCmp $commandprompt " " 0 +2 ;Check if $commandprompt is a single whitespace
        StrCpy $commandprompt '"..."' ;If it was we change it to "..."
    StrCmp $commandprompt '"' 0 +2 ;Check if $commandprompt is just a "
        StrCpy $commandprompt '"..."' ;If it was we change it to "..."

    StrCmp $audioplayer "" 0 +2 ;Check if $audioplayer is empty
        StrCpy $audioplayer '"..."' ;If it was we change it to "..."
    StrCmp $audioplayer " " 0 +2 ;Check if $audioplayer is a single whitespace
        StrCpy $audioplayer '"..."' ;If it was we change it to "..."
    StrCmp $audioplayer '"' 0 +2 ;Check if $audioplayer is just a "
        StrCpy $audioplayer '"..."' ;If it was we change it to "..."

    StrCmp $mediaplayer "" 0 +2 ;Check if $mediaplayer is empty
        StrCpy $mediaplayer '"..."' ;If it was we change it to "..."
    StrCmp $mediaplayer " " 0 +2 ;Check if $mediaplayer is a single whitespace
        StrCpy $mediaplayer '"..."' ;If it was we change it to "..."
    StrCmp $mediaplayer '"' 0 +2 ;Check if $mediaplayer is just a "
        StrCpy $mediaplayer '"..."' ;If it was we change it to "..."

    StrCmp $gfxviewer "" 0 +2 ;Check if $gfxviewer is empty
        StrCpy $gfxviewer '"..."' ;If it was we change it to "..."
    StrCmp $gfxviewer " " 0 +2 ;Check if $gfxviewer is a single whitespace
        StrCpy $gfxviewer '"..."' ;If it was we change it to "..."
    StrCmp $gfxviewer '"' 0 +2 ;Check if $gfxviewer is just a "
        StrCpy $gfxviewer '"..."' ;If it was we change it to "..."

    StrCmp $gfxeditor "" 0 +2 ;Check if $gfxeditor is empty
        StrCpy $gfxeditor '"..."' ;If it was we change it to "..."
    StrCmp $gfxeditor " " 0 +2 ;Check if $gfxeditor is a single whitespace
        StrCpy $gfxeditor '"..."' ;If it was we change it to "..."
    StrCmp $gfxeditor '"' 0 +2 ;Check if $gfxeditor is just a "
        StrCpy $gfxeditor '"..."' ;If it was we change it to "..."

    StrCmp $browser "" 0 +2 ;Check if $browser is empty
        StrCpy $browser '"..."' ;If it was we change it to "..."
    StrCmp $browser " " 0 +2 ;Check if $browser is a single whitespace
        StrCpy $browser '"..."' ;If it was we change it to "..."
    StrCmp $browser '"' 0 +2 ;Check if $browser is just a "
        StrCpy $browser '"..."' ;If it was we change it to "..."

    StrCmp $dun "" 0 +2 ;Check if $dun is empty
        StrCpy $dun '"..."' ;If it was we change it to "..."
    StrCmp $dun " " 0 +2 ;Check if $dun is a single whitespace
        StrCpy $dun '"..."' ;If it was we change it to "..."
    StrCmp $dun '"' 0 +2 ;Check if $dun is just a "
        StrCpy $dun '"..."' ;If it was we change it to "..."

    StrCmp $email "" 0 +2 ;Check if $email is empty
        StrCpy $email '"..."' ;If it was we change it to "..."
    StrCmp $email " " 0 +2 ;Check if $email is a single whitespace
        StrCpy $email '"..."' ;If it was we change it to "..."
    StrCmp $email '"' 0 +2 ;Check if $email is just a "
        StrCpy $email '"..."' ;If it was we change it to "..."

    StrCmp $irc "" 0 +2 ;Check if $irc is empty
        StrCpy $irc '"..."' ;If it was we change it to "..."
    StrCmp $irc " " 0 +2 ;Check if $irc is a single whitespace
        StrCpy $irc '"..."' ;If it was we change it to "..."
    StrCmp $irc '"' 0 +2 ;Check if $irc is just a "
        StrCpy $irc '"..."' ;If it was we change it to "..."

    StrCmp $ftp "" 0 +2 ;Check if $ftp is empty
        StrCpy $ftp '"..."' ;If it was we change it to "..."
    StrCmp $ftp " " 0 +2 ;Check if $ftp is a single whitespace
        StrCpy $ftp '"..."' ;If it was we change it to "..."
    StrCmp $ftp '"' 0 +2 ;Check if $ftp is just a "
        StrCpy $ftp '"..."' ;If it was we change it to "..."

    StrCmp $im "" 0 +2 ;Check if $im is empty
        StrCpy $im '"..."' ;If it was we change it to "..."
    StrCmp $im " " 0 +2 ;Check if $im is a single whitespace
        StrCpy $im '"..."' ;If it was we change it to "..."
    StrCmp $im '"' 0 +2 ;Check if $im is just a "
        StrCpy $im '"..."' ;If it was we change it to "..."

    ;-----------------------
    ;Add " where neccessary

    StrCpy $tmp $filemanager 1 ;Get the first character in $filemanager
    StrCmp $tmp '"' +2 0 ;Check if that character is a "
        StrCpy $filemanager '"$filemanager' ;If it isn't we'll add it
    StrCpy $tmp $filemanager 1 -1 ;Get the last character
    StrCmp $tmp '"' +2 0 ;Check if that character is a "
        StrCpy $filemanager '$filemanager"' ;If it isn't we'll add it

    DetailPrint 'FileManager: $filemanager'

    StrCpy $tmp $texteditor 1 ;Get the first character in $texteditor
    StrCmp $tmp '"' +2 0 ;Check if that character is a "
        StrCpy $texteditor '"$texteditor' ;If it isn't we'll add it
    StrCpy $tmp $texteditor 1 -1 ;Get the last character
    StrCmp $tmp '"' +2 0 ;Check if that character is a "
        StrCpy $texteditor '$texteditor"' ;If it isn't we'll add it

    DetailPrint 'Text Editor: $texteditor'

    StrCpy $tmp $commandprompt 1 ;Get the first character in $commandprompt
    StrCmp $tmp '"' +2 0 ;Check if that character is a "
        StrCpy $commandprompt '"$commandprompt' ;If it isn't we'll add it
    StrCpy $tmp $commandprompt 1 -1 ;Get the last character
    StrCmp $tmp '"' +2 0 ;Check if that character is a "
        StrCpy $commandprompt '$commandprompt"' ;If it isn't we'll add it

    DetailPrint 'Command Prompt: $commandprompt'

    StrCpy $tmp $audioplayer 1 ;Get the first character in $audioplayer
    StrCmp $tmp '"' +2 0 ;Check if that character is a "
        StrCpy $audioplayer '"$audioplayer' ;If it isn't we'll add it
    StrCpy $tmp $audioplayer 1 -1 ;Get the last character
    StrCmp $tmp '"' +2 0 ;Check if that character is a "
        StrCpy $audioplayer '$audioplayer"' ;If it isn't we'll add it

    DetailPrint 'Audio Player: $audioplayer'

    StrCpy $tmp $mediaplayer 1 ;Get the first character in $mediaplayer
    StrCmp $tmp '"' +2 0 ;Check if that character is a "
        StrCpy $mediaplayer '"$mediaplayer' ;If it isn't we'll add it
    StrCpy $tmp $mediaplayer 1 -1 ;Get the last character
    StrCmp $tmp '"' +2 0 ;Check if that character is a "
        StrCpy $mediaplayer '$mediaplayer"' ;If it isn't we'll add it

    DetailPrint 'Media Player: $mediaplayer'

    StrCpy $tmp $gfxviewer 1 ;Get the first character in $gfxviewer
    StrCmp $tmp '"' +2 0 ;Check if that character is a "
        StrCpy $gfxviewer '"$gfxviewer' ;If it isn't we'll add it
    StrCpy $tmp $gfxviewer 1 -1 ;Get the last character
    StrCmp $tmp '"' +2 0 ;Check if that character is a "
        StrCpy $gfxviewer '$gfxviewer"' ;If it isn't we'll add it

    DetailPrint 'Graphics Viewer: $gfxviewer'

    StrCpy $tmp $gfxeditor 1 ;Get the first character in $gfxeditor
    StrCmp $tmp '"' +2 0 ;Check if that character is a "
        StrCpy $gfxeditor '"$gfxeditor' ;If it isn't we'll add it
    StrCpy $tmp $gfxeditor 1 -1 ;Get the last character
    StrCmp $tmp '"' +2 0 ;Check if that character is a "
        StrCpy $gfxeditor '$gfxeditor"' ;If it isn't we'll add it

    DetailPrint 'Graphics Editor: $gfxeditor'

    StrCpy $tmp $browser 1 ;Get the first character in $browser
    StrCmp $tmp '"' +2 0 ;Check if that character is a "
        StrCpy $browser '"$browser' ;If it isn't we'll add it
    StrCpy $tmp $browser 1 -1 ;Get the last character
    StrCmp $tmp '"' +2 0 ;Check if that character is a "
        StrCpy $browser '$browser"' ;If it isn't we'll add it

    DetailPrint 'Browser: $browser'

    StrCpy $tmp $dun 1 ;Get the first character in $dun
    StrCmp $tmp '"' +2 0 ;Check if that character is a "
        StrCpy $dun '"$dun' ;If it isn't we'll add it
    StrCpy $tmp $dun 1 -1 ;Get the last character
    StrCmp $tmp '"' +2 0 ;Check if that character is a "
        StrCpy $dun '$dun"' ;If it isn't we'll add it

    DetailPrint 'Dial-up Networking: $dun'

    StrCpy $tmp $email 1 ;Get the first character in $email
    StrCmp $tmp '"' +2 0 ;Check if that character is a "
        StrCpy $email '"$email' ;If it isn't we'll add it
    StrCpy $tmp $email 1 -1 ;Get the last character
    StrCmp $tmp '"' +2 0 ;Check if that character is a "
        StrCpy $email '$email"' ;If it isn't we'll add it

    DetailPrint 'E-mail Client: $email'

    StrCpy $tmp $irc 1 ;Get the first character in $irc
    StrCmp $tmp '"' +2 0 ;Check if that character is a "
        StrCpy $irc '"$irc' ;If it isn't we'll add it
    StrCpy $tmp $irc 1 -1 ;Get the last character
    StrCmp $tmp '"' +2 0 ;Check if that character is a "
        StrCpy $irc '$irc"' ;If it isn't we'll add it

    DetailPrint 'IRC Client: $irc'

    StrCpy $tmp $ftp 1 ;Get the first character in $ftp
    StrCmp $tmp '"' +2 0 ;Check if that character is a "
        StrCpy $ftp '"$ftp' ;If it isn't we'll add it
    StrCpy $tmp $ftp 1 -1 ;Get the last character
    StrCmp $tmp '"' +2 0 ;Check if that character is a "
        StrCpy $ftp '$ftp"' ;If it isn't we'll add it

    DetailPrint 'FTP Client: $ftp'

    StrCpy $tmp $im 1 ;Get the first character in $im
    StrCmp $tmp '"' +2 0 ;Check if that character is a "
        StrCpy $im '"$im' ;If it isn't we'll add it
    StrCpy $tmp $im 1 -1 ;Get the last character
    StrCmp $tmp '"' +2 0 ;Check if that character is a "
        StrCpy $im '$im"' ;If it isn't we'll add it

    DetailPrint 'Instant Messager: $im'


    ;-----------------------
    ;Open the file, write the data, close the file
    ClearErrors
    FileOpen $tmp $whereprofiles\personal\evars.rc w
    IfErrors error

	FileWrite $tmp ';------------------------------------------------------------------------------$\r$\n'
	FileWrite $tmp ';    Edit *only* the paths as needed, and leave the file$\'s *FORMAT* unchanged$\r$\n'
	FileWrite $tmp ';------------------------------------------------------------------------------$\r$\n'
	FileWrite $tmp 'FileManager    $filemanager$\r$\n'
	FileWrite $tmp 'TxtEditor      $texteditor$\r$\n'
	FileWrite $tmp 'CmdPrompt      $commandprompt$\r$\n'
	FileWrite $tmp 'AudioPlayer    $audioplayer$\r$\n'
	FileWrite $tmp 'MediaPlayer    $mediaplayer$\r$\n'
	FileWrite $tmp 'GfxViewer      $gfxviewer$\r$\n'
	FileWrite $tmp 'GfxEditor      $gfxeditor$\r$\n'
	FileWrite $tmp 'Browser        $browser$\r$\n'
	FileWrite $tmp 'DUN            $dun$\r$\n'
	FileWrite $tmp 'Email          $email$\r$\n'
	FileWrite $tmp 'IRC            $irc$\r$\n'
	FileWrite $tmp 'FTP            $ftp$\r$\n'
	FileWrite $tmp 'IM             $im$\r$\n'
	FileWrite $tmp '$\r$\n'
	FileWrite $tmp '$\r$\n'
	FileWrite $tmp '$\r$\n'
	FileWrite $tmp ';------------------------------------------------------------------------------$\r$\n'
	FileWrite $tmp ';    Add and define any additional evars you require$\r$\n'
	FileWrite $tmp ';------------------------------------------------------------------------------$\r$\n'
	FileWrite $tmp '$\r$\n'
	FileWrite $tmp ';MiscApp       "C:\$PROGRAMFILES\misc\app.exe$\r$\n'

	FileClose $tmp

	GoTo noevarerror
	error:
		DetailPrint "Couldn't write evars.rc"
	noevarerror:
FunctionEnd

Function PopulateEvarVariables
	IfFileExists '$PLUGINSDIR\test.jpg' +2 ;Make sure they aren't already populated
		Call LoadEvarsDefaults
FunctionEnd

Function LoadEvarsDefaults
	InitPluginsDir
	SetOutPath $PLUGINSDIR
	File ".\test.txt"

	ReadRegStr $filemanager HKCR "folder\shell\open\command" ""

	System::Call "shell32::FindExecutable(t '$PLUGINSDIR\test.txt', t '', t .r0)"
	StrCpy $texteditor $0
	IfFileExists $texteditor +3 0
		ReadRegStr $texteditor HKCR ".txt" ""
		ReadRegStr $texteditor HKCR "$texteditor\shell\open\command" ""

	ExpandEnvStrings $commandprompt '%comspec%'

	Rename '$PLUGINSDIR\test.txt' '$PLUGINSDIR\test.mp3'
	System::Call "shell32::FindExecutable(t '$PLUGINSDIR\test.avi', t '', t .r0)"
	StrCpy $audioplayer $0
	IfFileExists $audioplayer +6 0
		ReadRegStr $audioplayer HKCR ".mp3" ""
		ReadRegStr $audioplayer HKCR "$audioplayer\shell\open\command" ""
		StrCmp $audioplayer "" 0 +3
		ReadRegStr $audioplayer HKCR ".mp3" ""
		ReadRegStr $audioplayer HKCR "$audioplayer\shell\Play\command" ""

	Rename '$PLUGINSDIR\test.mp3' '$PLUGINSDIR\test.avi'
	System::Call "shell32::FindExecutable(t '$PLUGINSDIR\test.avi', t '', t .r0)"
	StrCpy $mediaplayer $0
	IfFileExists $mediaplayer +6 0
		ReadRegStr $mediaplayer HKCR ".avi" ""
		ReadRegStr $mediaplayer HKCR "$mediaplayer\shell\open\command" ""
		StrCmp $mediaplayer "" 0 +3
		ReadRegStr $mediaplayer HKCR ".avi" ""
		ReadRegStr $mediaplayer HKCR "$mediaplayer\shell\play\command" ""

	Rename '$PLUGINSDIR\test.avi' '$PLUGINSDIR\test.jpg'
	System::Call "shell32::FindExecutable(t '$PLUGINSDIR\test.jpg', t '', t .r0)"
	StrCpy $gfxviewer $0
	DetailPrint "FindExecutable: $gfxviewer"
	IfFileExists $gfxviewer 0 +2
		StrCmp $gfxviewer "$SYSDIR\shimgvw.dll" 0 +7
			ReadRegStr $gfxviewer HKCR ".jpg" ""
			DetailPrint ".jpg:$gfxviewer"
			ReadRegStr $gfxviewer HKCR "$gfxviewer\shell\open\command" ""
			DetailPrint "shell\open\command: $gfxviewer"

			StrCmp $gfxviewer "" 0 +2
			ReadRegStr $gfxviewer HKCR "jpegfile\shell\open\command" ""

	ReadRegStr $gfxeditor HKCR ".bmp" ""
	ReadRegStr $gfxeditor HKCR "$gfxeditor\shell\edit\command" ""
	StrCmp $gfxeditor "" 0 +7
	ReadRegStr $gfxeditor HKCR ".bmp" ""
	ReadRegStr $gfxeditor HKCR "$gfxeditor\shell\open\command" ""
	StrCmp $gfxeditor "" 0 +4
	ReadRegStr $gfxeditor HKCR "jpegfile\shell\edit\command" ""
	StrCmp $gfxeditor "" 0 +2
	ReadRegStr $gfxeditor HKCR "jpegfile\shell\open\command" ""

	ReadRegStr $browser HKCR "http\shell\open\command" ""
	ReadRegStr $dun HKLM "SOFTWARE\Classes\rnkfile\shell\connect\command" ""
	ReadRegStr $email HKCR "mailto\shell\open\command" ""
	ReadRegStr $irc HKCR "irc\shell\open\command" ""
	ReadRegStr $ftp HKCR "ftp\shell\open\command" ""
	
	StrCpy $im '$PROGRAMFILES\MSN Messenger\msnmsgr.exe'
	IfFileExists $im imdone
		StrCpy $im '$PROGRAMFILES\Windows Live\Messenger\msnmsgr.exe'
		IfFileExists $im imdone
			ReadRegStr $im HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Miranda IM" "UninstallString"
			${RIndexOf} $R0 $im '\' ; Macro expands to 4 lines
			StrCpy $im $im -$R0
			StrCpy $im "$im\Miranda32.exe"
			IfFileExists $im imdone
			StrCpy $im ""
	imdone:

	DetailPrint " "
	DetailPrint "Values read from the registry"
	DetailPrint "====================================="
	DetailPrint "FileManager   $filemanager"
	DetailPrint "TextEditor    $texteditor"
	DetailPrint "CommandPromt  $commandprompt"
	DetailPrint "AudioPlayer   $audioplayer"
	DetailPrint "MediaPlayer   $mediaplayer"
	DetailPrint "GfxViewer     $gfxviewer"
	DetailPrint "GfxEditor     $gfxeditor"
	DetailPrint "Broswer       $browser"
	DetailPrint "Dun           $dun"
	DetailPrint "Email         $email"
	DetailPrint "IRC           $irc"
	DetailPrint "FTP           $ftp"
	DetailPrint "IM            $im"


	${ExePath} $filemanager $filemanager
	${ExePath} $texteditor $texteditor
	${ExePath} $commandprompt $commandprompt
	${ExePath} $audioplayer $audioplayer
	${ExePath} $mediaplayer $mediaplayer
	${ExePath} $gfxviewer $gfxviewer
	${ExePath} $gfxeditor $gfxeditor
	${ExePath} $browser $browser
	${ExePath} $dun $dun
	${ExePath} $email $email
	${ExePath} $irc $irc
	${ExePath} $ftp $ftp
	${ExePath} $im $im


	DetailPrint " "
	DetailPrint " "
	DetailPrint "Values after my magic"
	DetailPrint "===================================="
	DetailPrint "FileManager   $filemanager"
	DetailPrint "TextEditor    $texteditor"
	DetailPrint "CommandPromt  $commandprompt"
	DetailPrint "AudioPlayer   $audioplayer"
	DetailPrint "MediaPlayer   $mediaplayer"
	DetailPrint "GfxViewer     $gfxviewer"
	DetailPrint "GfxEditor     $gfxeditor"
	DetailPrint "Broswer       $browser"
	DetailPrint "Dun           $dun"
	DetailPrint "Email         $email"
	DetailPrint "IRC           $irc"
	DetailPrint "FTP           $ftp"
	DetailPrint "IM            $im"
	DetailPrint ""
FunctionEnd