// Not much commentation for the clientside code as it is very repetitive and much the same
// Variable for a rainbow style colour system (changes colour every tick based on the sin of the time)
local luxrainbow
hook.Add("Think", "lurainbow", function()
	luxrainbow = HSVToColor(math.sin(CurTime()) * 50,1,1)
end)

//Menu blur
local blur = Material( "pp/blurscreen" )
function lwepblur( panel, layers, density, alpha )
    local x, y = panel:LocalToScreen(0, 0)
    surface.SetDrawColor( 255, 255, 255, alpha )
    surface.SetMaterial( blur )
    for i = 1, 3 do
        blur:SetFloat( "$blur", ( i / layers ) * density )
        blur:Recompute()

        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect( -x, -y, ScrW(), ScrH() )
    end
end

// Fonts
surface.CreateFont( "lpp_smol", {
    font = "Roboto Lt",
    size = 16,
    weight = 400,
    antialias = true,
    extended = true,
} )

surface.CreateFont( "lpp_big", {
    font = "Roboto Lt",
    size = 32,
    weight = 500,
    antialias = true,
    extended = true,
} )

// Chat Notification (receiving the net message the server sends and adding the arguments of the serverside function to the chat window)
local function wepndisplay(len,ply)
	local txt = net.ReadString()
	local col = net.ReadColor() or Color(255,255,255)
	chat.AddText(col,txt)
end
net.Receive("lwepnoti", wepndisplay)

// Custom outline function. As mentioned previously, the clientside code for this is very repetitive and this function allows me to type 1 function instead of 2 lines of code every time.

local function lwepoutline(col,x,y,w,h)
	surface.SetDrawColor(col)
	surface.DrawOutlinedRect(x,y,w,h)
