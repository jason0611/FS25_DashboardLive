SyncClient2ServerEvent = {}
local SyncClient2ServerEvent_mt = Class(SyncClient2ServerEvent, Event)
InitEventClass(SyncClient2ServerEvent, "SyncClient2ServerEvent")

function SyncClient2ServerEvent.emptyNew()
	return Event.new(SyncClient2ServerEvent_mt)
end

function SyncClient2ServerEvent.new(object, orientation, leaveTime)
	local self = SyncClient2ServerEvent.emptyNew()
	self.object = object
	self.pageGroups = self.object.spec_DashboardLive.pageGroups
	self.orientation = orientation
	self.leaveTime = leaveTime
	return self
end

function SyncClient2ServerEvent:readStream(streamId, connection)
	self.object = NetworkUtil.readNodeObject(streamId)
	self.pageGroups = self.object.spec_DashboardLive.pageGroups
	self.orientation = streamReadString(streamId)
	self.leaveTime = streamReadFloat32(streamId)
	dbgprint("SyncClient2ServerEvent:readStream : Read data for "..self.object:getName(), 2)
	
	self:run(connection)
end

function SyncClient2ServerEvent:writeStream(streamId, _)
	NetworkUtil.writeNodeObject(streamId, self.object)
	
	streamWriteString(streamId, self.orientation)
	streamWriteFloat32(streamId, self.leaveTime)
	dbgprint("SyncClient2ServerEvent:writeStream : Written data for "..self.object:getName(), 2)
end

function SyncClient2ServerEvent:run(connection)
	if self.object ~= nil and self.object:getIsSynchronized() then
		local spec = self.object.spec_DashboardLive
		spec.pageGroups = self.pageGroups
		spec.orientation = self.orientation
		spec.leaveTime = self.leaveTime
	end
	if not connection:getIsServer() then
		g_server:broadcastEvent(SyncClient2ServerEvent.new(self.object, self.object.spec_DashboardLive.orientation, self.object.spec_DashboardLive.leaveTime), nil, connection, self.object)
	end
end

function SyncClient2ServerEvent.sendEvent(vehicle, orientation, leaveTime, noEventSend)
	if noEventSend == nil or noEventSend == false then 
		if g_server ~= nil then
			g_server:broadcastEvent(SyncClient2ServerEvent.new(vehicle, orientation, leaveTime), nil, nil, vehicle)
			return
		end
		g_client:getServerConnection():sendEvent(SyncClient2ServerEvent.new(vehicle, orientation, leaveTime))
	end
end