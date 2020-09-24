//Set up sql tables

hook.Add("Initialize", "lwepsdatatables", function()
	if not sql.TableExists("lweps") then
		print("[LWEPS] No data tables")
		sql.Query("CREATE TABLE lweps( steamid TEXT, weapons TEXT )")
		if sql.TableExists("lweps") then
			print("[LWEPS] Data tables created")
		else
			print("[LWEPS] Data tables failed")
		end
	else
		print("[LWEPS] Tables exist")
	end
end )

//Query for adding or deleting entries

local function lwepquery( ply, act, wep )
	if act == "add" then
		if not sql.Query("SELECT weapons FROM lweps WHERE steamid="..SQLStr(ply).." AND weapons="..SQLStr(wep).."") then
			sql.Query("INSERT INTO lweps( steamid, weapons ) VALUES( "..SQLStr(ply)..", "..SQLStr(wep).." )")
		end
	elseif act == "del" then
		sql.Query("DELETE FROM lweps WHERE weapons="..SQLStr(wep).." AND steamid="..SQLStr(ply).."")
	end
end

// Uses lwepquery to add or delete weapons as per menu user request, just saves me having to type all the arguments every time

util.AddNetworkString("lweprequest")

local function uselwepquery(len, ply)
	if lwep.ranks[ply:GetUserGroup()] then
		local targetply = net.ReadString()
		local lwepact = net.ReadString()
		local lwepwep = net.ReadString()
		lwepquery(targetply, lwepact, lwepwep )
	end
end
net.Receive("lweprequest",uselwepquery)

// Give player their weapons on spawn

hook.Add("PlayerSpawn", "lweps_givewep", function(ply)
	local qy = sql.Query("SELECT weapons FROM lweps WHERE steamid="..SQLStr(ply:SteamID()).."")
	if qy then
		for k, v in pairs(qy) do
			ply:Give(qy[k].weapons)
		end
	end
end )

// Serverside notification function (sends a net message to the target client, which is then processed on the client to create the clientside part of the notification)

util.AddNetworkString("lwepnoti")
local function lwepn(ply,text,col)
	if ply and text then
		if not col then 
			col = Color(255,255,255)
		end
		net.Start("lwepnoti")
			net.WriteString(text)
			net.WriteColor(col)
		net.Send(ply)
	end
end

// Network the menu (sends the net message to the client so the client knows when to draw the menu)

util.AddNetworkString("lwepmenu")
local function lwepmenu(ply)
	net.Start("lwepmenu")
		local count = 0
		for k, v in pairs(player.GetAll()) do
			local qy = sql.Query("SELECT * FROM lweps WHERE steamid="..SQLStr(v:SteamID()).."")
			if qy then count = count + 1 end
		end
		net.WriteDouble(count)
		for k, v in pairs(player.GetAll()) do
			local qy = sql.Query("SELECT * FROM lweps WHERE steamid="..SQLStr(v:SteamID()).."")
			if qy then
				local newqy = {}
				table.insert(newqy, v:SteamID())
				for l, b in pairs(qy) do
					table.insert(newqy,b.weapons)
				end
				net.WriteTable(newqy)
			end
		end
	net.Send(ply)
end

// Chat Command Hook (when a player types in chat, checks to see if they typed the command specified in the config file)

hook.Add("PlayerSay", "lweps_cmd", function(ply, text)
	if lwep.cmds[text] then
		if lwep.ranks[ply:GetUserGroup()] then
			lwepmenu(ply)
		else
			lwepn(ply,"[LWeps] You do not have access to this command.", Color(179,20,70))
		end
	end
end)
