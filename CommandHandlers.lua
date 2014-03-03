
-- This file implements the command handlers





-- Gives a message in return a list of all the active worlds
function HandleWListCommand(a_Split, a_Player)
	-- /wlist
	
	a_Player:SendMessage(cChatColor.Red .. "[WorldWarp] Worlds")
	
	-- Note each world and give them their appropriate color. The color depends on the dimension
	cRoot:Get():ForEachWorld(function(a_World)
		local Dimension = a_World:GetDimension()
		if (Dimension == dimOverworld) then
			a_Player:SendMessage("- " .. cChatColor.Green .. a_World:GetName())
		elseif (Dimension == dimNether) then
			a_Player:SendMessage("- " .. cChatColor.Red .. a_World:GetName())
		else
			a_Player:SendMessage("- " .. cChatColor.LightBlue .. a_World:GetName())
		end
	end)
	return true
end