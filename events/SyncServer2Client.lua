SyncServer2ClientEvent = {}
local SyncServer2ClientEvent_mt = Class(SyncServer2ClientEvent, Event)
InitEventClass(SyncServer2ClientEvent, "SyncServer2ClientEvent")

function SyncServer2ClientEvent.emptyNew()
	return Event.new(SyncServer2ClientEvent_mt)
end

function SyncServer2ClientEvent.new(object, motorTemperature, fanEnabled, lastFuelUsage, lastDefUsage, lastAirUsage, currentDischargeState)
	local self = SyncServer2ClientEvent.emptyNew()
	self.object = object
	self.motorTemperature = motorTemperature
	self.fanEnabled = fanEnabled
	self.lastFuelUsage = lastFuelUsage
	self.lastDefUsage = lastDefUsage
	self.lastAirUsage = lastAirUsage
	self.currentDischargeState = currentDischargeState
	return self
end

function SyncServer2ClientEvent:writeStream(streamId, _)
	NetworkUtil.writeNodeObject(streamId, self.object)
	streamWriteFloat32(streamId, self.motorTemperature)
	streamWriteBool(streamId, self.fanEnabled)
	streamWriteFloat32(streamId, self.lastFuelUsage)
	streamWriteFloat32(streamId, self.lastDefUsage)
	streamWriteFloat32(streamId, self.lastAirUsage)
	streamWriteInt8(streamId, self.currentDischargeState)
	dbgprint("SyncServer2ClientEvent:writeStream : Written data successfully for "..self.object:getName(), 2)
end

function SyncServer2ClientEvent:readStream(streamId, connection)
	self.object = NetworkUtil.readNodeObject(streamId)
	self.motorTemperature = streamReadFloat32(streamId)
	self.fanEnabled = streamReadBool(streamId)
	self.lastFuelUsage = streamReadFloat32(streamId)
	self.lastDefUsage = streamReadFloat32(streamId)
	self.lastAirUsage = streamReadFloat32(streamId)
	self.currentDischargeState = streamReadInt8(streamId)
	dbgprint("SyncServer2ClientEvent:readStream : Read data successfully for "..self.object:getName(), 2)
	
	self:run(connection)
end

function SyncServer2ClientEvent:run(connection)
	if self.object ~= nil and self.object:getIsSynchronized() then
		self.object.spec_DashboardLive.motorTemperature = self.motorTemperature
		self.object.spec_DashboardLive.fanEnabled = self.fanEnabled
		self.object.spec_DashboardLive.lastFuelUsage = self.lastFuelUsage
		self.object.spec_DashboardLive.lastDefUsage = self.lastDefUsage
		self.object.spec_DashboardLive.lastAirUsage = self.lastAirUsage
		self.object.spec_DashboardLive.currentDischargeState = self.currentDischargeState
	end
	if not connection:getIsServer() then
		g_server:broadcastEvent(SyncServer2ClientEvent.new(self.object, self.motorTemperature, self.fanEnabled, self.lastFuelUsage, self.lastDefUsage, self.lastAirUsage, self.currentDischargeState), nil, connection, self.object)
	end
end

function SyncServer2ClientEvent.sendEvent(vehicle, motorTemperature, fanEnabled, lastFuelUsage, lastDefUsage, lastAirUsage, currentDischargeState, noEventSend)
	if noEventSend == nil or noEventSend == false then 
		if g_server ~= nil then
			g_server:broadcastEvent(SyncServer2ClientEvent.new(vehicle, motorTemperature, fanEnabled, lastFuelUsage, lastDefUsage, lastAirUsage, currentDischargeState), nil, nil, vehicle)
			return
		end
		g_client:getServerConnection():sendEvent(SyncServer2ClientEvent.new(vehicle, motorTemperature, fanEnabled, lastFuelUsage, lastDefUsage, lastAirUsage, currentDischargeState))
	end
end