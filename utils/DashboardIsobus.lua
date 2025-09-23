DashboardIsobus = {}

if DashboardIsobus.MOD_NAME == nil then
	DashboardIsobus.MOD_NAME = g_currentModName
	DashboardIsobus.MOD_PATH = g_currentModDirectory
end

DashboardIsobus.XMLkey = "vehicle.dashboardLive"

source(DashboardIsobus.MOD_PATH.."tools/gmsDebug.lua")
GMSDebug:init(DashboardIsobus.MOD_NAME, true, 2)
--GMSDebug:enableConsoleCommands("dblDebug")

function DashboardIsobus.prerequisitesPresent(specializations)
  return SpecializationUtil.hasSpecialization(Attachable, specializations)
end

function DashboardIsobus.registerEventListeners(vehicleType)
	SpecializationUtil.registerEventListener(vehicleType, "onLoad", DashboardIsobus)
	SpecializationUtil.registerEventListener(vehicleType, "onPreLoad", DashboardIsobus)
--  SpecializationUtil.registerEventListener(vehicleType, "onPostLoad", DashboardIsobus)
--	SpecializationUtil.registerEventListener(vehicleType, "onRegisterDashboardValueTypes", DashboardIsobus)
--	SpecializationUtil.registerEventListener(vehicleType, "onRegisterActionEvents", DashboardIsobus)
--	SpecializationUtil.registerEventListener(vehicleType, "onReadStream", DashboardIsobus)
--	SpecializationUtil.registerEventListener(vehicleType, "onWriteStream", DashboardIsobus)
--	SpecializationUtil.registerEventListener(vehicleType, "onReadUpdateStream", DashboardIsobus)
--	SpecializationUtil.registerEventListener(vehicleType, "onWriteUpdateStream", DashboardIsobus)
--	SpecializationUtil.registerEventListener(vehicleType, "onUpdate", DashboardIsobus)
--	SpecializationUtil.registerEventListener(vehicleType, "onDraw", DashboardIsobus)
--	SpecializationUtil.registerEventListener(vehicleType, "onPostAttachImplement", DashboardIsobus)
end

function DashboardIsobus:onPreLoad(savegame)
	self.spec_DashboardIsobus = self["spec_"..DashboardIsobus.MOD_NAME..".DashboardIsobus"]
end

function DashboardIsobus:onLoad(savegame)
	local spec = self.spec_DashboardIsobus 
	local xmlFileName = self.xmlFile.filename
	local xmlFile = XMLFile.load("DBL ISOBUS", xmlFileName, self.xmlFile.schema)
	if xmlFile:hasProperty(DashboardIsobus.XMLkey) then
		local isobusFilename = xmlFile:getValue(DashboardIsobus.XMLkey .. "#isobusTerminal")
		if isobusFile ~= nil and fileExists(isobusFilename) then
			spec.xmlFile = isobusFilename
		else
			self.spec_DashboardIsobus = nil
		end
	end
end
