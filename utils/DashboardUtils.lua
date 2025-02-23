DashboardUtils = {}

DashboardUtils.MOD_NAME = g_currentModName
DashboardUtils.MOD_PATH = g_currentModDirectory

-- Vanilla Integration POC --
function DashboardUtils:loadVehicleFromXML(superfunc, xmlFile, key, defaultItemsToSPFarm, resetVehicles, keepPosition)
	print("VehicleSystem:loadVehicleFromXML:")
	print("key: "..tostring(key))
	
	local filename = xmlFile:getValue(key.."#filename")
	print("filename: "..tostring(filename))
	print("filename decoded: "..NetworkUtil.convertFromNetworkFilename(filename))
		
	if filename == "data/vehicles/claas/xerion12/xerion12.xml" then
		filename = DashboardLive.MOD_PATH.."data/vehicles/claas/xerion12/xerion12.xml"
		xmlFile:setValue(key.."#filename", filename)
		print("filename replaced: "..tostring(filename))
	end
	return superfunc(self, xmlFile, key, defaultItemsToSPFarm, resetVehicles, keepPosition)
end
--VehicleSystem.loadVehicleFromXML = Utils.overwrittenFunction(VehicleSystem.loadVehicleFromXML, DashboardUtils.loadVehicleFromXML)

function DashboardUtils:saveVehicleToXML(superfunc, vehicle, xmlFile, index, i, usedModNames)
	print("DashboardUtils:saveVehicleToXML:")
	print("environment: "..tostring(vehicle.customEnvironment))
	
	if vehicle.customEnvironment == DashboardUtils.MOD_NAME then
		vehicle.customEnvironment = nil
	end

	local fileName = HTMLUtil.encodeToHTML(NetworkUtil.convertToNetworkFilename(vehicle.configFileName))
	print("fileName: "..fileName)
	print("found? "..tostring(string.find(fileName, "$moddir$"..DashboardUtils.MOD_NAME)))
	if string.find(fileName, "$moddir$"..DashboardUtils.MOD_NAME) then
		print("vehicle.configFileName 1 :"..tostring(vehicle.configFileName))
		vehicle.configFileName = string.sub(fileName, string.len("$moddir$"..DashboardUtils.MOD_NAME)+2)
		print("vehicle.configFileName 2 :"..tostring(vehicle.configFileName))
	end

	print("configFileName: "..tostring(vehicle.configFileName))
	return superfunc(self, vehicle, xmlFile, index, i, usedModNames)
end
--VehicleSystem.saveVehicleToXML = Utils.overwrittenFunction(VehicleSystem.saveVehicleToXML, DashboardUtils.saveVehicleToXML)

function DashboardUtils:loadVehicle(superfunc, vehicleLoadingData)
	print("Vehicle:load ****")
	print(self.configFileName)
	
	if self.configFileName == "data/vehicles/claas/xerion12/xerion12.xml" then
		local item = g_storeManager:getItemByXMLFilename(self.configFileName)
		
		local lowerConfigName = string.lower(self.configFileName)
		--g_storeManager.xmlFilenameToItem[lowerConfigName] = nil
		
		self.configFileName = DashboardLive.MOD_PATH..self.configFileName

		vehicleLoadingData.xmlFilenameLower = string.lower(self.configFileName)
		vehicleLoadingData.rawXMLFilename = self.configFileName
		vehicleLoadingData.xmlFilename = self.configFileName

		item.xmlFilenameLower = string.lower(self.configFileName)
		item.rawXMLFilename = self.configFileName
		item.xmlFilename = self.configFileName
		
		g_storeManager.xmlFilenameToItem[vehicleLoadingData.xmlFilenameLower] = item
		
		print("replaced!")
	end
	return superfunc(self, vehicleLoadingData)
end
--Vehicle.load = Utils.overwrittenFunction(Vehicle.load, DashboardUtils.loadVehicle)

-- ** Vehicle Dashboards **

