-- FloppyUI Core
-- Bootstraps the addon, registers slash commands and verifies the
-- ElvUI dependency.

local AddonName, FloppyPrivate = ...

-- Lua / API cache
local format     = string.format
local strlower   = string.lower
local print      = print
local tonumber   = tonumber
local C_UI_Reload = C_UI.Reload

-- Local module table for Core (registered into FloppyPrivate.Modules)
local Core = {}
FloppyPrivate.Modules.Core = Core

-- Addon version (read from .toc)
local versionString = C_AddOns.GetAddOnMetadata(AddonName, 'Version')
FloppyPrivate.Version = tonumber(versionString) or 0.1

-- Chat print helper
function FloppyPrivate:Print(msg)
	print(FloppyPrivate.Name .. ': ' .. tostring(msg))
end

----------------------------------------------------------------------
-- Database bootstrap
----------------------------------------------------------------------

local function MergeDefaults(target, defaults)
	for k, v in pairs(defaults) do
		if type(v) == 'table' then
			if type(target[k]) ~= 'table' then
				target[k] = {}
			end
			MergeDefaults(target[k], v)
		elseif target[k] == nil then
			target[k] = v
		end
	end
end

function FloppyPrivate:InitDB()
	FloppyUIDB = FloppyUIDB or {}
	MergeDefaults(FloppyUIDB, FloppyPrivate.Defaults)
	FloppyPrivate.db = FloppyUIDB
end

----------------------------------------------------------------------
-- ElvUI dependency check
----------------------------------------------------------------------

function FloppyPrivate:CheckElvUI()
	if not FloppyPrivate.ElvUI then
		FloppyPrivate:Print('|cffC80000ElvUI is required to run FloppyUI. Please install ElvUI.|r')
		return false
	end

	local E = ElvUI and ElvUI[1]
	if not E then return false end

	if E.version and E.version < FloppyPrivate.RequiredElvUI then
		FloppyPrivate:Print(format('|cffC80000Your ElvUI is outdated. Required: %s, found: %s.|r', tostring(FloppyPrivate.RequiredElvUI), tostring(E.version)))
	end

	return true
end

----------------------------------------------------------------------
-- Slash commands
----------------------------------------------------------------------

local function HandleSlash(msg)
	msg = strlower(msg or '')

	if msg == '' or msg == 'install' then
		if FloppyPrivate.Installer then
			FloppyPrivate.Installer:Toggle()
		end
	elseif msg == 'reload' or msg == 'rl' then
		C_UI_Reload()
	elseif msg == 'reset' then
		FloppyUIDB = nil
		FloppyPrivate:Print('Saved variables cleared. Reloading UI.')
		C_UI_Reload()
	else
		FloppyPrivate:Print('Commands: /floppy install | /floppy reload | /floppy reset')
	end
end

local function RegisterSlashCommands()
	SLASH_FLOPPYUI1 = '/floppy'
	SLASH_FLOPPYUI2 = '/floppyui'
	SlashCmdList['FLOPPYUI'] = HandleSlash
end

----------------------------------------------------------------------
-- Addon Compartment (TOC AddonCompartmentFunc)
----------------------------------------------------------------------

function FloppyUI_OnAddonCompartmentClick()
	if FloppyPrivate.Installer then
		FloppyPrivate.Installer:Toggle()
	end
end

----------------------------------------------------------------------
-- Event frame & login flow
----------------------------------------------------------------------

local EventFrame = CreateFrame('Frame', 'FloppyUIEventFrame')
FloppyPrivate.EventFrame = EventFrame

EventFrame:RegisterEvent('ADDON_LOADED')
EventFrame:RegisterEvent('PLAYER_LOGIN')
EventFrame:RegisterEvent('PLAYER_ENTERING_WORLD')

EventFrame:SetScript('OnEvent', function(_, event, arg1)
	if event == 'ADDON_LOADED' and arg1 == AddonName then
		FloppyPrivate:InitDB()
		RegisterSlashCommands()

	elseif event == 'PLAYER_LOGIN' then
		FloppyPrivate.ElvUI = FloppyPrivate.IsAddOnLoaded('ElvUI')
		FloppyPrivate:CheckElvUI()

	elseif event == 'PLAYER_ENTERING_WORLD' then
		if not FloppyPrivate.Installer then return end

		-- First-time install: open installer at page 1
		if FloppyPrivate.db.profile.installer.install_version == nil then
			FloppyPrivate.Installer:Show(1)
			return
		end

		-- Resume-after-reload: open installer at the saved page
		if FloppyPrivate.db.profile.installer.resumeActive then
			local resumePage = FloppyPrivate.db.profile.installer.resumePage or 1
			FloppyPrivate.Installer:Show(resumePage)
		end
	end
end)
