-- FloppyUI Installer
-- Multi-step setup wizard. Each step lives in its own page-builder so
-- that real configuration logic can be added later without rewriting
-- the framework.
--
-- Step layout (matches FloppyUI spec):
--   1: Welcome
--   2: ElvUI Layouts
--   3: ElvUI Filters
--   4: ElvUI Plugins (WindTools)
--   5: Chat
--   6: Console Variables
--   7: Addon-Imports (BigWigs, MRT, NSRT, ...)
--   8: Cooldown Manager
--   9: EditMode-Layout
--  10: Installation Complete

local _, FloppyPrivate = ...

-- Lua / API cache
local format      = string.format
local next        = next
local type        = type
local CreateFrame = CreateFrame
local C_UI_Reload = C_UI.Reload
local StaticPopup_Show   = StaticPopup_Show
local StaticPopupDialogs = StaticPopupDialogs

-- Visual constants
local FRAME_WIDTH       = 600
local FRAME_HEIGHT      = 460
local STEP_FRAME_WIDTH  = 220
local STEP_BTN_WIDTH    = 200
local STEP_BTN_HEIGHT   = 22

local COLOR_FLOPPY      = { 0.294, 0.922, 0.173 } -- #4beb2c
local COLOR_STEP        = { 1, 1, 1 }
local COLOR_STEP_ACTIVE = { 0, 0.702, 1 } -- #00b3ff

-- ElvUI profile names used by Step 2 (FloppyUI spec).
local PROFILE_DPSTANK = 'FloppyUI-DpsTank'
local PROFILE_HEAL    = 'FloppyUI-Heal'

local Installer = {}
FloppyPrivate.Installer = Installer

local mainFrame, stepFrame
local currentPage = 0
local pages       = {}
local stepTitles  = {}

----------------------------------------------------------------------
-- Reload confirmation popup
----------------------------------------------------------------------
-- Shown after an import that requires a /reload. On accept it stores the
-- page to resume at and reloads the UI; the installer reopens at that
-- page on the next PLAYER_ENTERING_WORLD (handled in Core.lua).

StaticPopupDialogs['FLOPPYUI_RELOAD_REQUIRED'] = {
	text = '|cff4beb2cFloppyUI|r\n\nThe selected settings have been applied.\n\nA UI reload is mandatory for all changes to take effect and display correctly.',
	button1 = 'Reload Now',
	button2 = 'Later',
	OnAccept = function()
		Installer:ReloadAt(currentPage)
	end,
	OnCancel = function()
		-- "Later": keep the resume marker so the installer still returns
		-- to this page whenever the next reload happens.
		Installer:SavePage(currentPage)
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 0,
	preferredIndex = 3,
}

local function PromptReload()
	StaticPopup_Show('FLOPPYUI_RELOAD_REQUIRED')
end

----------------------------------------------------------------------
-- Templates
----------------------------------------------------------------------

local function ApplyBackdrop(frame)
	if not frame.SetBackdrop then
		Mixin(frame, BackdropTemplateMixin)
	end
	frame:SetBackdrop({
		bgFile   = 'Interface\\Buttons\\WHITE8X8',
		edgeFile = 'Interface\\Buttons\\WHITE8X8',
		edgeSize = 1,
		insets   = { left = 1, right = 1, top = 1, bottom = 1 },
	})
	frame:SetBackdropColor(0.05, 0.05, 0.05, 0.92)
	frame:SetBackdropBorderColor(0, 0, 0, 1)
end

local function StyleButton(button)
	if not button.bg then
		button.bg = button:CreateTexture(nil, 'BACKGROUND')
		button.bg:SetAllPoints()
		button.bg:SetColorTexture(0.2, 0.2, 0.2, 0.85)
	end
	if not button.hl then
		button.hl = button:CreateTexture(nil, 'HIGHLIGHT')
		button.hl:SetAllPoints()
		button.hl:SetColorTexture(1, 1, 1, 0.15)
		button:SetHighlightTexture(button.hl)
	end
	if not button.label then
		button.label = button:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
		button.label:SetPoint('CENTER')
		button.label:SetJustifyH('CENTER')
		button.SetText = function(self, text) self.label:SetText(text) end
	end
end

----------------------------------------------------------------------
-- Persistence helpers (resume-after-reload)
----------------------------------------------------------------------

function Installer:SavePage(pageNum)
	if not FloppyPrivate.db then return end
	FloppyPrivate.db.profile.installer.resumePage   = pageNum
	FloppyPrivate.db.profile.installer.resumeActive = true
end