function DashboardUtils:loadSharedI3DFileAsync(superfunc, filename, callOnCreate, addToPhysics, asyncCallbackFunction, asyncCallbackObject, asyncCallbackArguments)
	local filenameDBL = DashboardLive.MOD_PATH..filename
	local isMod = string.find(filename, "/mods/") ~= nil
	
	if fileExists(filenameDBL) and not isMod then
		dbgprint("loadSharedI3DFileAsync: replaced i3d-file: "..tostring(filenameDBL), 2)
		if DashboardUtils.check == nil then
			DashboardUtils.check = true
		end
		return superfunc(self, filenameDBL, callOnCreate, addToPhysics, asyncCallbackFunction, asyncCallbackObject, asyncCallbackArguments)
	else
		dbgprint("loadSharedI3DFileAsync: used i3d-file: "..tostring(filename), 4)
		return superfunc(self, filename, callOnCreate, addToPhysics, asyncCallbackFunction, asyncCallbackObject, asyncCallbackArguments)
	end
end
I3DManager.loadSharedI3DFileAsync = Utils.overwrittenFunction(I3DManager.loadSharedI3DFileAsync, DashboardUtils.loadSharedI3DFileAsync)

function DashboardUtils.loadI3DMapping(xmlFile, superfunc, vehicleType, rootLevelNodes, i3dMappings, realNumComponents)
	local filename = xmlFile.filename
	local filenameDBL = DashboardLive.MOD_PATH..filename
	local isMod = string.find(filename, "/mods/") ~= nil
	local replaceI3dMappings = false
	local returnValue
	local xmlFileDBL
	if vehicleType == "vehicle" and fileExists(filenameDBL) and not isMod then
		xmlFileDBL = XMLFile.load("DBL Replacement", filenameDBL, xmlFile.schema)
		if xmlFileDBL:hasProperty("vehicle.i3dMappings") then 
			replaceI3dMappings = true
		else
			xmlFileDBL:delete()
		end
	end
	if replaceI3dMappings then	
		dbgprint("loadI3DMapping: replaced xml-file: "..tostring(filenameDBL), 2)
		return superfunc(xmlFileDBL, vehicleType, rootLevelNodes, i3dMappings, realNumComponents)
	else
		dbgprint("loadI3DMapping: used xml-file: "..tostring(filename), 2)
		return superfunc(xmlFile, vehicleType, rootLevelNodes, i3dMappings, realNumComponents)
	end
end
I3DUtil.loadI3DMapping = Utils.overwrittenFunction(I3DUtil.loadI3DMapping, DashboardUtils.loadI3DMapping)

function DashboardUtils:loadDashboardsFromXML(superfunc, xmlFile, key, dashboardValueType, components, i3dMappings, parentNode)
	local filename = xmlFile.filename
	local filenameDBL = DashboardLive.MOD_PATH..filename
	local isMod = self.baseDirectory ~= ""
	
	local returnValue = superfunc(self, xmlFile, key, dashboardValueType, components, i3dMappings, parentNode)
	
	if returnValue and fileExists(filenameDBL) and not isMod then
		local xmlFileDBL = XMLFile.load("DBL Replacement", filenameDBL, xmlFile.schema)
		dbgprint("loadDashboardsFromXML: added xml-file: "..tostring(filenameDBL), 2)
		returnValue = superfunc(self, xmlFileDBL, key, dashboardValueType, components, i3dMappings, parentNode)
	end
	return returnValue
end
Dashboard.loadDashboardsFromXML = Utils.overwrittenFunction(Dashboard.loadDashboardsFromXML, DashboardUtils.loadDashboardsFromXML)

function DashboardUtils:loadAnimations(superfunc, savegame)	
	local filename = self.xmlFile.filename
	local filenameDBL = DashboardLive.MOD_PATH..filename
	local isMod = self.baseDirectory ~= ""
	
	-- load animations from vanilla xml
	superfunc(self, savegame)
	
	local specAnim = self.spec_animatedVehicle
	if specAnim ~= nil and not isMod and fileExists(filenameDBL) then
		
		local animBackup = specAnim.animations
		local xmlFileBackup = self.xmlFile
		local xmlFile = XMLFile.load("DBL Anim Replacement", filenameDBL, self.xmlFile.schema)
	
		dbgprint("loadAnimations: added xml-file: "..tostring(filenameDBL), 2)
		self.xmlFile = xmlFile
		
		superfunc(self, savegame)
		
		self.xmlFile = xmlFileBackup
		xmlFile:delete()
		
		for _name, _anim in pairs(animBackup) do
			specAnim.animations[_name] = _anim
		end
	end
