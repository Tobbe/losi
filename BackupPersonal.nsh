Function backupPersonal
	IfFileExists "$whereprofiles\personal\personal.rc" 0 end
	
	; We got here, that means there are old personal files
	; that we maybe should back up...
	
	MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON1 $(BACKUP_PERSONAL) IDNO end
	
	CreateDirectory "$whereprofiles\personal\backup"
	CopyFiles "$whereprofiles\personal\*" "$whereprofiles\personal\backup\"
	
	MessageBox MB_OK $(BACKUP_DONE)
	
end:
FunctionEnd