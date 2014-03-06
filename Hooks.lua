
-- This file has all the Hook handlers.



-- OnWorldStarted. Needed to send a Finished generating world message.
function OnWorldStarted(a_World)
	local WorldName = a_World:GetName()
	
	-- Check if we have to send a message to the player.
	if (not g_WorldsGenerating[WorldName]) then
		return false
	end
	
	-- Send a message to the player.
	cRoot:Get():FindAndDoWithPlayer(g_WorldsGenerating[WorldName], function(a_Player)
		a_Player:SendMessage(cChatColor.Red .. "[WorldWarp]: " .. cChatColor.Yellow .. "Done generating " .. WorldName)
	end)
	
	-- Remove the player from the list.
	g_WorldsGenerating[WorldName] = nil
	
	return false
end