end
AnimatedVehicle.onLoad = Utils.overwrittenFunction(AnimatedVehicle.onLoad, DashboardUtils.loadAnimations)

-- ** Dashboard Compounds **

function DashboardUtils:loadDashboardCompoundFromXML(superfunc, xmlFile, key, compound)
	local spec = self.spec_dashboard
	local fileName = xmlFile:getValue(key .. "#filename")
	local fileNameNew = string.sub(fileName, 2) -- rip $ off the path
	local dblReplacementExists = XMLFile.loadIfExists("DBL Replacement", DashboardLive.MOD_PATH..fileNameNew, xmlFile.schema) ~= nil --and self.baseDirectory == ""
	local baseDirectoryChanged = false
	
	dbgprint("loadDashboardCompoundFromXML :: self.baseDirectory: "..tostring(self.baseDirectory), 2)
	dbgprint("loadDashboardCompoundFromXML :: fileName    = "..tostring(fileName), 2)
	dbgprint("loadDashboardCompoundFromXML :: fileNameNew = "..DashboardLive.MOD_PATH..fileNameNew, 2)
	dbgprint("loadDashboardCompoundFromXML :: dblReplacementExists = "..tostring(dblReplacementExists), 2)
	
	if dblReplacementExists then
		xmlFile:setValue(key .. "#filename", fileNameNew)
		dbgprint("loadDashboardCompoundFromXML :: fileName replaced", 2)
		self.baseDirectoryBackup = self.baseDirectory
		self.baseDirectory = DashboardLive.MOD_PATH
		baseDirectoryChanged = true
		dbgprint("loadDashboardCompoundFromXML :: baseDirectory changed", 2)
	end	
	
	local returnValue = superfunc(self, xmlFile, key, compound)
	
	if baseDirectoryChanged then
		self.baseDirectory = self.baseDirectoryBackup
		self.baseDirectoryBackup = nil
	end
		
	return returnValue
end
Dashboard.loadDashboardCompoundFromXML = Utils.overwrittenFunction(Dashboard.loadDashboardCompoundFromXML, DashboardUtils.loadDashboardCompoundFromXML)

function DashboardUtils:onDashboardCompoundLoaded(i3dNode, failedReason, args)
	local spec = self.spec_dashboard
	local dashboardXMLFile = args.dashboardXMLFile
	local compound = args.compound
	local compoundKey = args.compoundKey
	
	dbgprint("onDashboardCompoundLoaded :: dashboardXMLFile: "..tostring(dashboardXMLFile.filename), 2)
	
-- compound extension: dashboard groups
	if not spec.compoundGroupsLoaded then
		local i = 0
		while true do
			local baseKey = string.format("%s.group(%d)", "dashboardCompounds", i)
			dbgprint("onDashboardCompoundLoaded :: groups :: looking for key "..baseKey, 2)
			if not dashboardXMLFile:hasProperty(baseKey) then
				break
			end
	
			local group = {}
			if self:loadDashboardGroupFromXML(dashboardXMLFile, baseKey, group) then
				spec.groups[group.name] = group
				table.insert(spec.sortedGroups, group)
				dbgprint("onDashboardCompoundLoaded :: group "..tostring(group.name).." added", 2)
				spec.hasGroups = true
				spec.compoundGroupsLoaded = true
			end
	
			i = i + 1
		end
		DashboardLive.createDashboardPages(self)
	end
	
-- compound extension: dashboard animations

