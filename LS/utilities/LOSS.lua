-- -----------------------------------------------------------------------------
-- Name:        LOSS.lua
-- Purpose:     Litestep Open-source Shell Switcher
-- Author:      Tobbe Lundberg / Darrin C Roenfanz (the-golem)
-- Modified by: Darrin C Roenfanz
-- Created:     27/07/2007
--Modified on: 20/11/2011
-- RCS-ID:
-- Copyright:   (c) 2007-2011 Tobbe Lundberg/Darrin C Roenfanz. All rights reserved.
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
readVals = {
    ["lmAutoRestartShell"] = "",
    ["lmBootShell"] = "",
    ["lmWinLogonShell"] = "",
    ["cuWinLogonShell"] = "",
    ["cuDesktopProcess"] = "",
    ["cuBrowseNewProcess"] = ""
}
constRegKeys = {
    ["cuWinLogonKey"] = [[HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\Winlogon]],
    ["lmWinLogonKey"] = [[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Winlogon]],    
    ["lmIniFileMap"] = [[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\IniFileMapping\system.ini\boot]],
    ["cuSeperateExplorerKey"] = [[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer]]
}
wxRegKey key(wxRegKey::HKLM, [[Software\Microsoft\Windows NT\CurrentVersion\Winlogon]]);
writeVals = {
    ["lmAutoRestartShell"] = "1",
    ["lmBootShell"] = [[USR:Software\Microsoft\Windows NT\CurrentVersion\Winlogon]],
    ["lmWinLogonShell"] = "explorer.exe",
    ["cuWinLogonShell"] = [[C:\Program Files\LiteStep\litestep.exe]],
    ["cuDesktopProcess"] = "1",
    ["cuBrowseNewProcess"] = "yes"
}
function readRegistry()
    hkey = winreg.openkey(constRegKeys["lmWinLogonKey"])
        readVals.lmAutoRestartShell = tostring(hkey:getvalue("AutoRestartShell"))
        readVals.lmWinLogonShell = tostring(hkey:getvalue("Shell"))
    
    hkey = winreg.openkey(constRegKeys["lmIniFileMap"])
        readVals.lmBootShell = tostring(hkey:getvalue("Shell"))
    
    hkey = winreg.openkey(constRegKeys["cuWinLogonKey"])
        readVals.cuWinLogonShell = tostring(hkey:getvalue("Shell"))
    
    hkey = winreg.openkey(constRegKeys["cuSeperateExplorerKey"])
        readVals.cuDesktopProcess = tostring(hkey:getvalue("DesktopProcess"))
        readVals.cuBrowseNewProcess = tostring(hkey:getvalue("BrowseNewProcess"))
end

function updateRegistry()
    hkey = winreg.openkey(constRegKeys["lmWinLogonKey"])
    hkey:setvalue("Shell", writeVals.lmWinLogonShell)
    
    hkey = winreg.openkey(constRegKeys["cuWinLogonKey"])
    hkey:setvalue("Shell", writeVals.cuWinLogonShell)

    hkey = winreg.openkey(constRegKeys["cuSeperateExplorerKey"])
    hkey:setvalue("DesktopProcess", writeVals.cuDesktopProcess)
    hkey:setvalue("BrowseNewProcess", writeVals.cuBrowseNewProcess)
end

function getLitestepExecPath()
    hkey = winreg.openkey[[HKEY_LOCAL_MACHINE\SOFTWARE\LOSI\Installer]]
    skey = hkey:getstrval("LitestepDir") .. "\\litestep.exe"
    return skey
end

function logoff()
    wx.wxExecute(getLitestepExecPath() .. " !logoff")
    --[[
    if writeVals.lmBootShell ~= readVals.lmBootShell then
        wx.wxShutdown(wx.wxSHUTDOWN_REBOOT)
    else
        wx.wxExecute(getLitestepExecPath() .. " !logoff")
    end
    --]]
end

function setShell(shell)
    if string.lower(shell) == "litestep" then
        writeVals.cuWinLogonShell = getLitestepExecPath()
        writeVals.cuDesktopProcess = "1"
        writeVals.cuBrowseNewProcess = "yes"
    elseif string.lower(shell) == "explorer" then
        writeVals.cuWinLogonShell = "explorer.exe"
        
        writeVals.cuDesktopProcess = "0"
        writeVals.cuBrowseNewProcess = "no"
    end
end    

