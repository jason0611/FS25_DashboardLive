DashboardUtils = {}

-- ** Vehicle Dashboards **

-- look for alternative i3d-file for vehicle and load it if existing
function DashboardUtils:loadSharedI3DFileAsync(superfunc, filename, callOnCreate, addToPhysics, asyncCallbackFunction, asyncCallbackObject, asyncCallbackArguments)
	local filenameDBL = DashboardLive.INT_PATH..filename
	local isMod = string.find(filename, "/mods/") ~= nil
	
	if fileExists(filenameDBL) and not isMod then
		dbgprint("loadSharedI3DFileAsync: replaced i3d-file: "..tostring(filenameDBL), 2)
		return superfunc(self, filenameDBL, callOnCreate, addToPhysics, asyncCallbackFunction, asyncCallbackObject, asyncCallbackArguments)
	else
		dbgprint("loadSharedI3DFileAsync: used i3d-file: "..tostring(filename), 4)
		return superfunc(self, filename, callOnCreate, addToPhysics, asyncCallbackFunction, asyncCallbackObject, asyncCallbackArguments)
	end
end
I3DManager.loadSharedI3DFileAsync = Utils.overwrittenFunction(I3DManager.loadSharedI3DFileAsync, DashboardUtils.loadSharedI3DFileAsync)

-- look for alternative xml-file for vehicle and use it for loading i3dMappings 
function DashboardUtils.loadI3DMapping(xmlFile, superfunc, vehicleType, rootLevelNodes, i3dMappings, realNumComponents)
	local filename = xmlFile.filename
	dbgprint("loadI3DMapping: fileName: "..tostring(fileName), 2)
	local filenameDBL = DashboardLive.INT_PATH..filename
	dbgprint("loadI3DMapping: filenameDBL: "..tostring(filenameDBL), 2)
	local isMod = string.find(filename, "/mods/") ~= nil
	dbgprint("loadI3DMapping: isMod: "..tostring(isMod), 2)
	local replaceI3dMappings = false
	local xmlFileDBL
	if vehicleType == "vehicle" and fileExists(filenameDBL) and not isMod then
		dbgprint("loadI3DMapping: Trying to replace xml-file ...", 2)
		xmlFileDBL = XMLFile.load("DBL Replacement", filenameDBL, xmlFile.schema)
		if xmlFileDBL:hasProperty("vehicle.i3dMappings") then 
			replaceI3dMappings = true
			xmlFile:delete()
			dbgprint("loadI3DMapping: ... success", 2)
		else
			xmlFileDBL:delete()
			dbgprint("loadI3DMapping: ... no success, no i3d mappings found", 2)
		end
	end
	if replaceI3dMappings then	
		dbgprint("loadI3DMapping: replaced xml-file: "..tostring(filenameDBL), 2)
		return superfunc(xmlFileDBL, vehicleType, rootLevelNodes, i3dMappings, realNumComponents)
	else
		dbgprint("loadI3DMapping: kept xml-file: "..tostring(filename), 4)
		return superfunc(xmlFile, vehicleType, rootLevelNodes, i3dMappings, realNumComponents)
	end
end
I3DUtil.loadI3DMapping = Utils.overwrittenFunction(I3DUtil.loadI3DMapping, DashboardUtils.loadI3DMapping)

function DashboardUtils:loadDashboardGroupsFromXML(savegame)
	local spec = self.spec_dashboard
	local filename = self.xmlFile.filename
	local filenameDBL = DashboardLive.INT_PATH..filename
	local isMod = self.baseDirectory ~= ""
		
	if fileExists(filenameDBL) and not isMod then
		local xmlFileDBL = XMLFile.load("DBL Replacement", filenameDBL, self.xmlFile.schema)
		dbgprint("loadDashboardGroupsFromXML: added xml-file: "..tostring(filenameDBL), 2)
		
		local i = 0
		while true do
			local baseKey = string.format("%s.groups.group(%d)", "vehicle.dashboard", i)
			if not xmlFileDBL:hasProperty(baseKey) then
				break
			end
	
			local group = {}
			if self:loadDashboardGroupFromXML(xmlFileDBL, baseKey, group) then
				spec.groups[group.name] = group
				table.insert(spec.sortedGroups, group)
				spec.hasGroups = true
			end
	
			i = i + 1
		end	
	end
end
Dashboard.onLoad = Utils.appendedFunction(Dashboard.onLoad, DashboardUtils.loadDashboardGroupsFromXML)

-- look for alternative xml-file for vehicle and use it for loading additional dashboard entries
function DashboardUtils:loadDashboardsFromXML(superfunc, xmlFile, key, dashboardValueType, components, i3dMappings, parentNode)
	local filename = xmlFile.filename
	local filenameDBL = DashboardLive.INT_PATH..filename
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

-- look for alternative xml-file for vehicle and use it for loading additional animations 
function DashboardUtils:loadAnimations(superfunc, savegame)	
	local filename = self.xmlFile.filename
	local filenameDBL = DashboardLive.INT_PATH..filename
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

