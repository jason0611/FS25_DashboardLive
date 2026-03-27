-- game fixes
--function AIAutomaticSteering:onWriteUpdateStream(streamId, connection, dirtyMask)

function fixAIAutomaticSteering_onWriteUpdateStream(self, superfunc, streamId, connection, dirtyMask)
	if not connection:getIsServer() then
		if self.spec_aiAutomaticSteering.steeringFieldCourse ~= nil then
			superfunc(self, streamId, connection, dirtyMask)
		else
			streamWriteBool(streamId, false)
			if bit32.band(dirtyMask, self.spec_aiAutomaticSteering.dirtyFlag) ~= 0 then
				dbgprint("AIAutomaticSteering.onWriteUpdateStream: error condition catched for "..tostring(self.getName ~= nil and self:getName() or "unknown vehicle"), 1)
				dbgprintCallstack(2)
			end
		end
	end
end
AIAutomaticSteering.onWriteUpdateStream = Utils.overwrittenFunction(AIAutomaticSteering.onWriteUpdateStream, fixAIAutomaticSteering_onWriteUpdateStream)