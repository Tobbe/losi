#
# This function will take a path and get it's long path (as opposed to it's short 8.3 name)
# If it for some reason failes it will return the path it got as an argument
#
# Written by Tobbe Lundberg 2007-07-14
#

Function LongPath
    Exch $R0 ; puts $r0 on the stack, and pops the top of the stack in to $r0
    Push $R1 ; put $r1 on the stack (above $r0)
    Push $R2 ; put $r2 on the stack (above $r1)
    
	;; The GetLongPathName function is only available on Win98 and later,
	;; so first we have to make sure the intaller is running on a modern OS
	
	ClearErrors
	; If the line below causes an error we're on an NT based system
	ReadRegStr $R1 HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion" VersionNumber
	IfErrors LongPathRun
	StrCpy $R2 $R1 1
	StrCmp $R2 '4' 0 LongPathCleanup ;Make sure the first number is 4
	StrCpy $R2 $R1 3
	StrCmp $R2 '4.0' LongPathCleanup ;4.0 is win95 anything else at this point is win98 or winME
	
LongPathRun:
    System::Call "Kernel32::GetLongPathNameA(t '$R0', &t .r11, i ${NSIS_MAX_STRLEN}) i .s"
    ;                                        ^  ^     ^  ^ ^   ^        ^            ^ ^^
    ;                            text variable  |     |  | |  int   max path length  | ||
    ;                               path to convert   |  | |           return type int ||
    ;        address of text variable to store result in | |                   no source|
    ;                                            no source |                          dest is NSIS stack
    ;                                                 dest is $r1

    Pop $R2
    IntCmp $R2 ${NSIS_MAX_STRLEN} LongPathCleanup 0 LongPathCleanup
		;Not too long, let's make sure it's not too short
		IntCmp $R2 0 LongPathCleanup
            ;Return value is good, copy the new path to $R0
            StrCpy $R0 $R1
LongPathCleanup:
	Pop $R2
	Pop $R1
	Exch $R0
FunctionEnd

!macro LongPath Var Path
    Push "${Path}"
        Call LongPath
    Pop "${Var}"
!macroend

!define LongPath "!insertmacro LongPath"
