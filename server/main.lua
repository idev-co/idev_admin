ESX = nil

local type = type

TriggerEvent(Config.triggers.esxLoading, function(object) ESX = object end)

local function hasMenuAccess(group)
    return Config.groupAccessMenu[group]
end

ESX.RegisterServerCallback("star_adminmenu:hasMenuAccess", function(source, callback)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    callback({ hasAccess = hasMenuAccess(xPlayer.getGroup()), group = xPlayer.getGroup()})
end)

ESX.RegisterServerCallback('star_adminmenu:triggerAction', function(source, callback, action, target, data)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

	if not hasMenuAccess(xPlayer.getGroup()) then return end
	if not Functions[action] then return end

    local blacklist = Config.functionsBlacklist[action]
    if blacklist and blacklist[xPlayer.getGroup()] then return end

    if data and type(data) ~= "table" then return end

	callback(Functions[action](source, target, data))
end)

ESX.RegisterServerCallback("star_adminmenu:getAllPlayers", function(source, callback)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    if not hasMenuAccess(xPlayer.getGroup()) then return end

	local players = {}

    -- TODO: sort by key string / id du player


	for _, player in pairs(GetPlayers()) do
		local ped = GetPlayerPed(player)
        local PLAYER = ESX.GetPlayerFromId(player)
		if Config.esxLegacy then
            players[tonumber(player)] = { name = GetPlayerName(player), ped = ped, coords = GetEntityCoords(ped), source = player}
        else
            players[tonumber(player)] = { name = GetPlayerName(player), ped = ped, coords = GetEntityCoords(ped), source = player}
        end
	end

	callback(players)
end)

ESX.RegisterServerCallback("star_adminmenu:logDiscord", function(source, callback, action, target, itemValue)
    if not Config.discord["enable"] then callback() end

    if itemValue ~= false and itemValue ~= true then
        itemValue = Translations["discordNotificationUsed"]
    elseif itemValue then
        itemValue = Translations["discordNotificationOn"]
    else
        itemValue = Translations["discordNotificationOff"]
    end

    if not target then
        target = Translations["extraActionTriggeredToServer"]
    else
        target = target.name
    end

    PerformHttpRequest(
        Config.discord["webhookURL"],
        function()
            callback()
        end,
        "POST",
        json.encode({ username = Config.discord["username"], embeds = {
            {
                ["color"] = Config.discord["color"],
                ["title"] = Config.discord["title"],
                ["description"] = (Config.discord["description"]):format(action, itemValue, target, GetPlayerName(source))
            }
        } }), { ["Content-Type"] = "application/json" }
    )
end)

AddEventHandler("playerConnecting", function(_, _, connection)
    local toFind

    if Config.useSteamIdentifier then
        toFind = "steam:"
    else
        toFind = "license:"
    end

	for _, identifier in pairs(GetPlayerIdentifiers(source) or {}) do

		if string.find(identifier, toFind) then
            identifier = identifier:gsub("%" .. toFind, "")

            -- TODO: voir pour vérifier la date si elle est passé ou non dans la query
			local record = MySQL.query.await("SELECT `reason`, `ended_at` FROM `adminmenu_records` WHERE `type` = 2 AND `user` = ?", {
                identifier
            })[1]

			if not record then return end

            record.ended_at = record.ended_at / 1000

            if os.time() <= record.ended_at or record.ended_at == 0 then
                local endedAt

                if record.ended_at == 0 then
                    endedAt = Translations["extraRecordPermanent"]
                else
                    endedAt = os.date("%Y-%m-%d %H:%M:%S", record.ended_at)
                end

                connection.done((Translations["extraBanReason"]):format(record.reason, endedAt))
            end

			break
		end
	end
end)