-- temporary build i3dMappings
	if not spec.compoundi3DMappingsLoaded then
		if i3dNode ~= 0 then
			dbgprint("onDashboardCompoundLoaded :: temporary building i3dMappings", 2)
			
			dbgprint("onDashboardCompoundLoaded :: i3dMappings before: ", 2)
			dbgprint_r(compound.i3dMappings, 2, 3)
			
			local components = {}
			for i=1, getNumOfChildren(i3dNode) do
				print("adding node "..tostring(i))
				table.insert(components, {node=getChildAt(i3dNode, i - 1)})
			end
			dbgprint_r(components, 2, 1)
			if compound.i3dMappings == nil then
				compound.i3dMappings = {}
			end
			I3DUtil.loadI3DMapping(dashboardXMLFile, "dashboardCompounds", components, compound.i3dMappings, nil)
			dbgprint("onDashboardCompoundLoaded :: i3dMappings after: ", 2)
			dbgprint_r(compound.i3dMappings, 2, 3)
			spec.compoundi3DMappings = compound.i3dMappings
			spec.compoundi3DMappingsLoaded = true
		end
	end
	
	if not spec.compoundAnimationsLoaded then
		local specAnim = self.spec_animatedVehicle
		local i = 0
		while specAnim ~= nil do
			local key = string.format("%s.animation(%d)", "dashboardCompounds", i)
			
			dbgprint("onDashboardCompoundLoaded :: animations :: looking for key "..key, 2)
			if not dashboardXMLFile:hasProperty(key) then
				break
			end
	
			local animation = {}
            if self:loadAnimation(dashboardXMLFile, key, animation, compound.i3dMappings) then
                specAnim.animations[animation.name] = animation
                specAnim.compoundAnimationsLoaded = true
            end
	
			i = i + 1
		end
	end
end
Dashboard.onDashboardCompoundLoaded = Utils.prependedFunction(Dashboard.onDashboardCompoundLoaded, DashboardUtils.onDashboardCompoundLoaded)

local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function DashboardUtils:loadAnimationPart(superfunc, xmlFile, partKey, part, animation, components)
	local spec = self.spec_dashboard
	if string.find(partKey, "dashboardCompounds") ~= nil then
		local i3dMappingsBackup = deepcopy(self.i3dMappings)
		self.i3dMappings = spec.compoundi3DMappings
		print_r(self.i3dMappings, 2)
		superfunc(self, xmlFile, partKey, part, animation, components)
		self.i3dMappings = i3dMappingsBackup
	else
		superfunc(self, xmlFile, partKey, part, animation, components)
	end
end
--AnimatedVehicle.loadAnimationPart = Utils.overwrittenFunction(AnimatedVehicle.loadAnimationPart, DashboardUtils.loadAnimationPart)













