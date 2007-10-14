-- -----------------------------------------------------------------------------
-- Name:        LOEC.lua
-- Purpose:     Litestep Open-source Evar Configurator
-- Author:      Darrin Roenfanz (( the.golem ))
-- Modified by:
-- Created:     27/07/2007
-- RCS-ID:
-- Copyright:   (c) 2007 Darrin Roenfanz. All rights reserved.
-- Licence:     wxWidgets licence
-- -----------------------------------------------------------------------------
require 'winreg'
require 'rcparser'
loecApp = nil

local evarString = {"FileManager", "TxtEditor", "CmdPrompt",
                    "AudioPlayer", "MediaPlayer", "GfxViewer",
                    "GfxEditor", "Browser", "DUN",
                    "Email", "IRC", "FTP", "IM"}

local ecBrowse = {}

local function getEvarRCPath()
	hkey = winreg.openkey[[HKEY_LOCAL_MACHINE\SOFTWARE\LOSI\Installer]]
	skey = hkey:getstrval("PersonalDir") .. "\\evars.rc"
	return skey
end

local function saveFileAndExit()
	for ID = 1, 13 do
		rcparser.values[evarString[ID]:lower()] = '"' ..
			ecBrowse[ID]:GetPath() .. '"'
	end

	rcparser.write()
	loecApp:Close()
end

local function main()
	rcparser.values = {
		filemanager = "...", txteditor = "...", cmdprompt = "...",
		audioplayer = "...", mediaplayer = "...", gfxviewer = "...",
		gfxeditor = "...", browser = "...", dun = "...",
		email = "...", irc = "...", ftp = "...", im = "..."}

	rcparser.read(getEvarRCPath())

	loecApp = wx.wxFrame( wx.NULL,
	wx.wxID_ANY, "Litestep OpenSource Evar Configurator",
	wx.wxDefaultPosition, wx.wxSize(520, 435),
	wx.wxDEFAULT_FRAME_STYLE - wx.wxMAXIMIZE_BOX - wx.wxRESIZE_BORDER)
	ecPanel = wx.wxPanel( loecApp, wx.wxID_ANY,
	wx.wxDefaultPosition, wx.wxSize(loecApp:GetSize()) )

	local browseSizer = wx.wxBoxSizer(wx.wxVERTICAL)
	local labelSizer = wx.wxBoxSizer(wx.wxVERTICAL)
	local ecSizer = wx.wxBoxSizer(wx.wxHORIZONTAL)
	local ecLabel = {}  -- This makes a table for all the statics/labels

	for ID = 1,13 do
		ecLabel[ID] = wx.wxStaticText(ecPanel, ID, evarString[ID],
			wx.wxDefaultPosition, wx.wxSize(60,20))
		ecBrowse[ID] = wx.wxFilePickerCtrl(ecPanel, ID,
			rcparser.values[evarString[ID]:lower()][1],	"Choose a Program" , 
			"*.exe", wx.wxDefaultPosition, wx.wxSize(60, 10), 
			wx.wxFLP_USE_TEXTCTRL + wx.wxFLP_OPEN)

		if ecBrowse[ID]:GetPath() == "..." then
			ecBrowse[ID]:SetPath("")
		end

		browseSizer:Add(ecBrowse[ID], 0, wx.wxEXPAND + wx.wxALIGN_RIGHT + 
			wx.wxLEFT + wx.wxRIGHT + wx.wxTOP, 5)
		labelSizer:Add(ecLabel[ID], 0, wx.wxALIGN_LEFT + wx.wxALIGN_TOP +
			wx.wxLEFT+wx.wxTOP, 8)
	end

	local ecSave = wx.wxButton(ecPanel, wx.wxID_SAVE, "Save",
		wx.wxPoint(354,380), wx.wxDefaultSize)
	local ecCancel = wx.wxButton(ecPanel, wx.wxID_EXIT, "Cancel",
		wx.wxPoint(434,380), wx.wxDefaultSize)

	loecApp:Connect(wx.wxID_EXIT, wx.wxEVT_COMMAND_BUTTON_CLICKED,
		function (event)
			loecApp:Close(true)
		end)

	loecApp:Connect(wx.wxID_SAVE, wx.wxEVT_COMMAND_BUTTON_CLICKED,
		function (event)
			saveFileAndExit()
		end)

	ecSizer:Add(labelSizer, 0)
	ecSizer:Add(browseSizer, 1)

	ecPanel:SetSizer(ecSizer)

	-- show the frame window ---------------------------------------------------
	loecApp:Show(true)

	ecBrowse[1]:GetTextCtrl():SetSelection(0,0)
end

main()
