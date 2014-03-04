
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
	
	-- Retrieve the worldname but don't take "//wwarp" with it.
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





function HandleWCreateCommand(a_Split, a_Player)
	-- /wcreate [Name] [Envireonment] <seed> -flags
	
	-- Check if the player gave enough arguments.
	if (#a_Split < 3) then
		a_Player:SendMessage(cChatColor.Red .. "[WorldWarp]: Use /wcreate [name] [environment] <seed>")
		return true
	end
	
	-- All the changes to the world.ini will be stored here and later on be written to the file.
	local WorldIniChanges = {}
	
	-- Check if the given dimension is valid and get the proper configuration from it.
	local Dimension = a_Split[3]:upper()
	
	if (Dimension == "NETHER") then -- The dimension is Nether. That means flat heightmap, a 30 layer high lava finisher, water vaporizing etc
		table.insert(WorldIniChanges, {Key = "Generator", ValueName = "CompositionGen", Value = "Nether"})
		table.insert(WorldIniChanges, {Key = "Generator", ValueName = "HeightGen", Value = "Flat"})
		table.insert(WorldIniChanges, {Key = "Generator", ValueName = "FlatHeight", Value = "128"}) -- Insert the config for the flat height generator
		
		-- Set the biome generator to constant and make it generate a hell biome.
		table.insert(WorldIniChanges, {Key = "Generator", ValueName = "BiomeGen", Value = "Constant"})
		table.insert(WorldIniChanges, {Key = "Generator", ValueName = "ConstantBiome", Value = "Hell"}) -- make the constantbiome generator only generate nether biomes
		
		-- Add finishers
		table.insert(WorldIniChanges, {Key = "Generator", ValueName = "Finishers", Value = "LavaSprings,BottomLava,NetherClumpFoliage,PreSimulator"})
		table.insert(WorldIniChanges, {Key = "Generator", ValueName = "BottomLavaLevel", Value = "30"}) -- This is needed for the BottomLava finisher
		
		-- No structures
		table.insert(WorldIniChanges, {Key = "Generator", ValueName = "Structures", Value = ""})
		
		-- Make the dimension "nether"
		table.insert(WorldIniChanges, {Key = "General", ValueName = "Dimension", Value = "-1"})
		
		-- Simulators
		table.insert(WorldIniChanges, {Key = "Physics", ValueName = "WaterSimulator", Value = "Vaporize"})
		table.insert(WorldIniChanges, {Key = "Physics", ValueName = "LavaSimulator", Value = "Floody"})
		table.insert(WorldIniChanges, {Key = "LavaSimulator", ValueName = "MaxHeight", Value = "6"}) -- lava in the nether should spread 8 blocks
		
		-- Mobs
		table.insert(WorldIniChanges, {Key = "Monsters", ValueName = "Types", Value = "zombiepigman, Ghast, magmacube, Blaze"})
		
	elseif (Dimension == "THE_END") then -- End dimension. No finishers and only set the composition- and height gen
		table.insert(WorldIniChanges, {Key = "Generator", ValueName = "CompositionGen", Value = "end"})
		table.insert(WorldIniChanges, {Key = "Generator", ValueName = "HeightGen", Value = "End"})
		
		-- Set the biome generator to constant and make it generate a hell biome.
		table.insert(WorldIniChanges, {Key = "Generator", ValueName = "BiomeGen", Value = "Constant"})
		table.insert(WorldIniChanges, {Key = "Generator", ValueName = "ConstantBiome", Value = "sky"}) -- make the constantbiome generator only generate nether biomes
		
		-- No structures
		table.insert(WorldIniChanges, {Key = "Generator", ValueName = "Structures", Value = ""})
		
		-- No finishers
		table.insert(WorldIniChanges, {Key = "Generator", ValueName = "Finishers", Value = ""})
		
		-- Make the dimension "the end"
		table.insert(WorldIniChanges, {Key = "General", ValueName = "Dimension", Value = "1"})
		
		-- Mobs
		table.insert(WorldIniChanges, {Key = "Monsters", ValueName = "Types", Value = "enderman"})
	else
		a_Player:SendMessage(cChatColor.Red .. "[WorldWarp]: You can only create: NORMAL/NETHER/THE_END/FLATLANDS")
		return true
	end
	
	-- Check if there is a world activated with the same name already.
	if (cRoot:Get():GetWorld(a_Split[2]) ~= nil) then
		a_Player:SendMessage(cChatColor.Red .. "[WorldWarp]: That world already exists, use /wlist to see active worlds.")
		return true
	end
	
	-- Check if there is a world with the same name already there.
	if (not cFile:CreateFolder(a_Split[2]) and cFile:Exists(a_Split[2] .. "/level.dat")) then
		a_Player:SendMessage(cChatColor.Red .. "[WorldWarp]: A world by that name seems to exist. Try /wimport " .. a_Split[2])
		return true
	end
	
	-- Remove the command, the worldname and the environment from the flags. We check if a seed is given later on.
	local Flags = a_Split
	for I=3, 1, -1 do
		table.remove(Flags, I)
	end
	
	-- Set the seed if given. Also remove it from the arguments
	if (tonumber(a_Split[4]) ~= nil then
		table.insert(WorldIniChanges, {Key = "Seed", ValueName = "Seed", Value = a_Split[4]})
		table.remove(Flags, 1)
	end
	
	-- Check for any extra flags.
	for Idx, Flag in ipairs(Flags) do
		local Flag = Flag:upper()
		if (Flag == "-PVP") then
			table.insert(WorldIniChanges, {Key = "Mechanics", ValueName = "PVPEnabled", Value = "1"})
		elseif (Flag == "-NOPVP") then
			table.insert(WorldIniChanges, {Key = "Mechanics", ValueName = "PVPEnabled", Value = "0"})
		end 
		-- ToDO: More flags.
	end
	
	-- Open the world config file
	local WorldIni = cIniFile()
	WorldIni:ReadFile(a_Split[2] .. "/world.ini")
	
	-- Save the settings.
	for Idx, Table in ipairs(WorldIniChanges) do
		WorldIni:SetValue(Table.Key, Table.ValueName, Table.Value)
	end
	
	-- Write to the ini file.
	WorldIni:WriteFile(a_Split[2] .. "/world.ini")
	
	-- Send a message to the player that we're going to initialize the world and generate the chunks.
	a_Player:SendMessage(cChatColor.Red .. "[WorldWarp]: " .. cChatColor.Green .. "Generating world: " .. a_Split[2])
	
	-- And finaly generate the world.
	cRoot:Get():CreateAndInitializeWorld(a_Split[2])
	return true
end
	