function Installer:ClearResume()
	if not FloppyPrivate.db then return end
	FloppyPrivate.db.profile.installer.resumePage   = nil
	FloppyPrivate.db.profile.installer.resumeActive = false
end

-- Schedule a reload that returns to the given page (or the current one)
-- after the UI was reloaded. Use this from any step that requires a /reload.
function Installer:ReloadAt(pageNum)
	self:SavePage(pageNum or currentPage)
	C_UI_Reload()
end

----------------------------------------------------------------------
-- Main frame creation
----------------------------------------------------------------------

local function CreateMainFrame()
	local f = CreateFrame('Frame', 'FloppyUIInstallerFrame', UIParent, BackdropTemplateMixin and 'BackdropTemplate')
	f:SetSize(FRAME_WIDTH, FRAME_HEIGHT)
	f:SetPoint('CENTER')
	f:SetFrameStrata('DIALOG')
	f:EnableMouse(true)
	f:SetMovable(true)
	f:RegisterForDrag('LeftButton')
	f:SetScript('OnDragStart', f.StartMoving)
	f:SetScript('OnDragStop',  f.StopMovingOrSizing)
	f:Hide()
	ApplyBackdrop(f)

	-- Title
	f.Title = f:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
	f.Title:SetPoint('TOP', 0, -10)
	f.Title:SetText(format('%s |cffffffffInstallation|r', FloppyPrivate.Name))

	-- Subtitle (set per page)
	f.SubTitle = f:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
	f.SubTitle:SetPoint('TOP', 0, -42)

	-- Description font strings (up to 4 per page)
	f.Desc = {}
	local prev
	for i = 1, 4 do
		local fs = f:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
		fs:SetWidth(FRAME_WIDTH - 40)
		fs:SetJustifyH('CENTER')
		fs:SetSpacing(3)
		if prev then
			fs:SetPoint('TOP', prev, 'BOTTOM', 0, -16)
		else
			fs:SetPoint('TOP', f.SubTitle, 'BOTTOM', 0, -24)
		end
		f.Desc[i] = fs
		prev = fs
	end

	-- Option buttons (up to 4 per page)
	f.Option = {}
	for i = 1, 4 do
		local b = CreateFrame('Button', 'FloppyUIInstallerOption' .. i, f)
		b:SetSize(160, 30)
		StyleButton(b)
		b:Hide()
		f.Option[i] = b
	end

	-- Prev / Next
	f.Prev = CreateFrame('Button', 'FloppyUIInstallerPrev', f)
	f.Prev:SetSize(110, 25)
	f.Prev:SetPoint('BOTTOMLEFT', 6, 6)
	StyleButton(f.Prev)
	f.Prev:SetText('Previous')
	f.Prev:SetScript('OnClick', function() Installer:Previous() end)

	f.Next = CreateFrame('Button', 'FloppyUIInstallerNext', f)
	f.Next:SetSize(110, 25)
	f.Next:SetPoint('BOTTOMRIGHT', -6, 6)
	StyleButton(f.Next)
	f.Next:SetText('Next')
	f.Next:SetScript('OnClick', function() Installer:Next() end)

	-- Progress bar
	f.Progress = CreateFrame('StatusBar', 'FloppyUIInstallerProgress', f)
	f.Progress:SetPoint('TOPLEFT',     f.Prev, 'TOPRIGHT', 6, 0)
	f.Progress:SetPoint('BOTTOMRIGHT', f.Next, 'BOTTOMLEFT', -6, 0)
	f.Progress:SetStatusBarTexture('Interface\\Buttons\\WHITE8X8')
	f.Progress:SetStatusBarColor(COLOR_FLOPPY[1], COLOR_FLOPPY[2], COLOR_FLOPPY[3])
	f.Progress:SetMinMaxValues(0, 1)
	f.Progress:SetValue(0)

	f.Progress.bg = f.Progress:CreateTexture(nil, 'BACKGROUND')
	f.Progress.bg:SetAllPoints()
	f.Progress.bg:SetColorTexture(0.2, 0.2, 0.2, 0.85)

	f.Progress.text = f.Progress:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
	f.Progress.text:SetPoint('CENTER')
	f.Progress.text:SetText('0 / 0')

	return f
end

local function CreateStepFrame(parent)
	local f = CreateFrame('Frame', 'FloppyUIInstallerSteps', UIParent, BackdropTemplateMixin and 'BackdropTemplate')
	f:SetSize(STEP_FRAME_WIDTH, FRAME_HEIGHT)
	f:SetPoint('TOPLEFT', parent, 'TOPRIGHT', 1, 0)
	f:SetFrameStrata('DIALOG')
	ApplyBackdrop(f)

	f.title = f:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
	f.title:SetPoint('TOP', 0, -10)
	f.title:SetText('Steps')

	f.buttons = {}
	return f