end
// Open menu
local function openlwepmenu()
	local count = 0
	surface.PlaySound( "UI/buttonclick.wav" )
	local lwepm = vgui.Create("DFrame") --Creating the base menu window
	lwepm:SetSize(1368,720)
	lwepm:Center()
	lwepm:MakePopup()
	lwepm:SetTitle("")
	lwepm:ShowCloseButton(false)
	lwepm.Paint = function(self,w,h)
		lwepblur(self, 20, 10, 170)
		draw.RoundedBox(0,0,0,w,h,Color(24,24,24,240))
		lwepoutline(luxrainbow,0,0,w,h)
		lwepoutline(luxrainbow,1,1,w-2,h-2)
	end

	local lwepmwindow = vgui.Create("DPanel", lwepm)
	lwepmwindow:SetSize(lwepm:GetWide(), 30)
	lwepmwindow.Paint = function(self,w,h)
		surface.SetDrawColor(HSVToColor(math.sin(CurTime()) * 50,1,.6))
		surface.DrawLine( 300, 10, 1070, 10)
		surface.DrawLine( 300, 15, 1070, 15)
		surface.DrawLine( 300, 20, 1070, 20)
		draw.SimpleText("P   E   R   M   A                 W   E   A   P   O   N                 M   E   N   U", "lpp_big", self:GetWide()/2, self:GetTall()/2+2, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		lwepoutline(luxrainbow,0,0,w,h)
	end

	local lwepm_close = vgui.Create("DButton", lwepmwindow)
	lwepm_close:SetText("")
	lwepm_close:SetSize(60,30)
	lwepm_close:SetPos(lwepmwindow:GetWide()-lwepm_close:GetWide(),0)
	lwepm_close.Paint = function(self,w,h)
		lwepoutline(Color(255,0,0),0,2,w-2,h-3)
		draw.SimpleText("Close", "lpp_smol", self:GetWide()/2, self:GetTall()/2, Color(255,0,0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		if self:IsHovered() then
			draw.RoundedBox(0,0,0,w,h,Color(179,12,5,25))
		end
	end
	lwepm_close.DoClick = function() --Closes the menu
		surface.PlaySound( "UI/buttonclick.wav" )
		lwepm:Close()
	end
	// Start of scroll bar 'paint' code (paint here refers to any modifications to how the vgui element looks)
	local lwepms = vgui.Create( "DScrollPanel", lwepm )
	lwepms:Dock( FILL )
	lwepms.Paint = function(self,w,h)
	end

	local wepsbar = lwepms:GetVBar()
	function wepsbar:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
		surface.SetDrawColor(luxrainbow)
		surface.DrawOutlinedRect(0,0,w,h)
	end
	function wepsbar.btnUp:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0,0,0 ) )
		draw.SimpleText("▲", "lpp_smol", self:GetWide()/2, self:GetTall()/2-2, luxrainbow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		if self:IsHovered() then
			draw.RoundedBox(0,0,0,w,h,luxrainbow)
		end
		surface.SetDrawColor(luxrainbow)
		surface.DrawOutlinedRect(0,0,w,h)
	end
	function wepsbar.btnDown:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0,0,0 ) )
		draw.SimpleText("▼", "lpp_smol", self:GetWide()/2, self:GetTall()/2, luxrainbow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		if self:IsHovered() then
			draw.RoundedBox(0,0,0,w,h,luxrainbow)
		end
		surface.SetDrawColor(luxrainbow)
		surface.DrawOutlinedRect(0,0,w,h)
	end
	function wepsbar.btnGrip:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 36,36,36 ) )
		draw.SimpleText("↕", "lpp_big", self:GetWide()/2, self:GetTall()/2, luxrainbow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		if self:IsHovered() then
			draw.RoundedBox(0,0,0,w,h,luxrainbow)
		end
		surface.SetDrawColor(luxrainbow)
		surface.DrawOutlinedRect(0,0,w,h)
	end
	// End of scrollbar paint
	// The serverside function sends a net message for every item in the list, so we send a net message containing the AMOUNT of items.
	// Then we insert the item into this table with the for loop.
	// For example, if we have 5 items, this code block will insert to the table the first, second, third, fourth and fifth table that was networked to the client.
	local bigtbl = {}
	for i = 1, net.ReadDouble() do 
		table.insert(bigtbl,net.ReadTable())
	end

	// This loops through all players and creates a vgui element for each of them, with certain details such as their name and unique id. 
	// This is so administrators can add or remove permanent weapons/tools from players
	for k, v in pairs(player.GetAll()) do
		local pname = v:Name()
		local pstid = v:SteamID()
		local prank = string.upper(v:GetUserGroup()) -- prank here refers to Player Rank, not an actual prank
		local lwepplayer = vgui.Create("DPanel",lwepms)
		local pjob = v:getJobTable()
		local str = ""
		local str2 = ""
		if table.Count(pjob.weapons) == 0 then str = "nothing" end
		for key, val in pairs(pjob.weapons) do
			if key < 9 then
				str = str..val.."  |  "
			else
				str2 = str2..val.."  |  "
			end
		end
		local str3 = ""
		local str4 = ""
		for b, n in pairs(bigtbl) do
			if n[1] == v:SteamID() then
				for key, value in pairs(n) do
					if value != v:SteamID() then
						if key < 9 then
							str3 = str3..value.."  |  "
						else
							str4 = str4..value.."  |  "
						end
					end
				end
				break
			end
		end
		if #str3 == 0 then str3 = "nothing" end
		lwepplayer:Dock( TOP )
		lwepplayer:DockMargin(5,5,5,5)
		lwepplayer:SetSize(lwepm:GetWide(),100)
		local lwepjobs = true
		lwepplayer.Paint = function(self,w,h)
			draw.RoundedBox(50,0,0,w,h,luxrainbow)
			draw.RoundedBox(48,1,2,w-2,h-4,Color(24,24,24))
			surface.SetDrawColor(luxrainbow)
			surface.DrawLine(w-100,0,w-100,h)
			draw.SimpleText(pname, "lpp_big", 4, self:GetTall()/2, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw.SimpleText(pstid, "lpp_smol", 10, self:GetTall()/2+16, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw.SimpleText(prank, "lpp_smol", 17, self:GetTall()/2+28, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			if lwepjobs == false then
				draw.SimpleText(string.upper("Job spawns with  |  "..str), "lpp_smol", 20, self:GetTall()/2-27, Color(255,255,255),TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				if #str2 > 0 then
					draw.SimpleText(string.upper(str2), "lpp_smol", 15, self:GetTall()/2-15, Color(255,255,255),TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				end
			elseif lwepjobs == true then
				draw.SimpleText(string.upper("Player spawns with  |  "..str3), "lpp_smol", 20, self:GetTall()/2-27, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				if #str4 > 0 then
					draw.SimpleText(string.upper(str4), "lpp_smol", 15, self:GetTall()/2-15, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				end
			end
		end
		local lwepbutton1 = vgui.Create("DButton", lwepplayer)
		lwepbutton1:SetText("")
		lwepbutton1:SetSize(185,25)
		lwepbutton1:SetPos(lwepplayer:GetWide()/2.5, 75)
		lwepbutton1.Paint = function(self,w,h)
			draw.RoundedBox(10,0,0,w,h,luxrainbow)
			draw.RoundedBox(10,1,2,w-2,h-4,Color(24,24,24))
			draw.SimpleText("Toggle job/player weapon list", "lpp_smol", self:GetWide()/2, self:GetTall()/2, luxrainbow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			if self:IsHovered() then
				draw.RoundedBox(10,0,0,w,h,Color(luxrainbow.r,luxrainbow.g,luxrainbow.b,15))
			end
		end
		lwepbutton1.DoClick = function()
			if lwepjobs == true then
				lwepjobs = false
			else
				lwepjobs = true
			end
			surface.PlaySound( "UI/buttonclick.wav" )
		end
		local lweplabel = vgui.Create("DTextEntry", lwepplayer)
		lweplabel:SetPos(lwepplayer:GetWide()-205,5)
		lweplabel:SetText("")
		lweplabel:SetSize(160,20)
		lweplabel.Paint = function(self,w,h)
			draw.RoundedBox(10,0,0,w,h,luxrainbow)
			draw.RoundedBox(10,1,2,w-2,h-4,Color(24,24,24))
			if self:IsHovered() then
				draw.RoundedBox(10,0,0,w,h,Color(luxrainbow.r,luxrainbow.g,luxrainbow.b,15))
			end
			if string.len(tostring(self:GetText())) < 1 then
				draw.SimpleText("type weapon class here", "lpp_smol", self:GetWide()/2, self:GetTall()/2, luxrainbow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
			draw.SimpleText(self:GetText(), "lpp_smol", self:GetWide()/2, self:GetTall()/2, luxrainbow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		local lwepbutton2 = vgui.Create("DButton", lwepplayer)
		lwepbutton2:SetText("")
		lwepbutton2:SetPos(lwepplayer:GetWide()-176,35)
		lwepbutton2:SetSize(110,22)
		lwepbutton2.Paint = function(self,w,h)
			draw.RoundedBox(10,0,0,w,h,luxrainbow)
			draw.RoundedBox(10,1,2,w-2,h-4,Color(24,24,24))
			draw.SimpleText("Add perma wep", "lpp_smol", self:GetWide()/2, self:GetTall()/2, luxrainbow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			if self:IsHovered() then
				draw.RoundedBox(10,0,0,w,h,Color(luxrainbow.r,luxrainbow.g,luxrainbow.b,15))
			end
		end
		// This button adds a permanent weapon to the player
		lwepbutton2.DoClick = function()
			if string.len(lweplabel:GetText()) < 1 then --If the player specifies an argument less than 1 character, it will return a failure message because that means it is blank.
				surface.PlaySound("common/wpn_denyselect.wav")
				chat.AddText(Color(255,0,0), "Failed.")
				return
			else
				net.Start("lweprequest") --Sends a net message to the server requesting that weapon of id lweplabel:GetText() is added to v:SteamID()'s permanent weapon arsenal.
					net.WriteString(v:SteamID())
					net.WriteString("add")
					net.WriteString(lweplabel:GetText())
				net.SendToServer()
				chat.AddText(Color(255,255,255), v:Name().." will now spawn with "..lweplabel:GetText())
				surface.PlaySound("UI/buttonclickrelease.wav")
			end
		end
		local lwepbutton3 = vgui.Create("DButton", lwepplayer)
		lwepbutton3:SetText("")
		lwepbutton3:SetSize(125,22)
		lwepbutton3:SetPos(lwepplayer:GetWide()-185,65)
		lwepbutton3.Paint = function(self,w,h)
			draw.RoundedBox(10,0,0,w,h,luxrainbow)
			draw.RoundedBox(10,1,2,w-2,h-4,Color(24,24,24))
			draw.SimpleText("Delete perma wep", "lpp_smol", self:GetWide()/2, self:GetTall()/2, luxrainbow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			if self:IsHovered() then
				draw.RoundedBox(10,0,0,w,h,Color(luxrainbow.r,luxrainbow.g,luxrainbow.b,15))
			end
		end
		lwepbutton3.DoClick = function() -- This is almost identical to the button that adds a weapon, with the exception of the middle argument of the net message being "del" for delete instead of "add"
			if string.len(lweplabel:GetText()) < 1 then
				surface.PlaySound("common/wpn_denyselect.wav")
				chat.AddText(Color(255,0,0), "Failed.")
				return
			else
				net.Start("lweprequest")
					net.WriteString(v:SteamID())
					net.WriteString("del")
					net.WriteString(lweplabel:GetText())
				net.SendToServer()
				chat.AddText(Color(255,255,255), v:Name().." will no longer spawn with "..lweplabel:GetText())
				surface.PlaySound("common/wpn_select.wav")
			end
		end
	end
end
net.Receive("lwepmenu", openlwepmenu)