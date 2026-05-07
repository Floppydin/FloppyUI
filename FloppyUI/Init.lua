-- FloppyUI Init
-- Sets up the addon namespace and shared private table.

local AddonName, FloppyPrivate = ...

-- Public addon name (matches the folder name)
FloppyPrivate.AddonName = AddonName

-- Display name (used in chat prints, popups, installer title)
FloppyPrivate.Name = '|cff4beb2cFloppyUI|r'

-- Required ElvUI version (will be checked on login)
FloppyPrivate.RequiredElvUI = 13.85

-- Player info
FloppyPrivate.myName    = UnitName('player')
FloppyPrivate.myRealm   = GetRealmName()
FloppyPrivate.myGUID    = UnitGUID('player')
FloppyPrivate.myFaction = UnitFactionGroup('player')

-- Game version flags
local interfaceVersion = select(4, GetBuildInfo())
FloppyPrivate.isRetail  = interfaceVersion >= 110000
FloppyPrivate.isMists   = interfaceVersion >= 50500 and interfaceVersion < 60000
FloppyPrivate.isCata    = interfaceVersion >= 40400 and interfaceVersion < 50000
FloppyPrivate.isWrath   = interfaceVersion >= 30400 and interfaceVersion < 40000
FloppyPrivate.isTBC     = interfaceVersion >= 20500 and interfaceVersion < 30000
FloppyPrivate.isClassic = interfaceVersion >= 11500 and interfaceVersion < 20000

-- Helper: returns true if the given addon is loaded
FloppyPrivate.IsAddOnLoaded = function(name)
	if C_AddOns and C_AddOns.IsAddOnLoaded then
		return C_AddOns.IsAddOnLoaded(name)
	end
	return IsAddOnLoaded and IsAddOnLoaded(name) or false
end

-- ElvUI presence flag (refreshed in Core on PLAYER_LOGIN)
FloppyPrivate.ElvUI = FloppyPrivate.IsAddOnLoaded('ElvUI')

-- Module registry
FloppyPrivate.Modules = {}

-- Library shortcuts (filled later in Libs/Libs.lua)
FloppyPrivate.Libs = {}
