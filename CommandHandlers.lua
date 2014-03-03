
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





-- Sends a player to a different world.
function HandleWWarpCommand(a_Split, a_Player)
	-- /wwarp [WorldName]
	
	-- Check if the player gave at least more then one argument
	if (#a_Split == 1) then
		a_Player:SendMessage(cChatColor.Red .. "[WorldWarp]: Use /wwarp [name].")
		return true
	end
	
	-- Retrieve the worldname but don't take "//wwarp" whith it.
	local WorldName = table.concat(a_Split, " ", 2)
	local DstWorld = cRoot:Get():GetWorld(WorldName)
	
	-- Check if the world actualy exists
	if (DstWorld == nil) then
		a_Player:SendMessage(cChatColor.Red .. "[WorldWarp]: That world does not exist.")
		a_Player:SendMessage(cChatColor.Red .. "[WorldWarp]: Use /wlist to see worlds.")
		return true
	end
	
	-- Move the player to the world and teleport to the spawn coordinates
	a_Player:MoveToWorld(WorldName)
	a_Player:TeleportToCoords(DstWorld:GetSpawnX(), DstWorld:GetSpawnY(), DstWorld:GetSpawnZ())
	
	-- Send a welcome message to the player.
	a_Player:SendMessage(cChatColor.Red .. "[WorldWarp]: " .. cChatColor.Green .. "Welcome to " .. WorldName)
	return true
end




