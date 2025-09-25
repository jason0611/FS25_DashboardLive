DashboardIsobus = {}

if DashboardIsobus.MOD_NAME == nil then
	DashboardIsobus.MOD_NAME = g_currentModName
	DashboardIsobus.MOD_PATH = g_currentModDirectory
end

DashboardIsobus.XMLkey = "vehicle.dashboard.dashboardLive.isobus"

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

function DashboardIsobus:initSpecialization()
	local schema = Vehicle.xmlSchema
	Dashboard.registerDashboardXMLPaths(schema, "vehicle.dashboard.dashboardLive", "dbl.isobus")
	DashboardIsobus.DBL_XML_KEY = "vehicle.dashboard.dashboardLive.isobus"
	schema:register(XMLValueType.STRING, DashboardIsobus.DBL_XML_KEY .. "#isobusTerminal", "ISOBUS file")
	dbgprint("initSpecialization : DashboardIsobus: "..tostring(DashboardIsobus.DBL_XML_KEY .. "#isobusTerminal").." registered", 2)
end

function DashboardIsobus:onPreLoad(savegame)
	self.spec_DashboardIsobus = self["spec_"..DashboardIsobus.MOD_NAME..".DashboardIsobus"]
end

function DashboardIsobus:onLoad(savegame)
	local spec = self.spec_DashboardIsobus 
	local vehicleXmlSchema = self.xmlFile.schema
	local implementXmlFilename = self.xmlFile.filename
	local implementXmlFile = XMLFile.load("IMPLEMENT", implementXmlFilename, vehicleXmlSchema)
	if implementXmlFile:hasProperty(DashboardIsobus.XMLkey) then
		local isobusFilename = implementXmlFile:getValue(DashboardIsobus.XMLkey .. "#isobusTerminal")
		local isobusFilepath = self.baseDirectory
		dbgprint("onLoad: ISOBUS filename = "..tostring(isobusFilename), 1)
		dbgprint("onLoad: ISOBUS filepath = "..tostring(isobusFilepath), 1)
		if isobusFilename ~= nil then
			spec.xmlFilename = isobusFilename
			spec.xmlFilepath = isobusFilepath
--			spec.xmlFile = XMLFile.load("ISOBUS", isobusFilename, vehicleXmlSchema)
		else
			self.spec_DashboardIsobus = nil
		end
	end
end
