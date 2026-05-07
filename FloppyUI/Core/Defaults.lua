-- FloppyUI Defaults
-- Default values for the addon's saved variables (FloppyUIDB).

local _, FloppyPrivate = ...

FloppyPrivate.Defaults = {
	profile = {
		minimap = {
			hide = false,
		},
		installer = {
			-- Set to FloppyPrivate.Version once the installer was completed at least once
			install_version = nil,
			-- Persisted page index for resume-after-reload
			resumePage   = nil,
			-- True while the user is actively going through the installer
			resumeActive = false,
		},
	},
	global = {
		debug = false,
	},
}