function processCommandLine(hasChangedShell)
	if hasChangedShell then
		-- create the wxFrame window
		frame = wx.wxFrame(wx.NULL,   -- no parent for toplevel windows
			wx.wxID_ANY,              -- don't need a wxWindow ID
			"LOSS: LiteStep Open-Source Shell Switcher",     -- caption on the frame
			wx.wxDefaultPosition,     -- let system place the frame
			wx.wxSize(325, 120),      -- set the size of the frame
			wx.wxDEFAULT_FRAME_STYLE) -- - wx.wxMAXIMIZE_BOX - wx.wxRESIZE_BORDER)
                                      -- use default frame styles

		local msg = "You have set \"" .. writeVals.cuWinLogonShell .. "\" as your shell,"
                  .."to use it you need to logout. Do you want to do that now?"
		local confDlg = ConfirmationDialog:new(frame, "Logoff", msg)
		confDlg:resize()
		confDlg.dialog:ShowModal(true)
		confDlg.dialog:Destroy()
		local ans = confDlg.retVal

		if ans == confDlg.YES then
			logoff()
		elseif ans == confDlg.UNDO then
			writeVals.cuWinLogonShell = readVals.cuWinLogonShell
			updateRegistry()
		end
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

	local rdbShells = wx.wxRadioBox(panel, ID_CHOOSESHELL, "Choose Your Shell",
                      wx.wxDefaultPosition, wx.wxDefaultSize, choices, 0)
	local chkLogoff = wx.wxCheckBox(panel, ID_LOGOFF, "Logoff")
	local quitButton = wx.wxButton(panel, wx.wxID_EXIT, "Cancel")
	local okButton = wx.wxButton(panel, wx.wxID_OK, "Apply")

	local detailsPane = wx.wxCollapsiblePane(panel, ID_DETAILS, "Details")
	local det = detailsPane:GetPane()
	local detailsBox = wx.wxTextCtrl(det, wx.wxID_ANY, "", wx.wxDefaultPosition,
                       wx.wxDefaultSize, wx.wxTE_MULTILINE + wx.wxTE_READONLY + wx.wxTE_DONTWRAP)

	local hiddenSizer = wx.wxBoxSizer(wx.wxVERTICAL)
		hiddenSizer:Add(wx.wxStaticText(det, wx.wxID_ANY,
                        "These values will be set in the registry:"), 0, wx.wxALL, 5)
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

	writeVals.cuWinLogonShell = getLitestepExecPath()

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
            hkeyIniFileMap = winreg.openkey(constRegKeys["lmIniFileMap"])
            
            answer = wx.wxMessageBox("This will set your shell to " .. 
                                     writeVals.cuWinLogonShell .. ".\n" ..
                                     "Are you sure you want to continue?", 
                                     "SetShell", 
                                     wx.wxYES_NO + wx.wxICON_QUESTION)
            if answer == wx.wxYES then            
                updateRegistry()
                if chkLogoff:IsChecked() then
                    logoff()
                end
            end
		end)

    frame:Connect(ID_CHOOSESHELL, wx.wxEVT_COMMAND_RADIOBOX_SELECTED,
        function (event)
            setShell(rdbShells:GetStringSelection())
            updateDetails()
        end)

	panel:SetAutoLayout(true)
	panel:SetSizer(mainSizer)
	frame:Show(true)
	frame:SetClientSize(panel:GetBestSize())
	frame:SetMinSize(frame:GetSize())

    function updateDetails()
        detailsBox:SetLabel("")
            detailsBox:AppendText(constRegKeys["cuWinLogonKey"] .. "\n")
            detailsBox:AppendText("    New value: Shell = " .. writeVals.cuWinLogonShell .. "\n")
            detailsBox:AppendText("    Old value: Shell = " .. readVals.cuWinLogonShell .. "\n\n")

            --[[ Deprecated: New versions of LOSI will now set only HKCU
                detailsBox:AppendText( constRegKeys["lmWinLogonKey"] .."\n")
                detailsBox:AppendText("    New value: Shell = " .. writeVals.lmWinLogonShell .. "\n")
                detailsBox:AppendText("    Old value: Shell = " .. readVals.lmWinLogonShell .. "\n\n")
            
                We never changed these to begin with.
                detailsBox:AppendText(constRegKeys["lmWinLogonKey"] .. "\n")
                detailsBox:AppendText("    New value: AutoRestartShell = " .. writeVals.lmAutoRestartShell .. "\n")
                detailsBox:AppendText("    Old value: AutoRestartShell = " .. readVals.lmAutoRestartShell .. "\n\n")
            --]]
            
            detailsBox:AppendText(constRegKeys["cuSeperateExplorerKey"] .. "\n")
            detailsBox:AppendText("    New value: DesktopProcess = " .. writeVals.cuDesktopProcess .. "\n")
            detailsBox:AppendText("    Old value: DesktopProcess = " .. readVals.cuDesktopProcess .. "\n\n")
            
            detailsBox:AppendText(constRegKeys["cuSeperateExplorerKey"] .. "\n")
            detailsBox:AppendText("    New value: BrowseNewProcess = " .. writeVals.cuBrowseNewProcess .. "\n")
            detailsBox:AppendText("    Old value: BrowseNewProcess = " .. readVals.cuBrowseNewProcess )
    end
end

readRegistry()
if arg ~= nil and #arg > 0 then
    setShell(arg[1])
    updateRegistry()
    processCommandLine(true)
else
	main()
end