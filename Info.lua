
-- Info.lua

-- Implements the g_PluginInfo standard plugin description.

g_PluginInfo =
{
	Name    = "WorldWarp",
	Version = "1",
	Date = "2014-3-3",
	SourceLocation = "https://github.com/STRWarrior/WorldWarp",
	Description = [[
	This plugin allows people to easily create, import, and move between worlds. 
	Later on there will probably be more features but the MCServer API needs to change for that.]],
	Commands =
	{
		["/wlist"] =
		{
			Permission = "WorldWarp.wlist",
			Handler    = HandleWListCommand,
			HelpString = "Lists active worlds.",
		},
		
		["/wwarp"] =
		{
			Permission = "WorldWarp.wwarp",
			Handler    = HandleWWarpCommand,
			HelpString = "Warps to desired world.",
		},
		
		["/wback"] =
		{
			Permission = "WorldWarp.wback",
			Handler    = HandleWBackCommand,
			HelpString = "Returns to previous world.",
		},
	},
}