-- game fixes
--function AIAutomaticSteering:onWriteUpdateStream(streamId, connection, dirtyMask)

function fixAIAutomaticSteering_onWriteUpdateStream(self, superfunc, streamId, connection, dirtyMask)
	if not connection:getIsServer() then
		if self.spec_aiAutomaticSteering.steeringFieldCourse == nil then
			streamWriteBool(streamId, false)
		else
			superfunc(self, streamId, connection, dirtyMask)
		end
	end
end
AIAutomaticSteering.onWriteUpdateStream = Utils.overwrittenFunction(AIAutomaticSteering.onWriteUpdateStream, fixAIAutomaticSteering_onWriteUpdateStream)