end

----------------------------------------------------------------------
-- Page resetting / rendering
----------------------------------------------------------------------

local function ResetPage()
	mainFrame.SubTitle:SetText('')
	for i = 1, 4 do
		mainFrame.Desc[i]:SetText('')
	end
	for i = 1, 4 do
		local opt = mainFrame.Option[i]
		opt:Hide()
		opt:SetScript('OnClick', nil)
		opt:SetText('')
		opt:ClearAllPoints()
	end
end

local function LayoutOptions()
	local visible = {}
	for i = 1, 4 do
		if mainFrame.Option[i]:IsShown() then
			visible[#visible + 1] = mainFrame.Option[i]
		end
	end
	if #visible == 0 then return end

	local spacing = 6
	local w       = 160
	local total   = (#visible * w) + ((#visible - 1) * spacing)
	local startX  = -(total / 2) + (w / 2)

	for i, b in ipairs(visible) do
		b:ClearAllPoints()
		b:SetPoint('BOTTOM', mainFrame, 'BOTTOM', startX + ((i - 1) * (w + spacing)), 60)
	end
end

local function UpdateProgress()
	local max = #pages
	mainFrame.Progress:SetMinMaxValues(0, max)
	mainFrame.Progress:SetValue(currentPage)
	mainFrame.Progress.text:SetFormattedText('%d / %d', currentPage, max)
end

local function UpdateStepList()
	if not stepFrame then return end
	for i, btn in ipairs(stepFrame.buttons) do
		local color = (i == currentPage) and COLOR_STEP_ACTIVE or COLOR_STEP
		btn.label:SetTextColor(color[1], color[2], color[3])
		btn.label:SetText(stepTitles[i] or '')
	end
end

function Installer:SetPage(num)
	if num < 1 or num > #pages then return end
	ResetPage()
	currentPage = num
	pages[num]()
	LayoutOptions()
	UpdateProgress()
	UpdateStepList()

	mainFrame.Prev:SetEnabled(num > 1)
	mainFrame.Next:SetEnabled(num < #pages)
end

function Installer:Next()
	if currentPage < #pages then
		self:SetPage(currentPage + 1)
	end
end

function Installer:Previous()
	if currentPage > 1 then
		self:SetPage(currentPage - 1)
	end
end

----------------------------------------------------------------------
-- Step definitions
----------------------------------------------------------------------

local function SetOption(index, text, onClick)
	local b = mainFrame.Option[index]
	b:SetText(text)
	b:SetScript('OnClick', onClick)
	b:Show()
end

-- Returns true if the given ElvUI layout has usable profile data.
local function LayoutHasData(layoutKey)
	local layout = FloppyPrivate.Profiles
		and FloppyPrivate.Profiles.ElvUI
		and FloppyPrivate.Profiles.ElvUI[layoutKey]
	return layout and type(layout.profile) == 'table' and next(layout.profile) ~= nil
end

-- Shared handler for Step 2 layout buttons.
-- Applies the layout via the ElvUI interface and, on success, prompts
-- for the mandatory reload.
local function ApplyElvUILayout(layoutKey, profileName)
	local iface = FloppyPrivate.ElvUIInterface
	if not iface then
		FloppyPrivate:Print('|cffC80000ElvUI interface not available.|r')
		return
	end

	if iface:ApplyLayout(layoutKey, profileName) then
		PromptReload()
	end
end

local function BuildPages()
	pages      = {}
	stepTitles = {}

	-- 1: Welcome
	stepTitles[1] = 'Welcome'
	pages[1] = function()
		mainFrame.SubTitle:SetText('Welcome')
		mainFrame.Desc[1]:SetText('The FloppyUI installer will guide you through setup and apply the chosen profiles.')
		mainFrame.Desc[2]:SetText(format('|cff4beb2c%s|r', 'Your existing profiles will not be modified. The installer creates fresh ones.'))
		mainFrame.Desc[3]:SetText('Read each step carefully before clicking any buttons.')
		SetOption(1, '|cffC80000Skip and close|r', function()
			FloppyPrivate.db.profile.installer.install_version = FloppyPrivate.Version
			Installer:ClearResume()
			Installer:Hide()
		end)
		SetOption(2, 'Temporarily hide', function() Installer:Hide() end)
	end

	-- 2: ElvUI Layouts
	stepTitles[2] = 'ElvUI Layouts'
	pages[2] = function()
		mainFrame.SubTitle:SetText('ElvUI Layouts')
		mainFrame.Desc[1]:SetText('Choose the ElvUI layout that fits your role. The layout is applied to a dedicated FloppyUI profile.')
		mainFrame.Desc[2]:SetText(format('|cff4beb2c%s|r', 'Apply order: Profile, Global, Private. A mandatory reload follows.'))
		mainFrame.Desc[3]:SetText('DPS & Tanks creates the profile "FloppyUI-DpsTank".')
		SetOption(1, 'DPS & Tanks', function()
			ApplyElvUILayout('DpsTank', PROFILE_DPSTANK)
		end)
		-- Healing has no data yet -- present it as not-yet-available.
		if LayoutHasData('Healing') then
			SetOption(2, 'Healing', function()
				ApplyElvUILayout('Healing', PROFILE_HEAL)
			end)
		else
			SetOption(2, '|cff888888Healing (soon)|r', function()
				FloppyPrivate:Print('The Healing layout will be available in a future update.')
			end)
		end
	end

	-- 3: ElvUI Filters
	stepTitles[3] = 'ElvUI Filters'
	pages[3] = function()
		mainFrame.SubTitle:SetText('ElvUI Filters')
		mainFrame.Desc[1]:SetText('Optionally apply the FloppyUI aura filter lists.')
		mainFrame.Desc[2]:SetText(format('|cff4beb2c%s|r', 'This step is optional. Skip it if you prefer to keep your own filters.'))

		local filters = FloppyPrivate.Profiles and FloppyPrivate.Profiles.AuraFilters
		local hasFilters = type(filters) == 'table' and next(filters) ~= nil

		if hasFilters then
			mainFrame.Desc[3]:SetText('Existing filters with the same name will be overwritten.')
			SetOption(1, 'Apply Aura Filters', function()
				local iface = FloppyPrivate.ElvUIInterface
				if not iface then
					FloppyPrivate:Print('|cffC80000ElvUI interface not available.|r')
					return
				end
				if iface:ApplyAuraFilters() then
					PromptReload()
				end
			end)
		else
			mainFrame.Desc[3]:SetText('No aura filters are bundled yet. This step will become available in a future update.')
			SetOption(1, '|cff888888No Filters (soon)|r', function()
				FloppyPrivate:Print('No aura filters are bundled yet.')
			end)
		end
	end

	-- 4: ElvUI Plugins
	stepTitles[4] = 'ElvUI Plugins'
	pages[4] = function()
		mainFrame.SubTitle:SetText('ElvUI Plugins')
		mainFrame.Desc[1]:SetText('Configure profiles for supported ElvUI plugins.')
		mainFrame.Desc[2]:SetText(format('|cff4beb2c%s|r', 'Recommended step. Should not be skipped.'))
		SetOption(1, '|cff5385edWindTools|r', function() FloppyPrivate:Print('WindTools setup (TODO)') end)
	end

	-- 5: Chat
	stepTitles[5] = 'Chat'
	pages[5] = function()
		mainFrame.SubTitle:SetText('Chat')
		mainFrame.Desc[1]:SetText('Configure two chat panels with separate tabs.')
		mainFrame.Desc[2]:SetText(format('|cff4beb2c%s|r', 'Recommended step. Should not be skipped.'))
		mainFrame.Desc[3]:SetText('Left panel: General - Log - Whisper - Guild - Party.')
		mainFrame.Desc[4]:SetText('Right panel: Details! Damage Meter.')
		SetOption(1, 'Setup Chat', function() FloppyPrivate:Print('Chat setup (TODO)') end)
	end

	-- 6: Console Variables
	stepTitles[6] = 'Console Variables'
	pages[6] = function()
		mainFrame.SubTitle:SetText('Console Variables')
		mainFrame.Desc[1]:SetText('Apply FloppyUIs recommended Blizzard console variables.')
		mainFrame.Desc[2]:SetText(format('|cff4beb2c%s|r', 'Recommended step. Should not be skipped.'))
		mainFrame.Desc[3]:SetText('Examples: max camera distance, screenshot quality, tutorials.')
		SetOption(1, 'Setup CVars', function() FloppyPrivate:Print('CVars setup (TODO)') end)
	end

	-- 7: Addon-Imports
	stepTitles[7] = 'Addon-Imports'
	pages[7] = function()
		mainFrame.SubTitle:SetText('Addon-Imports')
		mainFrame.Desc[1]:SetText('Import FloppyUIs profiles for supported addons.')
		mainFrame.Desc[2]:SetText(format('|cff4beb2c%s|r', 'Buttons that require a reload will resume the installer at this step.'))
		SetOption(1, 'BigWigs',                 function() FloppyPrivate:Print('BigWigs import (TODO)') end)
		SetOption(2, 'Method Raid Tools',       function() FloppyPrivate:Print('MRT import (TODO)') end)
		SetOption(3, 'Northern Sky Raid Tools', function() FloppyPrivate:Print('NSRT import (TODO)') end)
	end

	-- 8: Cooldown Manager
	stepTitles[8] = 'Cooldown Manager'
	pages[8] = function()
		mainFrame.SubTitle:SetText('Cooldown Manager')
		mainFrame.Desc[1]:SetText('Choose between SkironCDM, AyijeCDM and BetterCDM.')
		mainFrame.Desc[2]:SetText(format('|cff4beb2c%s|r', 'Recommended step. Should not be skipped.'))
		SetOption(1, 'SkironCDM', function() FloppyPrivate:Print('SkironCDM (TODO)') end)
		SetOption(2, 'AyijeCDM',  function() FloppyPrivate:Print('AyijeCDM (TODO)') end)
		SetOption(3, 'BetterCDM', function() FloppyPrivate:Print('BetterCDM (TODO)') end)
	end

	-- 9: EditMode-Layout
	stepTitles[9] = 'EditMode-Layout'
	pages[9] = function()
		mainFrame.SubTitle:SetText('Blizzard Edit Mode')
		mainFrame.Desc[1]:SetText('Copy the FloppyUI Edit Mode import string and paste it into Blizzards Edit Mode.')
		mainFrame.Desc[2]:SetText(format('|cff4beb2c%s|r', 'Step 1: copy the import string. Step 2: open Edit Mode and import.'))
		SetOption(1, 'Copy Import String', function() FloppyPrivate:Print('Edit Mode string (TODO)') end)
		SetOption(2, 'Enter Edit Mode',    function() FloppyPrivate:Print('Toggle Edit Mode (TODO)') end)
	end

	-- 10: Installation Complete
	stepTitles[10] = 'Installation Complete'
	pages[10] = function()
		mainFrame.SubTitle:SetText('Installation Complete')
		mainFrame.Desc[1]:SetText('You have completed the installation. Click Finished to reload the UI.')
		SetOption(1, '|cff4beb2cFinished|r', function()
			FloppyPrivate.db.profile.installer.install_version = FloppyPrivate.Version
			Installer:ClearResume()
			C_UI_Reload()
		end)
	end
end

----------------------------------------------------------------------
-- Step list (right-side navigation)
----------------------------------------------------------------------

local function BuildStepList()
	if not stepFrame then return end

	for _, btn in ipairs(stepFrame.buttons) do
		btn:Hide()
	end

	for i = 1, #stepTitles do
		local btn = stepFrame.buttons[i]
		if not btn then
			btn = CreateFrame('Button', nil, stepFrame)
			btn:SetSize(STEP_BTN_WIDTH, STEP_BTN_HEIGHT)
			btn:SetID(i)

			btn.bg = btn:CreateTexture(nil, 'BACKGROUND')
			btn.bg:SetAllPoints()
			btn.bg:SetColorTexture(0.2, 0.2, 0.2, 0.5)

			btn.hl = btn:CreateTexture(nil, 'HIGHLIGHT')
			btn.hl:SetAllPoints()
			btn.hl:SetColorTexture(1, 1, 1, 0.15)
			btn:SetHighlightTexture(btn.hl)

			btn.label = btn:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
			btn.label:SetPoint('CENTER')
			btn.label:SetJustifyH('CENTER')

			btn:SetScript('OnClick', function(self)
				Installer:SetPage(self:GetID())
			end)

			if i == 1 then
				btn:SetPoint('TOP', stepFrame.title, 'BOTTOM', 0, -10)
			else
				btn:SetPoint('TOP', stepFrame.buttons[i - 1], 'BOTTOM', 0, -2)
			end

			stepFrame.buttons[i] = btn
		end
		btn:Show()
	end
end

----------------------------------------------------------------------
-- Public API
----------------------------------------------------------------------

function Installer:Initialize()
	if mainFrame then return end
	mainFrame = CreateMainFrame()
	stepFrame = CreateStepFrame(mainFrame)
	BuildPages()
	BuildStepList()
end

function Installer:Show(pageNum)
	self:Initialize()
	BuildPages()
	BuildStepList()
	mainFrame:Show()
	self:SetPage(pageNum or 1)
end

function Installer:Hide()
	if mainFrame then mainFrame:Hide() end
end

function Installer:Toggle()
	if mainFrame and mainFrame:IsShown() then
		self:Hide()
	else
		self:Show(currentPage > 0 and currentPage or 1)
	end
end
