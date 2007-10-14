-- -----------------------------------------------------------------------------
-- Name:        LOSS.lua
-- Purpose:     Litestep Open-source Shell Switcher
-- Author:      Tobbe Lundberg / Darrin C Roenfanz (the-golem)
-- Modified by:
-- Created:     27/07/2007
-- RCS-ID:
-- Copyright:   (c) 2007 Tobbe Lundberg. All rights reserved.
-- Licence:     wxWidgets licence
-- -----------------------------------------------------------------------------
require 'winreg'












-------------------------------------------------------------------------------
-- ConfirmationDialog
-------------------------------------------------------------------------------

ConfirmationDialog = {
    -- The 'wxDialog' being encapsulated by this "class".
    dialog = nil,
	mainSizer = nil,
    yesBtn = nil,
    noBtn = nil,
    undoBtn = nil,
    infoText = nil,
    YES = 1,
    NO = 2,
    UNDO = 3,
    retVal = UNDO
}

-- The constructor for the confirmation dialog.
-- 'parent' is the parent window.
-- 'caption' is the title of the window
function ConfirmationDialog:new(parent, caption, text)
    local o = { }
    setmetatable(o, self)
    self.__index = self

    -- Create dialog
    o.dialog = wx.wxDialog(parent, wx.wxID_ANY, caption,
                           wx.wxDefaultPosition, wx.wxDefaultSize,
                           wx.wxDEFAULT_DIALOG_STYLE)

    o.infoText = wx.wxStaticText(o.dialog, wx.wxID_ANY, text)
    o.yesBtn = wx.wxButton(o.dialog, o.YES, "Yes")
    o.noBtn = wx.wxButton(o.dialog, o.NO, "No")
    o.undoBtn = wx.wxButton(o.dialog, o.UNDO, "Undo")
    o.mainSizer = wx.wxBoxSizer(wx.wxVERTICAL)
    local buttons = wx.wxBoxSizer(wx.wxHORIZONTAL)
    buttons:Add(o.yesBtn, 1, wx.wxALL - wx.wxTOP, 5)
    buttons:Add(o.noBtn, 1, wx.wxBOTTOM, 5)
    buttons:Add(o.undoBtn, 1, wx.wxALL - wx.wxTOP, 5)
    o.mainSizer:Add(o.infoText, 1, wx.wxALL, 5)
    o.mainSizer:Add(buttons, 0, wx.wxEXPAND)
    o.dialog:SetSizer(o.mainSizer)

    -- Handle idle events: run the coroutine's next "step"
    o.dialog:Connect(o.YES, wx.wxEVT_COMMAND_BUTTON_CLICKED,
        function (event)
            o.retVal = o.YES
            o.dialog:Close()
        end)

	o.dialog:Connect(o.NO, wx.wxEVT_COMMAND_BUTTON_CLICKED,
        function (event)
            o.retVal = o.NO
            o.dialog:Close()
        end)

	o.dialog:Connect(o.UNDO, wx.wxEVT_COMMAND_BUTTON_CLICKED,
        function (event)
            o.retVal = o.UNDO
            o.dialog:Close()
        end)

    -- Voilá
    return o
end

function ConfirmationDialog:resize()
    local yesW = self.yesBtn:GetSize():GetWidth()
    local noW = self.noBtn:GetSize():GetWidth()
    local undoW = self.undoBtn:GetSize():GetWidth()
    local newWidth = yesW + noW + undoW + 20
    self.infoText:Wrap(newWidth - 10) -- the -10 is because infoText has a 5px border on all sides
	self.dialog:SetClientSize(wx.wxSize(newWidth, self.dialog:GetBestSize():GetHeight()))
    
end

frame = nil
ID_CHOOSESHELL = 1001
ID_LOGOFF = 1002
ID_DETAILS = 1003
readVals = {}
readVals.lmAutoRestartShell = ""
readVals.lmBootShell = ""
readVals.lmWinlogonShell = ""
readVals.cuShell = ""
readVals.cuDesktopProcess = ""

writeVals = {}
writeVals.lmAutoRestartShell = "1"
writeVals.lmBootShell = [[USR:Software\Microsoft\Windows NT\CurrentVersion\Winlogon]]
writeVals.lmWinlogonShell = "explorer.exe"
writeVals.cuShell = [[C:\LiteStep\litestep.exe]]
writeVals.cuDesktopProcess = "1"

function getRegValues()
    hkey = winreg.openkey[[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon]]
    readVals.lmAutoRestartShell = tostring(hkey:getvalue("AutoRestartShell"))
    readVals.lmWinlogonShell = tostring(hkey:getvalue("Shell"))
    
    hkey = winreg.openkey[[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\IniFileMapping\system.ini\boot]]
    readVals.lmBootShell = tostring(hkey:getvalue("Shell"))
    
    hkey = winreg.openkey[[HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\Winlogon]]
    readVals.cuShell = tostring(hkey:getvalue("Shell"))
    
    hkey = winreg.openkey[[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer]]
    readVals.cuDesktopProcess = tostring(hkey:getvalue("DesktopProcess"))
