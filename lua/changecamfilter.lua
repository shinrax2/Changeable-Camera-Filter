	_G.CCF = _G.CCF or {}
	CCF._path = ModPath
	CCF.settings_path = SavePath .. "CCF.txt"
	CCF.settings = {}
	CCF.Choose_Camera_Filter = 	
		{
			"color_sin",
			"color_main",
			"color_payday",
			"color_heat",
			"color_nice",
			"color_bhd",
			"color_xgen",
			"color_xxxgen",
			"color_matrix",
			"color_matrix_classic",
			"color_sin_classic",
			"color_sepia",
			"color_sunsetstrip",
			"color_colorful",
			"color_madplanet"
		}
-- Store Color Gradient before using it as a string value in PostHook
function CCF:GetFilter()
	return CCF.Choose_Camera_Filter[CCF.settings.color_camera_filters_value]
end

function CCF:Reset()
	CCF.settings = {
		color_camera_filters_value = 1
	}
end

function CCF:Save()
	local file = io.open(CCF.settings_path, "w+")
	if file then
		file:write(json.encode(CCF.settings))
		file:close()
	end
end

function CCF:Load()
	CCF:Reset()
	local file = io.open(CCF.settings_path, "r")
	if file then
		for k, v in pairs(json.decode(file:read('*all')) or {}) do
				CCF.settings[k] = v
		end
		CCF:GetFilter()
		file:close()
	end
end

--PostHook to overide a function IngameAccessCamera:at_enter
Hooks:PostHook( IngameAccessCamera , "at_enter" , "ApplyCCF" , function(self)
		managers.environment_controller:set_default_color_grading(CCF:GetFilter(), true)
		managers.environment_controller:refresh_render_settings()
end)

--Localization thingy things :P
Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_CCF", function( loc )
	if file.DirectoryExists(CCF._path .. "loc/") then
			for _, filename in pairs(file.GetFiles(CCF._path .. "loc/")) do
				local str = filename:match('^(.*).txt$')
				if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
					loc:load_localization_file(CCF._path .. "loc/" .. filename)
					break
				end
			end
	end
	loc:load_localization_file(CCF._path .. "loc/english.txt", false)
end)

-- Menu stuffs
Hooks:Add( "MenuManagerInitialize", "MenuManagerInitialize_CCF", function( menu_manager )
	MenuCallbackHandler.callback_color_camera_filters = function (self, item)
		CCF.settings.color_camera_filters_value = item:value()
	end

	MenuCallbackHandler.ccf_save = function(this, item)
		CCF:Save()
	end
	
	MenuCallbackHandler.callback_ccf_reset = function(self, item)
		MenuHelper:ResetItemsToDefaultValue(item, {["color_camera_filters"] = true}, 1)
	end
	
	CCF:Load()	
	MenuHelper:LoadFromJsonFile(CCF._path .. "menu/options.txt", CCF, CCF.settings)
end )