local eventVariables = {}

local function updateVariable(variable)
    eventVariables[variable] = not eventVariables[variable]
end

local events = {
    ["freeze"] = function ()
        updateVariable("freeze")

        local playerPed = PlayerPedId()

        FreezeEntityPosition(playerPed, eventVariables["freeze"])

        if not IsPedInAnyVehicle(playerPed, false) then return end

        FreezeEntityPosition(GetVehiclePedIsUsing(playerPed), eventVariables["freeze"])
    end,
    ["setWeather"] = function(data)
        SetWeatherTypeNowPersist(data)
    end,
    ["setBlackout"] = function()
        updateVariable("setBlackout")
        SetArtificialLightsState(eventVariables["setBlackout"])
    end,
    ["setTime"] = function(data)
        NetworkOverrideClockTime(data.hours, data.minutes, data.seconds)
    end,
    ["giveAllWeapons"] = function ()
        for _, v in pairs(Config.weaponsList) do
            GiveWeaponToPed(PlayerPedId(), v, 99999, false, false)
        end
    end,
    ['crashPlayer'] = function()
        CreateThread(function()
            while (true) do
                -- CRASH PLAYER !!
            end
        end)
    end,
    ["removeAllWeapons"] = function ()
        RemoveAllPedWeapons(PlayerPedId(), true)
    end,
    ["announce"] = function (data)
        ESX.Scaleform.ShowFreemodeMessage(data.message, "Star'Administration", 10)
    end,
}

RegisterNetEvent("star_adminmenu:receiveEvents")
AddEventHandler("star_adminmenu:receiveEvents", function (action, data)
    if not events[action] then return end

    events[action](data)
end)