--[[
    DefModPackFix.lua

    Fixes issues caused by the DefModPack.

	@author: 		BayernGamers
	@date: 			27.11.2025
	@version:		1.0

	History:		v1.0 @27.11.2025 - initial implementation in FS 25
                    ------------------------------------------------------------------------------------------------------
	
	License:        Terms:
                        Usage:
                            Feel free to use this work as-is as long as you adhere to the following terms:
						Attribution:
							You must give appropriate credit to the original author when using this work.
						No Derivatives:
							You may not alter, transform, or build upon this work in any way.
						Usage:
							The work may be used for personal and commercial purposes, provided it is not modified or adapted.
						Additional Clause:
							This script may not be converted, adapted, or incorporated into any other game versions or platforms except by GIANTS Software.
]]
DefModPackFix = {}
DefModPackFix.MOD_NAME = g_currentModName
DefModPackFix.MOD_DIR = g_currentModDirectory

function DefModPackFix.source(filename, superFunc)
    if filename:find("FS25_DefModPack/script/DieselLowLevelFix.lua") ~= nil then
        return
    end

    superFunc(filename)
end

if FS25_DefModPack ~= nil then
    local modEnv = _G["FS25_DefModPack"]

    if modEnv.source ~= nil then
        modEnv.source = Utils.overwrittenFunction(modEnv.source, DefModPackFix.source)
    end
end