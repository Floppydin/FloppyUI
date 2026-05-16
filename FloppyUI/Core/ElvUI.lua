-- FloppyUI ElvUI Interface
-- Applies FloppyUI's ElvUI profile data WITHOUT going through ElvUI's
-- Distributor. The Distributor shows its own confirmation popups and
-- triggers its own reload, which conflicts with the installer flow.
--
-- Instead, FloppyUI writes the plain Lua tables from Profiles.lua directly
-- into ElvUI's database and then asks the installer to reload once.
--
-- Where each export type is written:
--   profile -> a named profile inside ElvUI's profile database (E.data)
--   private -> E.private  (character-bound settings)
--   global  -> E.global   (account-wide settings)
--
-- ElvUI exports only contain values that DIFFER from ElvUI's defaults,
-- so the tables are MERGED over whatever is already there rather than
-- replacing entire branches.
--
-- Public API (FloppyPrivate.ElvUIInterface):
--   :IsReady()                            -> bool, errorText
--   :ApplyLayout(layoutKey, profileName)  -> bool   (Step 2)
--   :ApplyAuraFilters()                   -> bool   (Step 3)

local _, FloppyPrivate = ...

-- Lua / API cache
local format = string.format
local pcall  = pcall
local type   = type
local pairs  = pairs
local next   = next

local Interface = {}
FloppyPrivate.ElvUIInterface = Interface

-- Resolve ElvUI's core object lazily (ElvUI may load after FloppyUI).
local function GetElv()
	if not ElvUI then return nil end
	return ElvUI[1]
end

----------------------------------------------------------------------
-- Table merge helper
----------------------------------------------------------------------

-- Recursively copies every key from `source` into `target`.
-- Existing sub-tables are merged, scalar values are overwritten.
-- This mirrors how ElvUI applies an imported (defaults-stripped) profile.
local function MergeInto(target, source)
	for key, value in pairs(source) do
		if type(value) == 'table' then
			if type(target[key]) ~= 'table' then
				target[key] = {}
			end
			MergeInto(target[key], value)
		else
			target[key] = value
		end
	end
	return target
end

----------------------------------------------------------------------
-- Readiness check
----------------------------------------------------------------------

-- Returns true if ElvUI and its profile database are available,
-- otherwise false plus a human-readable reason.
function Interface:IsReady()
	local E = GetElv()
	if not E then
		return false, 'ElvUI is not loaded.'
	end

	if not E.data or type(E.data.SetProfile) ~= 'function' then
		return false, 'ElvUI profile database is unavailable.'
	end

	if type(E.private) ~= 'table' or type(E.global) ~= 'table' then
		return false, 'ElvUI private/global database is unavailable.'
	end

	return true
end

----------------------------------------------------------------------
-- Profile creation / switching
----------------------------------------------------------------------

-- Creates the named profile (if missing), switches to it, and returns
-- the profile table so the caller can write into it.
local function CreateAndSelectProfile(E, profileName)
	-- SetProfile creates the profile automatically if it does not exist.
	local ok, err = pcall(function()
		E.data:SetProfile(profileName)
	end)

	if not ok then
		FloppyPrivate:Print(format('|cffC80000Failed to set ElvUI profile: %s|r', tostring(err)))
		return nil
	end

	-- E.data.profile now points at the active (named) profile table.
	return E.data.profile
end

----------------------------------------------------------------------
-- Step 2: apply a full layout (profile + global + private)
----------------------------------------------------------------------

-- layoutKey   is a key inside FloppyPrivate.Profiles.ElvUI, e.g. 'DpsTank'.
-- profileName is the named ElvUI profile to create, e.g. 'FloppyUI-DpsTank'.
--
-- Apply order (per FloppyUI spec): profile -> global -> private.
-- Aura Filters are intentionally NOT applied here -- see Step 3.
function Interface:ApplyLayout(layoutKey, profileName)
	local ready, reason = self:IsReady()
	if not ready then
		FloppyPrivate:Print(format('|cffC80000%s|r', reason))
		return false
	end

	local E = GetElv()

	local layout = FloppyPrivate.Profiles
		and FloppyPrivate.Profiles.ElvUI
		and FloppyPrivate.Profiles.ElvUI[layoutKey]

	if not layout then
		FloppyPrivate:Print(format('|cffC80000Layout "%s" is not available.|r', tostring(layoutKey)))
		return false
	end

	if type(layout.profile) ~= 'table' or not next(layout.profile) then
		FloppyPrivate:Print('|cffC80000This layout has no profile data yet.|r')
		return false
	end

	-- 1) profile -> named profile
	local profileTable = CreateAndSelectProfile(E, profileName)
	if not profileTable then
		return false
	end

	local ok = pcall(function()
		MergeInto(profileTable, layout.profile)
	end)
	if not ok then
		FloppyPrivate:Print('|cffC80000Failed to apply profile data.|r')
		return false
	end

	-- 2) global -> E.global
	if type(layout.global) == 'table' and next(layout.global) then
		pcall(function()
			MergeInto(E.global, layout.global)
		end)
	end

	-- 3) private -> E.private
	if type(layout.private) == 'table' and next(layout.private) then
		pcall(function()
			MergeInto(E.private, layout.private)
		end)

		-- Suppress ElvUI's own installer by marking it complete with the
		-- actually installed ElvUI version (not the stale exported value).
		if E.version then
			E.private.install_complete = E.version
		end
	end

	FloppyPrivate:Print(format('Layout |cff4beb2c%s|r applied. A reload is required.', profileName))
	return true
end

----------------------------------------------------------------------
-- Step 3: apply aura filters
----------------------------------------------------------------------

-- Aura filters live in E.global.unitframe.aurafilters. The current
-- FloppyUI export is empty, so this is a guarded no-op until real
-- filter data is added to Profiles.lua.
function Interface:ApplyAuraFilters()
	local ready, reason = self:IsReady()
	if not ready then
		FloppyPrivate:Print(format('|cffC80000%s|r', reason))
		return false
	end

	local filters = FloppyPrivate.Profiles and FloppyPrivate.Profiles.AuraFilters

	if type(filters) ~= 'table' or not next(filters) then
		FloppyPrivate:Print('No aura filters are defined yet -- nothing to apply.')
		return false
	end

	local E = GetElv()
	local ok = pcall(function()
		if type(E.global.unitframe) ~= 'table' then
			E.global.unitframe = {}
		end
		if type(E.global.unitframe.aurafilters) ~= 'table' then
			E.global.unitframe.aurafilters = {}
		end
		MergeInto(E.global.unitframe.aurafilters, filters)
	end)

	if not ok then
		FloppyPrivate:Print('|cffC80000Failed to apply aura filters.|r')
		return false
	end

	FloppyPrivate:Print('Aura filters applied. A reload is required.')
	return true
end
