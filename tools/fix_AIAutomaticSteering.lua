-- game fixes
--function AIAutomaticSteering:onWriteUpdateStream(streamId, connection, dirtyMask)

function fixAIAutomaticSteering_onWriteUpdateStream(self, superfunc, streamId, connection, dirtyMask)
	if self.spec_aiAutomaticSteering.steeringFieldCourse == nil then
		streamWriteBool(streamId, false)
	else
		superfunc(self, streamId, connection, dirtyMask)
	end

--	local spec = self.spec_aiAutomaticSteering
--	if not connection:getIsServer() then
--		if streamWriteBool(streamId, spec.steeringFieldCourse ~= nil and (bit32.band(dirtyMask, self.spec_aiAutomaticSteering.dirtyFlag) ~= 0)) then
--			if spec.steeringFieldCourse ~= nil then
--				spec.steeringFieldCourse:writeSegmentStatesToStream(streamId, connection)
--			end
--		end
--	end
end
AIAutomaticSteering.onWriteUpdateStream = Utils.overwrittenFunction(AIAutomaticSteering.onWriteUpdateStream, fixAIAutomaticSteering_onWriteUpdateStream)