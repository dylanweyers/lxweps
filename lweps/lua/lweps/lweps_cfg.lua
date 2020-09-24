// Config file
lwep = {}

// Strings to be recognized as commands that will open the menu
lwep.cmds = {
	["!permweps"] = true,
	["!lweps"] = true,
}

// Table of specific users that can access the menu regardless of their in-game rank
lwep.users = {
	["STEAM_0:1:64763283"] = true,
}

// Table of in-game ranks that can open the menu
lwep.ranks = {
	["owner"] = true,
	["co-owner"] = true,
	["superadmin"] = true,
}
