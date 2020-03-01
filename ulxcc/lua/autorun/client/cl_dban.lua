local SetClipboardText = SetClipboardText // #420LocalizeIt
local disconnectTable = disconnectTable || {};

local function OpenPanel(ply, cmd, args, str)
	local ply = LocalPlayer();
	if (!ULib.ucl.query(ply, "ulx dban")) then
		ULib.tsayError(ply, "You don't have access to this command, " .. ply:Nick() .. "!");
		return;
	end
	net.Start("DisconnectsRequestTable");
	net.SendToServer();

	local main = vgui.Create( "DFrame" )
	main:SetPos( 50,50 )
	main:SetSize( 500, 400 )
	main:SetTitle( "Recently Disconnected Players" )
	main:SetVisible( true )
	main:SetDraggable( true )
	main:ShowCloseButton( false )
	main:MakePopup()
	main:Center()

	local list = vgui.Create( "DListView" )
	list:SetParent( main )
	list:SetPos( 4, 27 )
	list:SetSize( 492, 369 )
	list:SetMultiSelect( false )
	list:AddColumn( "Name" )
	list:AddColumn( "SteamID" )
	list:AddColumn( "IP Address" )
	list:AddColumn( "Time" )
	list.OnRowRightClick = function( Main, line )
		local menu = DermaMenu()
		menu:AddOption( "Ban by SteamID", function()
				local Frame = vgui.Create( "DFrame" )
				Frame:SetSize( 250, 98 )
				Frame:Center()
				Frame:MakePopup()
				Frame:SetTitle( "Ban by SteamID..." )
				local TimeLabel = vgui.Create( "DLabel", Frame )
				TimeLabel:SetPos( 5,27 )
				TimeLabel:SetColor( Color( 0,0,0,255 ) )
				TimeLabel:SetFont( "DermaDefault" )
				TimeLabel:SetText( "Time:" )
				local Time = vgui.Create( "DTextEntry", Frame )
				Time:SetPos( 47, 27 )
				Time:SetSize( 198, 20 )
				Time:SetText( "" )
				local ReasonLabel = vgui.Create( "DLabel", Frame )
				ReasonLabel:SetPos( 5,50 )
				ReasonLabel:SetColor( Color( 0,0,0,255 ) )
				ReasonLabel:SetFont( "DermaDefault" )
				ReasonLabel:SetText( "Reason:" )
				local Reason = vgui.Create( "DTextEntry", Frame )
				Reason:SetPos( 47, 50 )
				Reason:SetSize( 198, 20 )
				Reason:SetText("")
				local execbutton = vgui.Create( "DButton", Frame )
				execbutton:SetSize( 75, 20 )
				execbutton:SetPos( 47, 73 )
				execbutton:SetText( "Ban!" )
				execbutton.DoClick = function()
					RunConsoleCommand( "ulx", "banid", tostring( list:GetLine( line ):GetValue( 2 ) ), Time:GetText(), Reason:GetText() )
					Frame:Close()
				end
				local cancelbutton = vgui.Create( "DButton", Frame )
				cancelbutton:SetSize( 75, 20 )
				cancelbutton:SetPos( 127, 73 )
				cancelbutton:SetText( "Cancel" )
				cancelbutton.DoClick = function( CButton )
					Frame:Close()
				end
			end ):SetIcon("icon16/tag_blue_delete.png")
		menu:AddOption( "Ban by IP Address", function()
				local Frame = vgui.Create( "DFrame" )
				Frame:SetSize( 250, 98 )
				Frame:Center()
				Frame:MakePopup()
				Frame:SetTitle( "Ban by IP Address..." )
				local TimeLabel = vgui.Create( "DLabel", Frame )
				TimeLabel:SetPos( 5,27 )
				TimeLabel:SetColor( Color( 0,0,0,255 ) )
				TimeLabel:SetFont( "DermaDefault" )
				TimeLabel:SetText( "Time:" )
				local Time = vgui.Create( "DTextEntry", Frame )
				Time:SetPos( 47, 27 )
				Time:SetSize( 198, 20 )
				Time:SetText( "" )
				local ReasonLabel = vgui.Create( "DLabel", Frame )
				ReasonLabel:SetPos( 5,50 )
				ReasonLabel:SetColor( Color( 0,0,0,255 ) )
				ReasonLabel:SetFont( "DermaDefault" )
				ReasonLabel:SetText( "Reason:" )
				local Reason = vgui.Create( "DTextEntry", Frame )
				Reason:SetPos( 47, 50 )
				Reason:SetSize( 198, 20 )
				Reason:SetText( "No reason required" )
				Reason:SetDisabled( true )
				local execbutton = vgui.Create( "DButton", Frame )
				execbutton:SetSize( 75, 20 )
				execbutton:SetPos( 47, 73 )
				execbutton:SetText( "Ban!" )
				execbutton.DoClick = function()
					RunConsoleCommand( "ulx", "banip", Time:GetText(),  list:GetLine( line ):GetValue( 3 ) )
					Frame:Close()
				end
				local cancelbutton = vgui.Create( "DButton", Frame )
				cancelbutton:SetSize( 75, 20 )
				cancelbutton:SetPos( 127, 73 )
				cancelbutton:SetText( "Cancel" )
				cancelbutton.DoClick = function( CButton )
					Frame:Close()
				end
			end ):SetIcon("icon16/vcard_delete.png")
		menu:AddOption( "Copy Name", function()
			SetClipboardText( tostring( list:GetLine( line ):GetValue( 1 ) ) )
		end ):SetIcon("icon16/user_edit.png")
		menu:AddOption( "Copy SteamID", function()
			SetClipboardText( tostring( list:GetLine( line ):GetValue( 2 ) ) )
		end ):SetIcon("icon16/tag_blue_edit.png")
		if ply:IsAdmin() then
			menu:AddOption( "Copy IP Address", function()
				SetClipboardText( tostring( list:GetLine( line ):GetValue( 3 ) ) )
			end ):SetIcon("icon16/vcard_edit.png")
		end
		menu:AddOption( "Copy Time", function()
			SetClipboardText( tostring( list:GetLine( line ):GetValue( 4 ) ) )
		end ):SetIcon("icon16/time.png")
		menu:AddOption( "View Profile", function()
			gui.OpenURL("http://steamcommunity.com/profiles/" .. util.SteamIDTo64( tostring( list:GetLine( line ):GetValue( 2 ) ) ) )
		end ):SetIcon("icon16/world.png")
		if ply:IsAdmin() then
			menu:AddOption( "Whois", function()
				gui.OpenURL("http://whois.net/ip-address-lookup/" .. tostring( list:GetLine( line ):GetValue( 3 ) ) )
			end ):SetIcon("icon16/zoom.png")
		end
		menu:Open()
	end
	main:ShowCloseButton(true);
	net.Receive("DisconnectsTransferTable", function ()
		disconnectTable = net.ReadTable();
		if (IsValid(main)) then
			for i = 1, #disconnectTable do
				list:AddLine(disconnectTable[i][2], disconnectTable[i][1], disconnectTable[i][3], disconnectTable[i][4]);
			end
		end
	end);
end

concommand.Add("menu_disconnects", OpenPanel);