-- look for alternative compound dashboard xml-file and use it for loading instead of original file
function DashboardUtils:loadDashboardCompoundFromXML(superfunc, xmlFile, key, compound)
	local spec = self.spec_dashboard
	dbgprint("loadDashboardCompoundFromXML :: self.baseDirectory: "..tostring(self.baseDirectory), 2)
	local fileName = xmlFile:getValue(key .. "#filename")
	dbgprint("loadDashboardCompoundFromXML :: fileName    = "..tostring(fileName), 2)
	local fileNameNew = string.sub(fileName, 2) -- rip $ off the path
	dbgprint("loadDashboardCompoundFromXML :: fileNameNew = "..tostring(DashboardLive.INT_PATH)..fileNameNew, 2)
	local dblReplacementExists = XMLFile.loadIfExists("DBL Replacement", DashboardLive.INT_PATH..fileNameNew, xmlFile.schema) ~= nil --and self.baseDirectory == ""
	dbgprint("loadDashboardCompoundFromXML :: dblReplacementExists = "..tostring(dblReplacementExists), 2)
	local baseDirectoryChanged = false
	
	if dblReplacementExists then
		xmlFile:setValue(key .. "#filename", fileNameNew)
		dbgprint("loadDashboardCompoundFromXML :: fileName replaced", 2)
		self.baseDirectoryBackup = self.baseDirectory
		self.baseDirectory = DashboardLive.INT_PATH
		baseDirectoryChanged = true
		dbgprint("loadDashboardCompoundFromXML :: baseDirectory temporarily changed", 2)
	end	
	
	local returnValue = superfunc(self, xmlFile, key, compound)
	
	if baseDirectoryChanged then
		self.baseDirectory = self.baseDirectoryBackup
		self.baseDirectoryBackup = nil
	end
		
	return returnValue
end
Dashboard.loadDashboardCompoundFromXML = Utils.overwrittenFunction(Dashboard.loadDashboardCompoundFromXML, DashboardUtils.loadDashboardCompoundFromXML)

-- load groups [and animations] out of alternative compound xml file
function DashboardUtils:onDashboardCompoundLoaded(i3dNode, failedReason, args)
	local spec = self.spec_dashboard
	local dashboardXMLFile = args.dashboardXMLFile
	local compound = args.compound
	local compoundKey = args.compoundKey
	
	dbgprint("onDashboardCompoundLoaded :: dashboardXMLFile: "..tostring(dashboardXMLFile.filename), 2)
	
-- compound extension: dashboard groups
	local i = 0
	while true do
		local baseKey = string.format("%s.group(%d)", "dashboardCompounds", i)
		dbgprint("onDashboardCompoundLoaded :: groups :: looking for key "..baseKey, 2)
		if not dashboardXMLFile:hasProperty(baseKey) then
			break
		end

		local group = {}
		if self:loadDashboardGroupFromXML(dashboardXMLFile, baseKey, group) then
			if spec.groups[group.name] ~= nil then
				Logging.xmlInfo(dashboardXMLFile, "Skipping already existing group "..tostring(group.name).."!")
			else
				spec.groups[group.name] = group			
				table.insert(spec.sortedGroups, group)
				dbgprint("onDashboardCompoundLoaded :: group "..tostring(group.name).." added", 2)
				spec.hasGroups = true
				spec.compoundGroupsLoaded = true
			end
		end
		dbgprint("onDashboardCompoundLoaded: Next group:", 2)
		i = i + 1
	end
	DashboardLive.createDashboardPages(self)
	
--[[ Deactivated because of engine restrictions:
-- compound extension: dashboard animations	
	if not spec.compoundAnimationsLoaded then
		local specAnim = self.spec_animatedVehicle

		dbgprint("onDashboardCompoundLoaded : loading animations", 1)
		
		-- prebuild components		
		compound.components = {}
		for i=1, getNumOfChildren(i3dNode) do
			table.insert(compound.components, {node=getChildAt(i3dNode, i - 1)})
		end
		
        -- preload i3dmappings
        compound.i3dMappings = {}
        I3DUtil.loadI3DMapping(dashboardXMLFile, "dashboardCompounds", compound.components, compound.i3dMappings, nil)
        dbgprint("onDashboardCompoundLoaded : i3dMappings:", 3)
		dbgprint_r(args.compound.i3dMappings, 3, 2)
      
        -- save i3dMappings and temporarily switch i3dmappings to compound's i3dmappings
		local i3dMappingsBackup = self.i3dMappings
		self.i3dMappings = compound.i3dMappings
	
		-- load animations
		local i = 0
		while specAnim ~= nil do
			local key = string.format("%s.animation(%d)", "dashboardCompounds", i)
			
			dbgprint("onDashboardCompoundLoaded :: animations :: looking for key "..key, 2)
			if not dashboardXMLFile:hasProperty(key) then
				break
			end
	
			local animation = {}
            if self:loadAnimation(dashboardXMLFile, key, animation, compound.components) then
                specAnim.animations[animation.name] = animation
                specAnim.compoundAnimationsLoaded = true
                dbgprint("onDashboardCompoundLoaded :: animation `"..tostring(animation.name).."` loaded", 2)
            end
	
			i = i + 1
		end
		
		-- restore i3dMappings
		self.i3dMappings = i3dMappingsBackup
	end
--]]
end
Dashboard.onDashboardCompoundLoaded = Utils.prependedFunction(Dashboard.onDashboardCompoundLoaded, DashboardUtils.onDashboardCompoundLoaded)