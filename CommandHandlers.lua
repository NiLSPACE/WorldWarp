
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
	
	-- Set the last coordinates to the current one
	g_LastPlayerPositions[a_Player:GetName()] = {WorldName = a_Player:GetWorld():GetName(), PosX = a_Player:GetPosX(), PosY = a_Player:GetPosY(), PosZ = a_Player:GetPosZ()}
	
	-- Move the player to the world and teleport to the spawn coordinates
	a_Player:MoveToWorld(WorldName)
	a_Player:TeleportToCoords(DstWorld:GetSpawnX(), DstWorld:GetSpawnY(), DstWorld:GetSpawnZ())
	
	-- Send a welcome message to the player.
	a_Player:SendMessage(cChatColor.Red .. "[WorldWarp]: " .. cChatColor.Green .. "Welcome to " .. WorldName)
	return true
end





-- Sends the player back to the previous coordinates
function HandleWBackCommand(a_Split, a_Player)
	-- /wback
	
	local PlayerName = a_Player:GetName()
	
	-- Check if the player has position data. If not send a message end bail out.
	if (g_LastPlayerPositions[PlayerName] == nil) then
		a_Player:SendMessage(cChatColor.Red .. "[WorldWarp]: We don't have any data of previous teleports.")
		return true
	end
	
	-- Check if the previous world still exists.
	local DstWorld = cRoot:Get():GetWorld(g_LastPlayerPositions[PlayerName].WorldName)
	if (DstWorld == nil) then
		a_Player:SendMessage(cChatColor.Red .. "[WorldWarp]: That world does not exist anymore o_O")
		return true
	end
	
	-- Save the previous last coordinates and save the current ones
	local LastCoordinates = g_LastPlayerPositions[PlayerName]
	g_LastPlayerPositions[PlayerName] = {WorldName = a_Player:GetWorld():GetName(), PosX = a_Player:GetPosX(), PosY = a_Player:GetPosY(), PosZ = a_Player:GetPosZ()}
	
	-- Teleport to the latest world and coordinates
	a_Player:MoveToWorld(LastCoordinates.WorldName)
	a_Player:TeleportToCoords(LastCoordinates.PosX, LastCoordinates.PosY, LastCoordinates.PosZ)
	
	-- Send a welcome message
	a_Player:SendMessage(cChatColor.Red .. "[WorldWarp]: " .. cChatColor.Green .. "Welcome to " .. DstWorld:GetName())
	return true
end




