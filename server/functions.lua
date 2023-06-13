local TriggerClientEvent = TriggerClientEvent
local GetPlayerPed = GetPlayerPed
local GetEntityCoords = GetEntityCoords

CreateThread(function()
    Functions = {
        ["getCoords"] = function (_, target)
            local ped = GetPlayerPed(target)

            return GetEntityCoords(ped), GetEntityHeading(ped)
        end,
        ["setWeather"] = function(_, weather)
          TriggerClientEvent("star_adminmenu:receiveEvents", -1, "setWeather", weather)
        end,
        ["setBlackout"] = function()
          TriggerClientEvent('star_adminmenu:receiveEvents', -1, "setBlackout")
        end,
        ["bring"] = function(source, target)
            SetEntityCoords(GetPlayerPed(target), GetEntityCoords(GetPlayerPed(source)))
        end,
        ["freeze"] = function (_, target)
            TriggerClientEvent("star_adminmenu:receiveEvents", target, "freeze")
        end,
        ["giveMoney"] = function (source, target, data)
            if not data then return end

            local xTarget

            if not target then
                xTarget = ESX.GetPlayerFromId(source)
            else
                xTarget = ESX.GetPlayerFromId(target)
            end

            if not xTarget then return end


            if data.type == "money" then
                xTarget.addMoney(data.amount)
            else
              xTarget.addAccountMoney(data.type, data.amount)
            end

            return true
        end,
        ["giveAllWeapons"] = function (_, target)
            --TriggerClientEvent("star_adminmenu:receiveEvents", target, "giveAllWeapons")
            for _, weapons in pairs(Config.weaponsList) do
              GiveWeaponToPed(GetPlayerPed(target), weapons, 99999, false, false)
            end
        end,
        ["removeAllWeapons"] = function (_, target)
            --TriggerClientEvent("star_adminmenu:receiveEvents", target, "removeAllWeapons")
            RemoveAllPedWeapons(GetPlayerPed(target), true)
        end,
        ["revive"] = function (_, target)
            TriggerClientEvent(Config.triggers["esxRevivePlayer"], target)
        end,
        ["setJob"] = function (_, target, data)
            local xTarget = ESX.GetPlayerFromId(target)
            if not xTarget then return end

            if not data then return end

            if not ESX.DoesJobExist(data.jobName, data.jobGrade) then return end
            xTarget.setJob(data.jobName, data.jobGrade)

            return true
        end,
        ["setJob2"] = function (_, target, data)
            local xTarget = ESX.GetPlayerFromId(target)
            if not xTarget then return end

            if not data then return end

            if not ESX.DoesJob2Exist(data.jobName, data.jobGrade) then return end

            xTarget.setJob2(data.jobName, data.jobGrade)

            return true
        end,
        ["setRank"] = function (_, target, data)
            local xTarget = ESX.GetPlayerFromId(target)
            if not xTarget then return end

            if not data then return end

            xTarget.setGroup(data.rank)

            return true
        end,
        ["addRecord"] = function (player, target, data)
            local xPlayer = ESX.GetPlayerFromId(player)
            if not xPlayer then return end

            local xTarget = ESX.GetPlayerFromId(target)
            if not xTarget then return end

            if not data then return end

            local endedAt

            if data.type == 1 or data.type == 2 then
                DropPlayer(target, Translations["extraDropPlayerPrefix"] .. data.reason)

                if data.type == 2 and data.duration > 0 then
                    endedAt = os.date("%Y-%m-%d %H:%M:%S", os.time() + data.duration)
                end
            end

            MySQL.insert.await("INSERT INTO `adminmenu_records` (`user`, `staff`, `reason`, `created_at`, `type`, `ended_at`) VALUES (?, ?, ?, ?, ?, ?)", {
                xTarget.getIdentifier(),
                xPlayer.getIdentifier(),
                data.reason,
                os.date("%Y-%m-%d %H:%M:%S"),
                data.type,
                endedAt
            })

            return true
        end,
        ["kickAll"] = function (_, _, data)
            if not data then return end

            for _, player in pairs(GetPlayers()) do
                DropPlayer(player, data.reason)
            end

            return true
        end,
        ["reviveAll"] = function (source, target)
            for _, player in pairs(GetPlayers()) do
                if IsEntityDead(GetPlayerPed(player)) then
                  print(player)
                  TriggerClientEvent('esx_ambulancejob:revive', player)
                end
            end
        end,
        ["getTargetRecords"] = function (_, target)
            local xTarget = ESX.GetPlayerFromId(target)
            if not xTarget then return end

            local result = MySQL.query.await("SELECT `idban`, `reason`, `created_at`, `type`, `ended_at`, `firstname`, `lastname` FROM `adminmenu_records` a INNER JOIN `users` b ON a.staff = b.identifier WHERE `user` = ? ORDER BY `created_at` DESC", {
              xTarget.getIdentifier()
            })

            for k, v in pairs(result) do
                result[k].created_at = os.date("%Y-%m-%d %H:%M:%S", v.created_at / 1000)

                if v.ended_at > 0 then
                    result[k].ended_at = os.date("%Y-%m-%d %H:%M:%S", v.ended_at / 1000)
                elseif v.ended_at == 0 then
                    result[k].ended_at = Translations["extraRecordPermanent"]
                end
            end

            return result
        end,
        ["getTargetInventory"] = function (_, target)
            local xTarget = ESX.GetPlayerFromId(target)
            if not xTarget then return end

            local inventory = {}
            local itemInventory = xTarget.getInventory()

            for _, item in pairs(itemInventory) do
                if item.count > 0 then
                    inventory[#inventory + 1] = { label = item.label, count = item.count }
                end
            end

            return inventory
        end,
        ["sendPVToAPlayer"] = function(source, target, data)
          if not source then return end
          local xTarget = ESX.GetPlayerFromId(target)
          xTarget.showNotification(Translations["staffMsgSendToPlayer"] .. data.message, false, true, 140)
        end,
        ["kickPlayerFromVeh"] = function(source, target)
          local Target = GetPlayerPed(target)
          local vehTarget = GetVehiclePedIsIn(Target, false)
          if (vehTarget == 0 or vehTarget == nil) then
            TriggerClientEvent('esx:showNotification', source, Translations["playerIsNotInAVeh"])
          end
          TaskLeaveVehicle(Target, vehTarget, 0)
        end,
        ["wipe"] = function (source, target)
          local xTarget = ESX.GetPlayerFromId(target)
          if not xTarget then return end

          Functions["addRecord"](source, target, { type = 1, reason = Translations["wipeReason"] })

          local tablesToWipe = {
              {name = "billing", column = "`identifier` = ? OR `sender` = ?"},
              {name = "characters", column = "`identifier` = ?"},
              {name = "datastore_data", column = "`owner` = ?"},
              {name = "bit_driverschool", column = "`userIdentifier` = ?"},
              {name = "okokbanking_transactions", column = "`sender_identifier` = ?"},
              {name = "casino_players", column = "`identifier` = ?"},
              {name = "boombox_songs", column = "`identifier` = ?"},
              {name = "saved_documents", column = "`identifier` = ?"},
              {name = "wasabi_multijob", column = "`identifier` = ?"},
              {name = "jsfour_criminalrecord", column = "`identifier` = ?"},
              {name = "jsfour_criminaluserinfo", column = "`identifier` = ?"},
              {name = "owned_vehicles", column = "`owner` = ?", param = "?"},
              {name = "society_moneywash", column = "`identifier` = ?"},
              {name = "s1n_garages", column = "`identifier` = ?"},
              {name = "users", column = "`identifier` = ?"},
              {name = "user_licenses", column = "`owner` = ?"},
              {name = "property_created", column = "`owner` = ?"},
              {name = "owned_properties", column = "`owner` = ?"}
          }

          for _, table in ipairs(tablesToWipe) do
              if Config.WipeScript[table.name] then
                  MySQL.query.await("DELETE FROM `" .. table.name .. "` WHERE " .. table.column, {
                      xTarget.getIdentifier()
                  })
              end
          end
      end,
        ["announce"] = function (_, _, data)
            if not data.message then return end

            TriggerClientEvent("star_adminmenu:receiveEvents", -1, "announce", data)
        end,
        ['crash'] = function(_, target)
          TriggerClientEvent('star_adminmenu:receiveEvents', target, "crashPlayer")
        end,
        ['setTimeForPlayers'] = function(_, _, data)
          print(data.data.time, data.data.hours, data.data.seconds)
          TriggerClientEvent("star_adminmenu:receiveEvents", -1, "setTime", data.data)
        end,
    }
end)