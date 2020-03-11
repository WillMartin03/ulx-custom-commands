function injectModule()
	hook.Add("PlayerInitialSpawn", "ULXCC_VariableSet", function (ply)
		timer.Simple(10, function ()
			ply.canbrag = true;
		end);
	end);
	function starttimer(ply)
		timer.Simple(180, function ()
			ply.canbrag = true;
		end);
	end
	function ulx.brag(calling_ply)
		if (IsValid(calling_ply) && calling_ply.canbrag) then
			calling_ply.canbrag = false;
			starttimer(calling_ply);
			local pts = calling_ply:PS_GetPoints();
			if (isnumber(tonumber(pts)) && (tonumber(pts) != 0)) then
				for _, v in ipairs(player.GetHumans()) do
					if (IsValid(v)) then
						v:ChatPrint("[BRAG]: " .. ((calling_ply.Nick && calling_ply:Nick()) || "?") .. " has " .. tostring(pts) .. " points!");
					end
				end
			else
				ULib.tsayError(calling_ply, "[ERROR]: What are you gonna do, brag about being broke?");
			end
		elseif (IsValid(calling_ply) && !calling_ply.canbrag) then
			ULib.tsayError(calling_ply, "[ERROR]: You can't brag yet!");
		end
	end
	local brag = ulx.command("Custom", "ulx brag", ulx.brag, {"!brag", "!brags", "!points", "!mypoints", "!point"}, true);
	brag:defaultAccess(ULib.ACCESS_ALL);
	brag:help("Brag about your pointshop points!");
	function ulx.viewpoints(calling_ply, target_plys)
		for _, v in ipairs(target_plys) do
			if (IsValid(v)) then
				local pts = v:PS_GetPoints();
				calling_ply:ChatPrint("[POINTS]: " .. ((v.Nick && v:Nick()) || "?") .. " has " .. pts .. " points!");
			else
				ULib.tsayError(calling_ply, "[ERROR]: Not a valid player!");
			end
		end
	end
	local viewpoints = ulx.command("Custom", "ulx viewpoints", ulx.viewpoints, "!viewpoints", true);
	viewpoints:addParam({type = ULib.cmds.PlayersArg});
	viewpoints:defaultAccess(ULib.ACCESS_ALL);
	viewpoints:help("View a players points");
end

timer.Simple(3, function (MadeByZero)
	if (istable(PS)) then
		print("[ULXCC]: Pointshop is installed! Adding pointshop module!");
		injectModule();
	end
end);
