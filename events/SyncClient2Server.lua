SyncClient2ServerEvent = {}
local SyncClient2ServerEvent_mt = Class(SyncClient2ServerEvent, Event)
InitEventClass(SyncClient2ServerEvent, "SyncClient2ServerEvent")

function SyncClient2ServerEvent.emptyNew()
	return Event.new(SyncClient2ServerEvent_mt)
end

function SyncClient2ServerEvent.new(object, maxPageGroup, pageGroups, orientation, leaveTime)
	local self = SyncClient2ServerEvent.emptyNew()
	self.object = object
	self.maxPageGroup = maxPageGroup
	self.pageGroups = pageGroups
	self.orientation = orientation
	self.leaveTime = leaveTime
	return self
end

function SyncClient2ServerEvent:writeStream(streamId, _)
	NetworkUtil.writeNodeObject(streamId, self.object)
	streamWriteInt8(streamId, self.maxPageGroup)
	for pg = 1, self.maxPageGroup do
		streamWriteInt8(streamId, self.pageGroups[pg] ~= nil and self.pageGroups[pg].actPage or 1)
		dbgprint("SyncClient2ServerEvent:writeStream : actPage sent = "..tostring(actPage), 2)
	end
	streamWriteString(streamId, self.orientation)
	streamWriteFloat32(streamId, self.leaveTime)
	dbgprint("SyncClient2ServerEvent:writeStream : Written data for "..self.object:getName(), 2)
end

function SyncClient2ServerEvent:readStream(streamId, connection)
	self.object = NetworkUtil.readNodeObject(streamId)
	self.maxPageGroup = streamReadInt8(streamId)
	self.pageGroups = {}
	for pg = 1, self.maxPageGroup do
		self.pageGroups[pg] = {}
		self.pageGroups[pg].actPage = streamReadInt8(streamId)
		dbgprint("SyncClient2ServerEvent:readStream : actPage "..tostring(pg).." read = "..tostring(self.pageGroups[pg]), 2)
	end
	self.orientation = streamReadString(streamId)
	self.leaveTime = streamReadFloat32(streamId)
	dbgprint("SyncClient2ServerEvent:readStream : Read data successfully for "..self.object:getName(), 2)
	
	self:run(connection)
end

function SyncClient2ServerEvent:run(connection)
	if self.object ~= nil and self.object:getIsSynchronized() then
		self.object.spec_DashboardLive.maxPageGroup = self.maxPageGroup
		for pg = 1, self.maxPageGroup do
			self.object.spec_DashboardLive.pageGroups[pg].actPage = self.pageGroups[pg].actPages
		end
		self.object.spec_DashboardLive.orientation = self.orientation
		self.object.spec_DashboardLive.leaveTime = self.leaveTime
	end
	if not connection:getIsServer() then
		g_server:broadcastEvent(SyncClient2ServerEvent.new(self.object, self.maxPageGroup, self.pageGroups, self.orientation, self.leaveTime), nil, connection, self.object)
	end
end

function SyncClient2ServerEvent.sendEvent(vehicle, maxPageGroup, pageGroups, orientation, leaveTime, noEventSend)
	if noEventSend == nil or noEventSend == false then 
		if g_server ~= nil then
			g_server:broadcastEvent(SyncClient2ServerEvent.new(vehicle, maxPageGroup, pageGroups, orientation, leaveTime), nil, nil, vehicle)
			return
		end
		g_client:getServerConnection():sendEvent(SyncClient2ServerEvent.new(vehicle, maxPageGroup, pageGroups, orientation, leaveTime))
	end
end