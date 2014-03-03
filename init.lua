
g_Plugin = nil
g_LastPlayerPositions = {}





-- Contains the Initialize and OnDisable function.





function Initialize(a_Plugin)
	a_Plugin:SetName("WorldWarp")
	a_Plugin:SetVersion(1)
	
	g_Plugin = a_Plugin
	
	-- Load the InfoReg shared library:
	dofile(cPluginManager:GetPluginsPath() .. "/InfoReg.lua")
	
	-- Bind the commands
	RegisterPluginInfoCommands()
	
	-- Say we finished loading.
	LOG("[WorldWarp] Enabled! Running " .. g_Plugin:GetVersion())
	
	LOG(" _  _  _             _     _ _  _  _                         ")
	LOG("| || || |           | |   | | || || |                        ")
	LOG("| || || | ___   ____| | _ | | || || | ____  ____ ____        ")
	LOG("| ||_|| |/ _ \\ / ___) |/ || | ||_|| |/ _  |/ ___)  _ \\     ")
	LOG("| |___| | |_| | |   | ( (_| | |___| ( ( | | |   | | | |      ")
	LOG(" \\______|\\___/|_|   |_|\\____|\\______|\\_||_|_|   | ||_/  ")
	LOG("                                                |_|          ")
	return true
end





function OnDisable()
	LOG("[WorldWarp] Disabling WorldWarp v" .. g_Plugin:GetVersion())
end