--[[
function DashboardUtils.createVanillaNodes(vehicle, xmlVanillaFile, xmlModFile)
	local spec = vehicle.spec_DashboardLive
	
	if vehicle.xmlFile == nil then return false end
	local xmlPath = vehicle.xmlFile.filename
	
	local i3dLibPath = DashboardLive.MOD_PATH.."utils/DBL_MeshLibary"
	local i3dLibFile = "DBL_MeshLibary.i3d"
	local i3dMinimapFile = "DBL_minimap_plane.i3d"
	
	-- Inject extended Dashboard Symbols into Vanilla Vehicles
	dbgprint("createVanillaNodes : vehicle: "..vehicle:getName(), 2)
	dbgprint("createVanillaNodes : vehicle's filename: "..xmlPath, 2)
	
	for xmlPart, xmlFile in pairs({xmlVanillaFile ,xmlModFile}) do
		dbgprint("createVanillaNodes : Step "..tostring(xmlPart)..": "..tostring(xmlFile.filename), 2)
	
		if xmlFile ~= nil then
			dbgprint("createVanillaNodes : reading file", 2)
			local i = 0
			while true do
				local xmlRootPath = string.format("vanillaDashboards.vanillaDashboard(%d)", i)
				if not xmlFile:hasProperty(xmlRootPath) then break end
				dbgprint("createVanillaNodes : xmlRootPath: "..tostring(xmlRootPath), 2)
			
				local vanillaFile = xmlFile:getString(xmlRootPath .. "#fileName")
				dbgprint("createVanillaNodes : vanillaFile: "..tostring(vanillaFile), 2)
				
				if string.sub(vanillaFile, 1, 2) == "FS" then
					vanillaFile = g_modsDirectory .. vanillaFile
					dbgprint("createVanillaNodes : vanillaFile changed to: "..tostring(vanillaFile), 2)
				end
			
				if vanillaFile == xmlPath then
					dbgprint("createVanillaNodes : found vehicle in "..tostring(xmlFile.objectName), 2)
								
					local n = 0
					while true do
						local xmlNodePath = xmlRootPath .. string.format(".nodes.node(%d)", n)
						if not xmlFile:hasProperty(xmlNodePath) then break end
					
						local nodeName = xmlFile:getString(xmlNodePath .. "#name")
						if nodeName == nil then
							Logging.xmlWarning(xmlFile, "No node name given, setting to 'dashboardLive'")
							nodeName = "dashboardLive"
						end
					
						local node = xmlFile:getString(xmlNodePath .. "#node")
						if node == nil then
							Logging.xmlWarning(xmlFile, "No root node given, setting to 0>0")
							node = "0>0"
						end
					
						local index = xmlFile:getString(xmlNodePath .. "#symbol")
						if index == nil then
							Logging.xmlWarning(xmlFile, "No symbol given, setting to 0|1")
							index = "0|1"
						elseif index == "map" then
							index = "0"
							i3dLibFile = i3dMinimapFile
						end

						local nx, ny, nz = 0, 0, 0
						local moveTo = xmlFile:getVector(xmlNodePath .. "#moveTo")
						if moveTo ~= nil then
							nx, ny, nz = unpack(moveTo)
						else
							Logging.xmlWarning(xmlFile, "No node translation given, setting to 0 0 0")
						end

						local rx, ry, rz = 0, 0, 0
						local rotate = xmlFile:getVector(xmlNodePath .. "#rotate")
						if rotate ~= nil then
							rx, ry, rz = unpack(rotate)
						else
							Logging.xmlWarning(xmlFile, "No node translation given, setting to 0 0 0")
						end
						
						local sx, sy, sz = 1, 1, 1
						local scale = xmlFile:getVector(xmlNodePath .. "#scale")
						if scale ~= nil then 
							sx, sy, sz = unpack(scale)
						else
							Logging.xmlWarning(xmlFile, "No node scale given, setting to 1 1 1")
						end
					
						dbgprint("nodeName: "..tostring(nodeName), 2)
						dbgprint("node: "..tostring(node), 2)
						dbgprint(string.format("moveTo: %f %f %f", nx, ny, nz), 2)
						dbgprint(string.format("rotate: %f %f %f", rx, ry, rz), 2)
					
						local i3d = g_i3DManager:loadSharedI3DFile(i3dLibPath.."/"..i3dLibFile, false, false)
						local symbol = I3DUtil.indexToObject(i3d, index)
						local linkNode = I3DUtil.indexToObject(vehicle.components, node, vehicle.i3dMappings)
		
						setTranslation(symbol, nx, ny, nz)
						setRotation(symbol, math.rad(rx), math.rad(ry), math.rad(rz))
						setScale(symbol, sx, sy, sz)
		
						link(linkNode, symbol)
						g_i3DManager:releaseSharedI3DFile(i3d, false)
						delete(i3d)
		
						if xmlPart == 1 then 
							spec.vanillaIntegration = i
						elseif xmlPart == 2 then
							spec.modIntegration = i
						end
						n = n + 1
					end
				end
				i = i + 1
			end
		end
	end
end

function DashboardUtils.createEditorNode(vehicle, node, symbolIndex, createMinimap)
	local spec = vehicle.spec_DashboardLive
	
	local i3dLibPath = DashboardLive.MOD_PATH.."utils/DBL_MeshLibary"
	local i3dLibFile
	local index
	if createMinimap == true then
	   i3dLibFile = "DBL_minimap_plane.i3d"
	   index = "0"
	else
	   i3dLibFile = "DBL_MeshLibary.i3d"
	   index = "0|"..tostring(symbolIndex)
	end
					
	local i3d = g_i3DManager:loadSharedI3DFile(i3dLibPath.."/"..i3dLibFile, false, false)
	local symbol = I3DUtil.indexToObject(i3d, index)
	local linkNode = I3DUtil.indexToObject(vehicle.components, node, vehicle.i3dMappings)
		
	setTranslation(symbol, DashboardLive.xTrans, DashboardLive.yTrans, DashboardLive.zTrans)
	setRotation(symbol, math.rad(DashboardLive.xRot), math.rad(DashboardLive.yRot), math.rad(DashboardLive.zRot))
	setScale(symbol, DashboardLive.xScl, DashboardLive.yScl, DashboardLive.zScl)
		
	link(linkNode, symbol)
	
	DashboardLive.editNode = node
	DashboardLive.editSymbol = symbol
	DashboardLive.editSymbolIndex = index
	g_i3DManager:releaseSharedI3DFile(i3d, false)
	delete(i3d)
end
--]]