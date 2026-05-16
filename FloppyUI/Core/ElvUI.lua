-- FloppyUI ElvUI Interface
-- Wraps ElvUI's Distributor module so the installer can apply FloppyUI's
-- export strings cleanly.
--
-- Key facts about ElvUI imports:
--   * Distributor:ImportProfile(string) decodes the string itself and
--     detects the data type (profile / private / global / filters).
--   * Only "profile" data is bound to a named profile. The installer
--     therefore creates and switches to a named profile BEFORE importing
--     the profile string, so the import lands in the right place.
--   * "private" and "global" data are NOT profile-bound (character- and
--     account-wide respectively). This is expected ElvUI behaviour.
--
-- Public API (FloppyPrivate.ElvUIInterface):
--   :IsReady()                            -> bool, errorText
--   :CreateAndSwitchProfile(name)         -> bool
--   :ImportString(string)                 -> bool
--   :ApplyLayout(layoutKey, profileName)  -> bool   (Step 2)
--   :ApplyAuraFilters()                   -> bool   (Step 3)

local _, FloppyPrivate = ...

-- Lua / API cache
local format = string.format
local pcall  = pcall
local type   = type

local Interface = {}
FloppyPrivate.ElvUIInterface = Interface

-- Resolve ElvUI's core object lazily (ElvUI may load after FloppyUI).
local function GetElv()
	if not ElvUI then return nil end
	return ElvUI[1]
end

----------------------------------------------------------------------
-- Readiness check
----------------------------------------------------------------------

-- Returns true if ElvUI and its Distributor are available, otherwise
-- false plus a human-readable reason.
function Interface:IsReady()
	local E = GetElv()
	if not E then
		return false, 'ElvUI is not loaded.'
	end

	local D = E:GetModule('Distributor', true)
	if not D then
		return false, 'ElvUI Distributor module not found.'
	end

	if type(D.ImportProfile) ~= 'function' then
		return false, 'ElvUI Distributor:ImportProfile is unavailable.'
	end

	return true
end

----------------------------------------------------------------------
-- Profile creation / switching
----------------------------------------------------------------------

-- Creates the named profile (if missing) and switches the active profile
-- to it. Uses ElvUI's AceDB profile API via E.data.
function Interface:CreateAndSwitchProfile(profileName)
	local E = GetElv()
	if not E or not E.data then
		FloppyPrivate:Print('|cffC80000Cannot access ElvUI profile database.|r')
		return false
	end

	-- E.data is the AceDB instance for ElvUI's profile-bound settings.
	-- SetProfile creates the profile automatically if it does not exist.
	local ok, err = pcall(function()
		E.data:SetProfile(profileName)
	end)

	if not ok then
		FloppyPrivate:Print(format('|cffC80000Failed to switch ElvUI profile: %s|r', tostring(err)))
		return false
	end

	FloppyPrivate:Print(format('ElvUI profile set to |cff4beb2c%s|r.', profileName))
	return true
end

----------------------------------------------------------------------
-- Generic string import
----------------------------------------------------------------------

-- Imports a single ElvUI export string through the Distributor.
-- The Distributor decodes the string and applies it according to its
-- embedded data type.
function Interface:ImportString(dataString)
	if type(dataString) ~= 'string' or dataString == '' then
		FloppyPrivate:Print('|cffC80000Import skipped: empty string.|r')
		return false
	end

	local ready, reason = self:IsReady()
	if not ready then
		FloppyPrivate:Print(format('|cffC80000Import failed: %s|r', reason))
		return false
	end

	local E = GetElv()
	local D = E:GetModule('Distributor')

	local ok, result = pcall(function()
		return D:ImportProfile(dataString)
	end)

	if not ok then
		FloppyPrivate:Print(format('|cffC80000Import error: %s|r', tostring(result)))
		return false
	end

	if not result then
		FloppyPrivate:Print('|cffC80000Import failed: ElvUI rejected the string.|r')
		return false
	end

	return true
end

----------------------------------------------------------------------
-- Step 2: apply a full layout (profile + global + private)
----------------------------------------------------------------------

-- layoutKey   is a key inside FloppyPrivate.Profiles.ElvUI, e.g. 'DpsTank'.
-- profileName is the named ElvUI profile to create, e.g. 'FloppyUI-DpsTank'.
--
-- Import order (as defined by the FloppyUI spec):
--   1. profile   2. global   3. private
-- Aura Filters are intentionally NOT applied here -- they live in Step 3.
function Interface:ApplyLayout(layoutKey, profileName)
	local ready, reason = self:IsReady()
	if not ready then
		FloppyPrivate:Print(format('|cffC80000%s|r', reason))
		return false
	end

	local layout = FloppyPrivate.Profiles
		and FloppyPrivate.Profiles.ElvUI
		and FloppyPrivate.Profiles.ElvUI[layoutKey]

	if not layout then
		FloppyPrivate:Print(format('|cffC80000Layout "%s" is not available.|r', tostring(layoutKey)))
		return false
	end

	if not layout.profile or layout.profile == '' then
		FloppyPrivate:Print('|cffC80000This layout has no profile string yet.|r')
		return false
	end

	-- Step 1: named profile must exist and be active before the import.
	if not self:CreateAndSwitchProfile(profileName) then
		return false
	end

	-- Step 2: import in the required order (profile -> global -> private).
	local success = true

	if not self:ImportString(layout.profile) then success = false end

	if layout.global and layout.global ~= '' then
		if not self:ImportString(layout.global) then success = false end
	end

	if layout.private and layout.private ~= '' then
		if not self:ImportString(layout.private) then success = false end
	end

	if success then
		FloppyPrivate:Print(format('Layout |cff4beb2c%s|r imported successfully.', profileName))
	else
		FloppyPrivate:Print('|cffC80000One or more parts of the layout failed to import.|r')
	end

	return success
end

----------------------------------------------------------------------
-- Step 3: apply aura filters
----------------------------------------------------------------------

function Interface:ApplyAuraFilters()
	local filters = FloppyPrivate.Profiles and FloppyPrivate.Profiles.AuraFilters

	if not filters or filters == '' then
		FloppyPrivate:Print('|cffC80000No aura filter string available.|r')
		return false
	end

	local success = self:ImportString(filters)

	if success then
		FloppyPrivate:Print('Aura filters imported successfully.')
	end

	return success
end