end

function getLitestepPath()
    hkey = winreg.openkey[[HKEY_LOCAL_MACHINE\SOFTWARE\LOSI\Installer]]
    skey = hkey:getstrval("LitestepDir") .. "\\litestep.exe"
    return skey
end

function rebootLogoff()
    if writeVals.lmBootShell ~= readVals.lmBootShell then
        --wx.wxMessageBox("yo")
        wx.wxExecute("shutdown -r -t 0")
        -- C:\WINDOWS\RUNDLL.EXE user.exe,exitwindowsexec
    else
        -- io.popen("shutdown -l -t 0")
        wx.wxExecute("shutdown -l -t 0")
        -- io.popen[["C:\WINDOWS\RUNDLL.EXE" shell32.dll,SHExitWindowsEx 0]]
        -- os.execute[["C:\WINDOWS\RUNDLL.EXE" shell32.dll,SHExitWindowsEx 0]]
    end
end

function main()
	-- create the wxFrame window
	frame = wx.wxFrame(wx.NULL,   -- no parent for toplevel windows
		wx.wxID_ANY,              -- don't need a wxWindow ID
		"LOSS - Litestep Open-source Shell Switcher",     -- caption on the frame
		wx.wxDefaultPosition,     -- let system place the frame
		wx.wxSize(325, 120),      -- set the size of the frame
		wx.wxDEFAULT_FRAME_STYLE)-- - wx.wxMAXIMIZE_BOX - wx.wxRESIZE_BORDER) -- use default frame styles

	panel = wx.wxPanel(frame, wx.wxID_ANY)

	local choices = wx.wxArrayString()
		choices:Add("Litestep")
		choices:Add("Explorer")

	local rdbShells = wx.wxRadioBox(panel, ID_CHOOSESHELL, "Choose Your Shell",	wx.wxDefaultPosition, wx.wxDefaultSize, choices, 0)
	local chkLogoff = wx.wxCheckBox(panel, ID_LOGOFF, "Logoff/(Reboot)")
	local quitButton = wx.wxButton(panel, wx.wxID_EXIT, "Cancel")
	local okButton = wx.wxButton(panel, wx.wxID_OK, "Apply")

	local detailsPane = wx.wxCollapsiblePane(panel, ID_DETAILS, "Details")
	local det = detailsPane:GetPane()
	local detailsBox = wx.wxTextCtrl(det, wx.wxID_ANY, "", wx.wxDefaultPosition, wx.wxDefaultSize, wx.wxTE_MULTILINE + wx.wxTE_READONLY + wx.wxTE_DONTWRAP)

	local hiddenSizer = wx.wxBoxSizer(wx.wxVERTICAL)
        hiddenSizer:Add(wx.wxStaticText(det, wx.wxID_ANY, "These values will be set in the registry:"), 0, wx.wxALL, 5)
		hiddenSizer:Add(detailsBox, 1, wx.wxALL + wx.wxEXPAND, 5)
		det:SetSizer(hiddenSizer)
		hiddenSizer:SetSizeHints(det);

	local buttonSizer = wx.wxBoxSizer(wx.wxHORIZONTAL)
		buttonSizer:Add(okButton, 0, wx.wxALL + wx.wxEXPAND, 5)
		buttonSizer:Add(quitButton, 0, wx.wxALL + wx.wxEXPAND, 5)

	local shellsSizer = wx.wxBoxSizer(wx.wxHORIZONTAL)
		shellsSizer:Add(rdbShells, 1, wx.wxEXPAND + wx.wxALL, 5)

	local rightSizer = wx.wxBoxSizer(wx.wxVERTICAL)
		rightSizer:Add(chkLogoff, 0, wx.wxALL + wx.wxEXPAND, 5)
		rightSizer:Add(buttonSizer, 0, wx.wxEXPAND)

	local topSizer = wx.wxBoxSizer(wx.wxHORIZONTAL)
		topSizer:Add(shellsSizer, 1, wx.wxEXPAND)
		topSizer:Add(rightSizer, 0, wx.wxEXPAND)

	local mainSizer = wx.wxBoxSizer(wx.wxVERTICAL)
		mainSizer:Add(topSizer, 0)
		mainSizer:Add(detailsPane, 1, wx.wxGROW + wx.wxALL, 5)

	local function checkDetails()

	end

	frame:Connect(ID_DETAILS, wx.wxEVT_COMMAND_COLLPANE_CHANGED,
		function (event)
			if detailsPane:IsCollapsed(true) then
				frame:SetSize(wx.wxSize(wx.wxDefaultCoord,120))
			else
				frame:SetSize(wx.wxSize(wx.wxDefaultCoord,325))

				updateDetails()
			end
		end)
	frame:Connect(wx.wxID_EXIT, wx.wxEVT_COMMAND_BUTTON_CLICKED,
		function (event) frame:Close() end )
	frame:Connect(wx.wxID_OK, wx.wxEVT_COMMAND_BUTTON_CLICKED,
		function (event)
            answer = wx.wxMessageBox("This will set your shell to " .. 
                                     writeVals.cuShell .. ".\n" ..
                                     "Are you sure you want to continue?", 
                                     "SetShell", 
                                     wx.wxYES_NO + wx.wxICON_QUESTION)
            
            if answer == wx.wxYES then
                updateRegistry()

                if chkLogoff:IsChecked() then
                    rebootLogoff()
                end
            end
		end)

    frame:Connect(ID_CHOOSESHELL, wx.wxEVT_COMMAND_RADIOBOX_SELECTED,
        function (event)
            if rdbShells:GetStringSelection() == "Litestep" then
                writeVals.cuShell = getLitestepPath()
            else
                writeVals.cuShell = "explorer.exe"
            end
            
            updateDetails()
        end)

	panel:SetAutoLayout(true)
	panel:SetSizer(mainSizer)
	frame:Show(true)
	frame:SetClientSize(panel:GetBestSize())
    frame:SetMinSize(frame:GetSize())
    
    function updateDetails()
        detailsBox:SetLabel("")
        detailsBox:AppendText("HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Winlogon\n")
        detailsBox:AppendText("    New value: Shell = " .. writeVals.lmWinlogonShell .. "\n")
        detailsBox:AppendText("    Old value: Shell = " .. readVals.lmWinlogonShell .. "\n\n")
        detailsBox:AppendText([[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\IniFileMapping\system.ini\boot]] .. "\n")
        detailsBox:AppendText("    New value: Shell = " .. writeVals.lmBootShell .. "\n")
        detailsBox:AppendText("    Old value: Shell = " .. readVals.lmBootShell .. "\n\n")
        detailsBox:AppendText([[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon]] .. "\n")
        detailsBox:AppendText("    New value: AutoRestartShell = " .. writeVals.lmAutoRestartShell .. "\n")
        detailsBox:AppendText("    Old value: AutoRestartShell = " .. readVals.lmAutoRestartShell .. "\n\n")
        detailsBox:AppendText([[HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\Winlogon]] .. "\n")
        detailsBox:AppendText("    New value: Shell = " .. writeVals.cuShell .. "\n")
        detailsBox:AppendText("    Old value: Shell = " .. readVals.cuShell .. "\n\n")
        detailsBox:AppendText([[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer]] .. "\n")
        detailsBox:AppendText("    New value: DesktopProcess = " .. writeVals.cuDesktopProcess .. "\n")
        detailsBox:AppendText("    Old value: DesktopProcess = " .. readVals.cuDesktopProcess)
    end
