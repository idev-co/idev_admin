--[[

    Able the code to be more efficient (~10% faster than the usual, depends on the iteration and other metrics)
    I won't do it for all in order to avoid too much memory used on client's side

]]
local NotifyAction = NotifyAction
local translate = Translations

local customMenu = RageUI.CreateMenu(Translations["menuTitle"], Translations["menuSubtitle"])
local customData = {}
local recordTypes = {
    [0] = "Warn",
    [1] = "Kick",
    [2] = "Ban"
}

function RageUI.PoolMenus:AdminMenu()
    customMenu:IsVisible(function(items)
        for _, data in pairs(customData) do
            items:AddButton(data.name, data.description, { IsDisabled = false }, function(onSelected)
            end)
        end
    end, function() end)
end

CreateThread(function ()
    -- TODO: clenup tempory variable to table like events file
    local isUsingSuperJump, isShowingCoords, isShowingTargetCoords, isShowingBlips, isShowingNames, isAutoRepairing, isUsingNoclip, isSpectating
    local playersBlips, playersNames = {}, {}
    local noclipButtons = SetupScaleform("instructional_buttons", 1)
    local currentSpeed = Config.actions["noclip"].speed[1].speed
    local speedIndex = 1
    local lastCoords

    Sections = {
        [1] = {
            disable = false,
            name = translate["sectionPlayer"],
            functions = {
                [1] = {
                    disable = false,
                    blacklistID = "godmod",
                    name = translate["actionGodmode"],
                    type = "checkbox",
                    trigger = function (player, checked)
                        SetEntityInvincible(player, checked)
                        SetPedCanRagdoll(player, not checked)
                        SetEntityCanBeDamaged(player, not checked)

                        NotifyAction(translate["actionGodmode"], checked)
                    end
                },
                [2] = {
                    disable = false,
                    blacklistID = "invisible",
                    name = translate["actionInvisible"],
                    type = "checkbox",
                    trigger = function (player, checked)
                        SetEntityVisible(player, not checked, false)

                        NotifyAction(translate["actionInvisible"], checked)
                    end
                },
                [3] = {
                    disable = false,
                    blacklistID = "freeze",
                    name = translate["actionFreezePlayer"],
                    type = "checkbox",
                    trigger = function (player, checked)
                        FreezeEntityPosition(player, checked)

                        NotifyAction(translate["actionFreezePlayer"], checked)
                    end
                },
                [4] = {
                    disable = false,
                    blacklistID = "heal",
                    name = translate["actionHealPlayer"],
                    trigger = function (player)
                        SetEntityHealth(player, GetPedMaxHealth(player))

                        for status, value in pairs(Config.actions["healPlayer"]) do
                            TriggerEvent(Config.triggers["esxStatusSet"], status, value)
                        end

                        NotifyAction(translate["actionHealPlayer"])
                    end
                },
                [5] = {
                    disable = false,
                    blacklistID = "sprint",
                    name = translate["actionFastSprint"],
                    type = "checkbox",
                    trigger = function (_, checked, playerID)
                        SetRunSprintMultiplierForPlayer(playerID, checked and 1.49 or 1.0)

                        NotifyAction(translate["actionFastSprint"], checked)
                    end
                },
                [6] = {
                    disable = false,
                    blacklistID = "jump",
                    name = translate["actionFastJump"],
                    type = "checkbox",
                    trigger = function (_, _, playerID)
                        isUsingSuperJump = not isUsingSuperJump
                        NotifyAction(translate["actionFastJump"], isUsingSuperJump)

                        if isUsingSuperJump then
                            while isUsingSuperJump do
                                SetSuperJumpThisFrame(playerID)

                                Wait(0)
                            end
                        end
                    end
                },
                [7] = {
                    disable = false,
                    blacklistID = "swim",
                    name = translate["actionFastSwim"],
                    type = "checkbox",
                    trigger = function (_, checked, playerID)
                        SetSwimMultiplierForPlayer(playerID, checked and 1.49 or 1.0)

                        NotifyAction(translate["actionFastSwim"], checked)
                    end
                },
                [8] = {
                    disable = false,
                    name = translate["actionShowCoords"],
                    type = "checkbox",
                    trigger = function (player, checked)
                        isShowingCoords = not isShowingCoords
                        NotifyAction(translate["actionShowCoords"], checked)

                        if isShowingCoords then
                            while isShowingCoords do
                                local coords = GetEntityCoords(player, false)
                                CreateText((translate["extraShowCoords"]):format(ESX.Math.Round(coords.x, 3), ESX.Math.Round(coords.y, 3), ESX.Math.Round(coords.z, 3), ESX.Math.Round(GetEntityPhysicsHeading(player), 3)))

                                Wait(1)
                            end
                        end
                    end
                },
                [9] = {
                    disable = false,
                    blacklistID = "giveall",
                    name = translate["actionGiveAllWeapons"],
                    trigger = function (player)
                        for _, v in pairs(Config.weaponsList) do
                            GiveWeaponToPed(player, v, 99999, false, false)
                        end

                        NotifyAction(translate["actionGiveAllWeapons"])
                    end
                },
                [10] = {
                    disable = false,
                    blacklistID = "removeall",
                    name = translate["actionRemoveAllWeapons"],
                    trigger = function (player)
                        RemoveAllPedWeapons(player, true)

                        NotifyAction(translate["actionRemoveAllWeapons"])
                    end
                },
                [11] = {
                    disable = false,
                    blacklistID = "teleportPoint",
                    name = translate["actionTeleportToWaypoint"],
                    trigger = function (player)
                        local waypoint = GetFirstBlipInfoId(8)

                        if not DoesBlipExist(waypoint) then
                            return NotifyAction(false, false, translate["errorNoMarkerOnMap"])
                        end

                        local waypointCoords = GetBlipInfoIdCoord(waypoint)
                        local foundGround, zCoord, zPos = false, -500.0, 0.0

                        while not foundGround do
                            zCoord = zCoord + 10.0

                            RequestCollisionAtCoord(waypointCoords.x, waypointCoords.y, zCoord)
                            Wait(0)

                            foundGround, zPos = GetGroundZFor_3dCoord(waypointCoords.x, waypointCoords.y, zCoord, false)

                            if not foundGround and zCoord >= 2000.0 then
                                foundGround = true
                            end

                        end

                        SetPedCoordsKeepVehicle(player, waypointCoords.x, waypointCoords.y, zPos)
                        NotifyAction(translate["actionTeleportToWaypoint"])
                    end
                },
                [12] = {
                    disable = false,
                    blacklistID = "armor",
                    name = translate["actionGiveArmor"],
                    trigger = function (player)
                        local amount = CreateKeyboardInput("star_adminmenu_givearmor", translate["extraGiveArmor"], "", 4)
                        if not amount then return end

                        amount = tonumber(amount)

                        if amount < 0 then
                            amount = 0
                        end

                        SetPedArmour(player, tonumber(amount))

                        NotifyAction(translate["actionGiveArmor"])
                    end
                },
                [13] = {
                    disable = false,
                    blacklistID = "revive",
                    name = translate["actionRevive"],
                    trigger = function ()
                        TriggerEvent(Config.triggers["esxRevivePlayer"])

                        NotifyAction(translate["actionRevive"])
                    end
                },
                [14] = {
                    disable = false,
                    blacklistID = "blips",
                    name = translate["actionShowBlips"],
                    type = "checkbox",
                    trigger = function ()
                        isShowingBlips = not isShowingBlips
                        NotifyAction(translate["actionShowBlips"], isShowingBlips)

                        if not isShowingBlips then
                            for _, blip in pairs(playersBlips) do
                                RemoveBlip(blip)
                            end

                            playersBlips = {}

                            return
                        end

                        -- Neeeded for Onesync in order to update the loaded players around the ped, yes it's ugly :/
                        while isShowingBlips do
                            for _, player in pairs(GetActivePlayers()) do
                                local playerPed = GetPlayerPed(player)
                                local blip = AddBlipForEntity(playerPed)

                                SetBlipSprite(blip, 1)
                                SetBlipScale(blip, 0.85)
                                SetBlipRotation(blip, math.ceil(GetEntityHeading(playerPed)))
                                SetBlipNameToPlayerName(blip, player)
                                ShowHeadingIndicatorOnBlip(blip, true)
                                SetBlipAsShortRange(blip, false)

                                playersBlips[player] = blip
                            end

                            Wait(10000)

                            for _, blip in pairs(playersBlips) do
                                RemoveBlip(blip)
                            end

                            playersBlips = {}
                        end
                    end
                },
                [15] = {
                    disable = false,
                    name = translate["actionShowNames"],
                    type = "checkbox",
                    trigger = function (player)
                        isShowingNames = not isShowingNames
                        NotifyAction(translate["actionShowNames"], isShowingNames)

                        if not isShowingNames then
                            for _, v in pairs(playersNames) do
                                RemoveMpGamerTag(v)
                            end

                            playersNames = {}
                            return
                        end

                        -- Neeeded for Onesync in order to update the loaded players around the ped, yes it's ugly :/
                        while isShowingNames do
                            for _, v in pairs(GetActivePlayers()) do
                                local playerPed = GetPlayerPed(v)
                                if playerPed == player then return end

                                playersNames[v] = CreateFakeMpGamerTag(playerPed, (translate["extraShowNames"]):format(GetPlayerServerId(v), GetPlayerName(v)), false, false, '', 0)
                            end

                            Wait(10000)
                        end
                    end
                },
                [16] = {
                    disable = false,
                    name = translate["actionNoclip"],
                    type = "checkbox",
                    trigger = function (player)
                        isUsingNoclip = not isUsingNoclip

                        ClearPedTasksImmediately(player)

                        SetEntityCollision(player, not isUsingNoclip, not isUsingNoclip)
                        FreezeEntityPosition(player, isUsingNoclip)
                        SetEntityInvincible(player, isUsingNoclip)
                        SetEntityVisible(player, not isUsingNoclip, false)
                        SetEntityAlpha(player, not isUsingNoclip and 255, false)

                        SetEveryoneIgnorePlayer(player, isUsingNoclip)
                        SetPoliceIgnorePlayer(player, isUsingNoclip)

                        NotifyAction(translate["actionNoclip"], isUsingNoclip)

                        if isUsingNoclip then
                            while isUsingNoclip do
                                SetEntityVisible(player, false, false)
                                SetLocalPlayerVisibleLocally(true)
                                SetEntityAlpha(player, isUsingNoclip and 50 or 255, false)

                                DrawScaleformMovieFullscreen(noclipButtons)
                                DisableActionControls()

                                local x, y, z = table.unpack(GetEntityCoords(player, true))
                                local xDirection, yDirection, zDirection = GetCameraDirection()

                                SetEntityVelocity(player, 0.0001, 0.0001, 0.0001)

                                if IsControlJustPressed(1, Config.actions["noclip"]["controls"].adjustSpeed) then
                                    speedIndex = speedIndex + 1

                                    if speedIndex > #Config.actions["noclip"].speed then
                                        speedIndex = 1
                                    end

                                    currentSpeed = Config.actions["noclip"].speed[speedIndex].speed

                                    SetupScaleform("instructional_buttons", speedIndex)
                                end

                                if IsDisabledControlPressed(0, Config.actions["noclip"]["controls"].forward) then
                                    x = x + currentSpeed * xDirection
                                    y = y + currentSpeed * yDirection
                                    z = z + currentSpeed * zDirection
                                end

                                if IsDisabledControlPressed(0, Config.actions["noclip"]["controls"].backward) then
                                    x = x - currentSpeed * xDirection
                                    y = y - currentSpeed * yDirection
                                    z = z - currentSpeed * zDirection
                                end

                                SetEntityCoordsNoOffset(player, x, y, z, true, true, true)
                                SetEntityRotation(player, 0.0, 0.0, GetGameplayCamRot(0).z)

                                Wait(1)
                            end
                        end
                    end
                },
                [17] = {
                    disable = false,
                    blacklistID = "givemoney",
                    name = translate["actionGiveMoney"],
                    type = "slider",
                    values = {
                        { label = translate["extraBankName"], value = "bank" },
                        { label = translate["extraMoneyName"], value = "money" },
                        { label = translate["extraDirtyMoneyName"], value = "black_money" },
                    },
                    trigger = function (_, value)
                        local amount = CreateKeyboardInput("star_adminmenu_givemoney", translate["extraGiveMoney"], "", 8)
                        if not amount then return end

                        ESX.TriggerServerCallback("star_adminmenu:triggerAction", function()
                            NotifyAction(translate["actionGiveMoney"])
                        end, "giveMoney", false, { type = value, amount = tonumber(amount) })
                    end
                },
            }
        },
        [2] = {
            disable = false,
            name = translate["sectionManagePlayers"],
            functions = {
                [1] = {
                    disable = false,
                    name = translate["actionTeleportToPlayer"],
                    trigger = function (player, target)
                        ESX.TriggerServerCallback("star_adminmenu:triggerAction", function(coords)
                            RequestCollisionAtCoord(coords.x, coords.y, coords.z)
                            SetPedCoordsKeepVehicle(player, coords.x, coords.y, coords.z)

                            NotifyAction(translate["actionTeleportToPlayer"])
                        end, "getCoords", target.source)
                    end
                },
                [2] = {
                    disable = false,
                    name = translate["actionTeleportToYou"],
                    trigger = function (_, target)
                        ESX.TriggerServerCallback("star_adminmenu:triggerAction", function()
                            NotifyAction(translate["actionTeleportToYou"])
                        end, "bring", target.source)
                    end
                },
                [3] = {
                    disable = false,
                    blacklistID = "freezeplay",
                    name = translate["actionFreezeTarget"],
                    type = "checkbox",
                    trigger = function (_, target, checked)
                        ESX.TriggerServerCallback("star_adminmenu:triggerAction", function()
                            NotifyAction(translate["actionFreezeTarget"], checked)
                        end, "freeze", target.source)
                    end
                },
                [4] = {
                    disable = false,
                    name = translate["actionSpectateTarget"],
                    type = "checkbox",
                    trigger = function (player, target)
                        isSpectating = not isSpectating

                        -- avoid sync problems
                        Wait(50)

                        NotifyAction(translate["actionSpectateTarget"], isSpectating)

                        FreezeEntityPosition(player, isSpectating)

                        if not isSpectating then
                            SetEntityCoords(player, lastCoords)

                            ClearPedBloodDamage(player)
                            ClearPedEnvDirt(player)
                            ResetPedVisibleDamage(player)
                        end

                        SetEntityVisible(player, not isSpectating, false)
                        SetEntityInvincible(player, isSpectating)
                        SetEntityCollision(player, not isSpectating, not isSpectating)
                        SetPedCanRagdoll(player, not isSpectating)
                        SetEntityCanBeDamaged(player, not isSpectating)

                        if not isSpectating then return end

                        lastCoords = GetEntityCoords(player)

                        ESX.TriggerServerCallback("star_adminmenu:triggerAction", function(coords)
                            while not HasCollisionLoadedAroundEntity(player) do
                                Wait(0)
                                RequestCollisionAtCoord(coords.x, coords.y, coords.z)
                            end

                            SetEntityCoords(player, coords.x, coords.y, coords.z)

                            local targetSpectate

                            -- Because network entity client and server doesn't share the same ID on OneSync Inifinity
                            while not targetSpectate do
                                Wait(1)

                                for _, v in pairs(GetActivePlayers()) do
                                    if NetworkIsPlayerActive(v) then
                                        if GetPlayerName(v) == target.name then
                                            targetSpectate = v
                                        end
                                    end
                                end
                            end

                            while isSpectating do
                                Wait(1)

                                if targetSpectate then
                                    local targetPed = GetPlayerPed(targetSpectate)
                                    local coords = GetEntityCoords(targetPed)

                                    if IsPedInAnyVehicle(targetPed) then
                                        SetEntityNoCollisionEntity(GetVehiclePedIsIn(targetPed, false), player, true)
                                    end

                                    SetEntityNoCollisionEntity(targetSpectate, player, true)
                                    RequestCollisionAtCoord(coords.x, coords.y, coords.z)
                                    SetEntityCoords(player, coords.x, coords.y, coords.z)
                                end
                            end
                        end, "getCoords", target.source)
                    end
                },
                [5] = {
                    disable = false,
                    name = translate["actionShowTargetCoords"],
                    type = "checkbox",
                    trigger = function (_, target)
                        isShowingTargetCoords = not isShowingTargetCoords

                        NotifyAction(translate["actionShowTargetCoords"], isShowingTargetCoords)

                        if isShowingTargetCoords then
                            ESX.TriggerServerCallback("star_adminmenu:triggerAction", function(coords, heading)
                                while isShowingTargetCoords do
                                    CreateText((translate["extraShowCoords"]):format(ESX.Math.Round(coords.x, 3), ESX.Math.Round(coords.y, 3), ESX.Math.Round(coords.z, 3), ESX.Math.Round(heading, 3)))

                                    Wait(1)
                                end
                            end, "getCoords", target.source)
                        end
                    end
                },
                [6] = {
                    disable = false,
                    blacklistID = "giveallplayer",
                    name = translate["actionTargetGiveAllWeapons"],
                    trigger = function (_, target)
                        ESX.TriggerServerCallback("star_adminmenu:triggerAction", function()
                            NotifyAction(translate["actionTargetGiveAllWeapons"])
                        end, "giveAllWeapons", target.source)
                    end
                },
                [7] = {
                    disable = false,
                    blacklistID = "removeallplayer",
                    name = translate["actionTargetRemoveAllWeapons"],
                    trigger = function (_, target)
                        ESX.TriggerServerCallback("star_adminmenu:triggerAction", function()
                            NotifyAction(translate["actionTargetRemoveAllWeapons"])
                        end, "removeAllWeapons", target.source)
                    end
                },
                [8] = {
                    disable = false,
                    name = translate["actionTargetRevive"],
                    blacklistID = "reviveplayer",
                    trigger = function (_, target)
                        ESX.TriggerServerCallback("star_adminmenu:triggerAction", function()
                            NotifyAction(translate["actionTargetRevive"])
                        end, "revive", target.source)
                    end
                },
                [9] = {
                    disable = false,
                    blacklistID = "setjob",
                    name = translate["actionSetTargetJob"],
                    trigger = function (_, target)
                        local job = CreateKeyboardInput("star_adminmenu_setjob", translate["extraSetJob"], "", 100)
                        if not job then return end

                        local grade = CreateKeyboardInput("star_adminmenu_setjobgrade", translate["extraSetJobGrade"], "", 100)
                        if not grade then return end

                        ESX.TriggerServerCallback("star_adminmenu:triggerAction", function(success)
                            if not success then
                                return NotifyAction(false, false, translate["errorJobNotFound"])
                            end

                            NotifyAction(translate["actionSetTargetJob"])
                        end, "setJob", target.source, { jobName = job, jobGrade = grade })
                    end
                },
                [10] = {
                    disable = false,
                    blacklistID = "givemoneyy",
                    name = translate["actionTargetGiveMoney"],
                    type = "slider",
                    values = {
                        { label = translate["extraBankName"], value = "bank" },
                        { label = translate["extraMoneyName"], value = "money" },
                        { label = translate["extraDirtyMoneyName"], value = "black_money" },
                    },
                    trigger = function (_, target, value)
                        local amount = CreateKeyboardInput("star_adminmenu_targetgivemoney", translate["extraGiveMoney"], "", 8)
                        if not amount then return end

                        -- TODO: shouldn't have just replaced the false by the target source ?!
                        ESX.TriggerServerCallback("star_adminmenu:triggerAction", function(success)
                            if not success then
                                return NotifyAction(false, false, translate["errorSomethingWentWrong"])
                            end

                            NotifyAction(translate["actionTargetGiveMoney"])
                        end, "giveMoney", target.source, { type = value, amount = tonumber(amount) })
                    end
                },
                [11] = {
                    disable = false,
                    blacklistID = "rankk",
                    name = translate["actionTargetSetRank"],
                    trigger = function (_, target)
                        local rank = CreateKeyboardInput("star_adminmenu_targetsetrank", translate["extraSetRank"], "", 20)
                        if not rank then return end

                        ESX.TriggerServerCallback("star_adminmenu:triggerAction", function(success)
                            if not success then
                                return NotifyAction(false, false, translate["errorSomethingWentWrong"])
                            end

                            NotifyAction(translate["actionTargetSetRank"])
                        end, "setRank", target.source, { rank = rank })
                    end
                },
                [12] = {
                    disable = false,
                    blacklistID = "gwarn",
                    name = translate["actionTargetAddWarn"],
                    trigger = function (_, target)
                        local reason = CreateKeyboardInput("star_adminmenu_setrecord", translate["extraAddReason"], "", 200)
                        if not reason then return end

                        ESX.TriggerServerCallback("star_adminmenu:triggerAction", function(success)
                            if not success then
                                return NotifyAction(false, false, translate["errorSomethingWentWrong"])
                            end

                            NotifyAction(translate["actionTargetAddWarn"])
                        end, "addRecord", target.source, { reason = reason, type = 0 })
                    end
                },
                [13] = {
                    disable = false,
                    blacklistID = "kickplay",
                    name = translate["actionTargetKick"],
                    trigger = function (_, target)
                        local reason = CreateKeyboardInput("star_adminmenu_setrecord", translate["extraAddReason"], "", 200)
                        if not reason then return end

                        ESX.TriggerServerCallback("star_adminmenu:triggerAction", function(success)
                            if not success then
                                return NotifyAction(false, false, translate["errorSomethingWentWrong"])
                            end

                            NotifyAction(translate["actionTargetKick"])
                        end, "addRecord", target.source, { reason = reason, type = 1 })
                    end
                },
                [14] = {
                    disable = false,
                    blacklistID = "ban",
                    name = translate["actionTargetBan"],
                    trigger = function (_, target)
                        local duration = CreateKeyboardInput("star_adminmenu_setrecord", translate["extraSetDuration"], "", 200)
                        if not duration then return end

                        local reason = CreateKeyboardInput("star_adminmenu_setrecord", translate["extraAddReason"], "", 200)
                        if not reason then return end

                        ESX.TriggerServerCallback("star_adminmenu:triggerAction", function(success)
                            if not success then
                                return NotifyAction(false, false, translate["errorSomethingWentWrong"])
                            end

                            NotifyAction(translate["actionTargetBan"])
                        end, "addRecord", target.source, { reason = reason, type = 2, duration = tonumber(duration) })
                    end
                },
                [15] = {
                    disable = false,
                    blacklistID = "listrecord",
                    name = translate["actionOpenTargetRecords"],
                    trigger = function (_, target)
                        ESX.TriggerServerCallback("star_adminmenu:triggerAction", function(data)
                            if not data then
                                return NotifyAction(false, false, translate["errorSomethingWentWrong"])
                            end

                            customData = {}

                            for _, record in pairs(data) do
                                customData[#customData + 1] = {
                                    name = ("[#%s] %s"):format(record.idban, recordTypes[record.type]),
                                    description = (translate["extraRecordDescription"] .. ((record.type == 2 and record.ended_at) and translate["extraRecordDescriptionEnded"] or "")):format(
                                        record.reason,
                                        (record.firstname .. " " .. record.lastname),
                                        record.created_at,
                                        record.ended_at
                                    )
                                }
                            end

                            RageUI.Visible(customMenu, true)
                            NotifyAction(translate["actionOpenTargetRecords"])
                        end, "getTargetRecords", target.source)
                    end
                },
                [16] = {
                    disable = false,
                    blacklistID = "inventory",
                    name = translate["actionOpenTargetInventory"],
                    trigger = function (_, target)
                        ESX.TriggerServerCallback("star_adminmenu:triggerAction", function(data)
                            if not data then
                                return NotifyAction(false, false, translate["errorSomethingWentWrong"])
                            end

                            customData = {}

                            for _, item in pairs(data) do
                                customData[#customData + 1] = {
                                    name = ("[x%s] %s"):format(item.count, item.label),
                                    description = false
                                }
                            end

                            RageUI.Visible(customMenu, true)
                            NotifyAction(translate["actionOpenTargetInventory"])
                        end, "getTargetInventory", target.source)
                    end
                },
                [17] = {
                    disable = false,
                    blacklistID = "wipe",
                    name = Translations["actionWipePlayer"],
                    trigger = function (_, target)
                        ESX.TriggerServerCallback("star_adminmenu:triggerAction", function(data)
                            ESX.ShowNotification((Translations["youWipedPlayer"]):format(target.name), false, false, 140)

                            NotifyAction(Translations["youWipedPlayer"])
                        end, "wipe", target.source)
                    end
                },
                [18] = {
                    disable = false,
                    blacklistID = "setjob2",
                    name = translate["actionSetTargetJob2"],
                    trigger = function (_, target)
                        local job = CreateKeyboardInput("star_adminmenu_setjob", translate["extraSetJob2"], "", 100)
                        if not job then return end

                        local grade = CreateKeyboardInput("star_adminmenu_setjobgrade", translate["extraSetJobGrade2"], "", 100)
                        if not grade then return end

                        ESX.TriggerServerCallback("star_adminmenu:triggerAction", function(success)
                            if not success then
                                return NotifyAction(false, false, translate["errorJobNotFound"])
                            end

                            NotifyAction(translate["actionSetTargetJob2"])
                        end, "setJob2", target.source, { jobName = job, jobGrade = grade })
                    end
                },
                [19] = {
                    disable = false,
                    blacklistID = "crashPlayer",
                    name = translate["actionCrashPlayer"],
                    trigger = function(_, target)
                        ESX.TriggerServerCallback("star_adminmenu:triggerAction", function()
                            NotifyAction(translate["actionCrashPlayer"])
                        end, "crash", target.source)
                    end
                },
                [20] = {
                    disable = false,
                    blacklistID = "sendMsgToPlayer",
                    name = translate["sendMsgToPlayer"],
                    trigger = function(_, target)
                        local message = CreateKeyboardInput("star_adminmenu_sendprivatemsgtoplayer", translate["sendMsgToPlayer"], "", 200)
                        if not message then return end
                        ESX.TriggerServerCallback("star_adminmenu:triggerAction", function()
                            NotifyAction(translate["sendMsgToPlayer"])
                        end, "sendPVToAPlayer", target.source, {message = message})
                    end
                },
                [21] = {
                    blacklistID = "kickPlayerFromAVehicle",
                    name = translate["kickPlayerFromAVehicle"],
                    trigger = function(player, target)
                        ESX.TriggerServerCallback("star_adminmenu:triggerAction", function()
                            NotifyAction(translate["kickPlayerFromAVehicle"])
                        end, "kickPlayerFromVeh", target.source)
                    end,
                },
            }
        },
        [3] = {
            disable = false,
            name = translate["sectionManageVehicle"],
            functions = {
                [1] = {
                    disable = false,
                    blacklistID = "fixcar",
                    name = translate["actionFixVehicle"],
                    trigger = function (player)
                        if not IsPedInAnyVehicle(player) then return NotifyAction(false, false, Translations["errorNoVehiclePedIn"]) end

                        local vehicle = GetVehiclePedIsUsing(player)
                        RepairVehicle(vehicle)

                        NotifyAction(translate["actionFixVehicle"])
                    end
                },
                [2] = {
                    disable = false,
                    blacklistID = "godcar",
                    name = translate["actionGodModeVehicle"],
                    type = "checkbox",
                    trigger = function (player, checked)
                        if not IsPedInAnyVehicle(player) then return NotifyAction(false, false, translate["errorNoVehiclePedIn"]) end

                        local vehicle = GetVehiclePedIsUsing(player)
                        SetEntityInvincible(vehicle, checked)
                        SetVehicleStrong(vehicle, checked)

                        NotifyAction(translate["actionGodModeVehicle"])
                    end
                },
                [3] = {
                    disable = false,
                    blacklistID = "removecar",
                    name = translate["actionRemoveVehicle"],
                    trigger = function (player)
                        if not IsPedInAnyVehicle(player) then return NotifyAction(false, false, translate["errorNoVehiclePedIn"]) end

                        DeleteEntity(GetVehiclePedIsUsing(player))

                        NotifyAction(translate["actionRemoveVehicle"])
                    end
                },
                [4] = {
                    disable = false,
                    blacklistID = "modifplate",
                    name = translate["actionSetPlateVehicle"],
                    trigger = function (player)
                        if not IsPedInAnyVehicle(player) then return NotifyAction(false, false, translate["errorNoVehiclePedIn"]) end

                        local plate = CreateKeyboardInput("star_adminmenu_setplate", translate["extraSetPlate"], "", 8)
                        if not plate then return end

                        SetVehicleNumberPlateText(GetVehiclePedIsUsing(player), plate)

                        NotifyAction(translate["actionSetPlateVehicle"])
                    end
                },
                [5] = {
                    disable = false,
                    blacklistID = "perfs",
                    name = translate["actionSetPowerVehicle"],
                    type = "slider",
                    values = {
                        { label = "x1", value = 1.0 },
                        { label = "x2", value = 2.0 },
                        { label = "x4", value = 4.0 },
                        { label = "x8", value = 8.0 },
                        { label = "x16", value = 16.0 },
                        { label = "x32", value = 32.0 },
                        { label = "x64", value = 64.0 },
                        { label = "x128", value = 128.0 },
                        { label = "x256", value = 256.0 },
                        { label = "x512", value = 512.0 },
                    },
                    trigger = function (player, value)
                        if not IsPedInAnyVehicle(player) then return NotifyAction(false, false, translate["errorNoVehiclePedIn"]) end

                        ModifyVehicleTopSpeed(GetVehiclePedIsUsing(player), value)

                        NotifyAction(translate["actionSetPowerVehicle"])
                    end
                },
                [6] = {
                    disable = false,
                    blacklistID = "autorepair",
                    name = translate["actionSetAutoRepairVehicle"],
                    type = "checkbox",
                    trigger = function (player)
                        if not IsPedInAnyVehicle(player) then return NotifyAction(false, false, translate["errorNoVehiclePedIn"]) end

                        isAutoRepairing = not isAutoRepairing

                        NotifyAction(translate["actionSetAutoRepairVehicle"], isAutoRepairing)

                        if isAutoRepairing then
                            while isAutoRepairing do
                                if IsPedInAnyVehicle(player) then
                                    local vehicle = GetVehiclePedIsUsing(player)

                                    if IsVehicleDamaged(GetVehiclePedIsUsing(player)) then
                                        RepairVehicle(vehicle)
                                    end
                                end

                                Wait(1)
                            end
                        end
                    end
                },
                [7] = {
                    disable = false,
                    blacklistID = "maxUpgradesVeh",
                    name = translate["actionMaxUpgrades"],
                    trigger = function(player)
                        if not IsPedInAnyVehicle(player) then return NotifyAction(false, false, translate["errorNoVehiclePedIn"]) end
                        if IsPedInAnyVehicle(player) then
                            local vehicle = GetVehiclePedIsUsing(player)
                            if DoesEntityExist(vehicle) and IsEntityAVehicle(vehicle) then
                                ESX.Game.SetVehicleProperties(vehicle, Config.maxUpgradesVeh)
                            end
                        end
                    end
                },
                [8] = {
                    disable = false,
                    blacklistID = "setVehicleColor",
                    name = translate["actionsetVehicleColor"],
                    type = "slider",
                    values = Config.colorOptionsVeh,
                    trigger = function(player, value)
                        if not IsPedInAnyVehicle(player) then return NotifyAction(false, false, translate["errorNoVehiclePedIn"]) end
                        if IsPedInAnyVehicle(player) then
                            local vehicle = GetVehiclePedIsUsing(player)
                            if DoesEntityExist(vehicle) and IsEntityAVehicle(vehicle) then
                                SetVehicleColours(vehicle, value)
                            end
                        end
                    end
                }
            }
        },
        [4] = {
            disable = false,
            name = translate["sectionUtils"],
            functions = {
                [1] = {
                    disable = false,
                    blacklistID = "weather",
                    name = translate["actionSetWeather"],
                    type = "slider",
                    values = {
                        { label = translate["extraWeatherNames"]["clear"], value = "CLEAR" },
                        { label = translate["extraWeatherNames"]["extrasunny"], value = "EXTRASUNNY" },
                        { label = translate["extraWeatherNames"]["clouds"], value = "CLOUDS" },
                        { label = translate["extraWeatherNames"]["overcast"], value = "OVERCAST" },
                        { label = translate["extraWeatherNames"]["rain"], value = "RAIN" },
                        { label = translate["extraWeatherNames"]["clearing"], value = "CLEARING" },
                        { label = translate["extraWeatherNames"]["thunder"], value = "THUNDER" },
                        { label = translate["extraWeatherNames"]["smog"], value = "SMOG" },
                        { label = translate["extraWeatherNames"]["foggy"], value = "FOGGY" },
                        { label = translate["extraWeatherNames"]["xmas"], value = "XMAS" },
                        { label = translate["extraWeatherNames"]["snowlight"], value = "SNOWLIGHT" },
                        { label = translate["extraWeatherNames"]["blizzard"], value = "BLIZZARD" },
                    },
                    trigger = function (_, value)
                        if Config.ScriptsWithAdmin.vSync then
                            TriggerServerEvent('vSync:changeWeather', string.upper(value))
                        else
                            ESX.TriggerServerCallback("star_adminmenu:triggerAction", function()
                            end, "setWeather", value)
                        end
                        NotifyAction(translate["actionSetWeather"])
                    end
                },
                [2] = {
                    disable = false,
                    blacklistID = "blackout",
                    name = translate["actionManageBlackout"],
                    type = "checkbox",
                    trigger = function (_, checked)
                        if Config.ScriptsWithAdmin.vSync then
                            TriggerServerEvent('vSync:Blackout', checked)
                        else
                            ESX.TriggerServerCallback("star_adminmenu:triggerAction", function()
                            end, "setBlackout", nil, nil)
                        end

                        NotifyAction(translate["actionManageBlackout"], checked)
                    end
                },
                [3] = {
                    disable = false,
                    blacklistID = "cleararea",
                    name = translate["actionRemoveVehiclesInArea"],
                    trigger = function (player)
                        local radius = CreateKeyboardInput("star_adminmenu_removevehiclesarea", translate["extraRemoveVehiclesInArea"], "", 4)
                        if not radius then return end

                        for _, vehicle in pairs(ESX.Game.GetVehiclesInArea(GetEntityCoords(player), tonumber(radius) + 0.0)) do
                            ESX.Game.DeleteVehicle(vehicle)
                        end

                        NotifyAction(translate["actionRemoveVehiclesInArea"])
                    end
                },
                [4] = {
                    disable = false,
                    blacklistID = "settime",
                    name = translate["actionSetTime"],
                    type = "slider",
                    values = {
                        { label = translate["extraTimeNames"]["morning"], value = Config.timeOptions.morning},
                        { label = translate["extraTimeNames"]["afternoon"], value = Config.timeOptions.afternoon},
                        { label = translate["extraTimeNames"]["evening"], value = Config.timeOptions.evening},
                        { label = translate["extraTimeNames"]["night"], value = Config.timeOptions.night},
                    },
                    trigger = function (_, value)
                     --   NetworkOverrideClockTime(value.hours, value.minutes, value.seconds)
                        if Config.ScriptsWithAdmin.vSync then
                            TriggerServerEvent('vSync:changeTime', value)
                        else
                            ESX.TriggerServerCallback("star_adminmenu:triggerAction", function()
                                NotifyAction(translate["actionSetTime"])
                            end, "setTimeForPlayers", false, {data = value})
                        end
                    end
                },
                [5] = {
                    disable = false,
                    blacklistID = "kickall",
                    name = translate["actionKickAll"],
                    trigger = function (_, target)
                        local reason = CreateKeyboardInput("star_adminmenu_setrecord", translate["extraAddReason"], "", 200)
                        if not reason then return end

                        ESX.TriggerServerCallback("star_adminmenu:triggerAction", function(success)
                            if not success then
                                return NotifyAction(false, false, translate["errorSomethingWentWrong"])
                            end

                            NotifyAction(translate["actionKickAll"])
                        end, "kickAll", false, { reason = reason })
                    end
                },
                [6] = {
                    disable = false,
                    blacklistID = "announce",
                    name = translate["makeAnnounce"],
                    trigger = function(_, target)
                        local announce = CreateKeyboardInput(translate["makeAnnounce"], translate["yourAnnounce"], "", 200)
                        if not announce then return end

                        ESX.TriggerServerCallback("star_adminmenu:triggerAction", function()

                            NotifyAction(translate["makeAnnounce"])
                        end, "announce", false, { message = announce })
                    end
                },
            }
        }
    }
end)