end

function updateRegistry()
    hkey = winreg.openkey[[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon]]
    hkey:setvalue("AutoRestartShell", writeVals.lmAutoRestartShell)
    hkey:setvalue("Shell", writeVals.lmWinlogonShell)
    
    hkey = winreg.openkey[[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\IniFileMapping\system.ini\boot]]
    hkey:setvalue("Shell", writeVals.lmBootShell)
    
    hkey = winreg.openkey[[HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\Winlogon]]
    hkey:setvalue("Shell", writeVals.cuShell)
    
    hkey = winreg.openkey[[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer]]
    hkey:setvalue("DesktopProcess", writeVals.cuDesktopProcess)
end

getRegValues()
if arg ~= nil and #arg > 0 then
    local hasChangedShell = false
    if string.lower(arg[1]) == "litestep" then
        -- Set LiteStep as the shell
        writeVals.cuShell = getLitestepPath()
        updateRegistry()
        hasChangedShell = true
    elseif string.lower(arg[1]) == "explorer" then
        -- Set Explorer as the shell
        writeVals.cuShell = "explorer.exe"
        updateRegistry()
        hasChangedShell = true
    end
    
    if hasChangedShell then
		-- create the wxFrame window
		frame = wx.wxFrame(wx.NULL,   -- no parent for toplevel windows
			wx.wxID_ANY,              -- don't need a wxWindow ID
			"LOSS - Litestep Open-source Shell Switcher",     -- caption on the frame
			wx.wxDefaultPosition,     -- let system place the frame
			wx.wxSize(325, 120),      -- set the size of the frame
			wx.wxDEFAULT_FRAME_STYLE)-- - wx.wxMAXIMIZE_BOX - wx.wxRESIZE_BORDER) -- use default frame styles
		
        local msg = "You have set " .. writeVals.cuShell .. " as your shell, to use it you need to reboot/logout. Do you want to do that now?"
		local confDlg = ConfirmationDialog:new(frame, "Reboot/Logoff", msg)
		confDlg:resize()
		confDlg.dialog:ShowModal(true)
		confDlg.dialog:Destroy()
		local ans = confDlg.retVal
		
        if ans == confDlg.YES then        
            rebootLogoff()
        elseif ans == confDlg.UNDO then
            writeVals.cuShell = readVals.cuShell
            updateRegistry()
        end
    end
else
    main()
end