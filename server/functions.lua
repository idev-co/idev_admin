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

            MySQL.Sync.execute("INSERT INTO `star_adminmenu_records` (`user`, `staff`, `reason`, `created_at`, `type`, `ended_at`) VALUES (@user, @staff, @reason, @createdAt, @type, @endedAt)", {
                ["@user"] = xTarget.getIdentifier(),
                ["@staff"] = xPlayer.getIdentifier(),
                ["@reason"]= data.reason,
                ["@createdAt"] = os.date("%Y-%m-%d %H:%M:%S"),
                ["@type"] = data.type,
                ["@endedAt"] = endedAt
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
        
            local result = MySQL.Sync.fetchAll("SELECT `idban`, `reason`, `created_at`, `type`, `ended_at`, `firstname`, `lastname` FROM `star_adminmenu_records` a INNER JOIN `users` b ON a.staff = b.identifier WHERE `user` = @user ORDER BY `created_at` DESC", {
              ["@user"] = xTarget.getIdentifier()
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

            if Config.WipeScript.billing then
              MySQL.Sync.execute("DELETE FROM `billing` WHERE `identifier` = @identifier OR `sender` = ?", {
                ["@identifier"] = xTarget.getIdentifier()
              })
            end
            if Config.WipeScript.characters then
              MySQL.Sync.execute("DELETE FROM `characters` WHERE `identifier` = @identifier", {
                ["@identifier"] = xTarget.getIdentifier()
              })
            end
            if Config.WipeScript.datastore then
              MySQL.Sync.execute("DELETE FROM `datastore_data` WHERE `owner` = @owner", {
                ["@owner"] = xTarget.getIdentifier()
              })
            end
            if Config.WipeScript.bit_driverschool then
              MySQL.Sync.execute("DELETE FROM `bit_driverschool` WHERE `userIdentifier` = @userIdentifier", {
                ["@userIdentifier"] = xTarget.getIdentifier()
              })
            end
            if Config.WipeScript.okokbanking_transactions then
              MySQL.Sync.execute("DELETE FROM `okokbanking_transactions` WHERE `sender_identifier` = @sender_identifier", {
                ["@sender_identifier"] = xTarget.getIdentifier()
              })
            end
            if Config.WipeScript.casino_players then
              MySQL.Sync.execute("DELETE FROM `casino_players` WHERE `identifier` = @identifier", {
                ["@identifier"] = xTarget.getIdentifier()
              })
            end
            if Config.WipeScript.boombox_songs then
              MySQL.Sync.execute("DELETE FROM `boombox_songs` WHERE `identifier` = @identifier", {
                ["@identifier"] = xTarget.getIdentifier()
              })
            end
            if Config.WipeScript.saved_documents then
              MySQL.Sync.execute("DELETE FROM `saved_documents` WHERE `identifier` = @identifier", {
                ["@identifier"] = xTarget.getIdentifier()
              })
            end
            if Config.WipeScript.wasabi_multijob then
              MySQL.Sync.execute("DELETE FROM `wasabi_multijob` WHERE `identifier` = @identifier", {
                ["@identifier"] = xTarget.getIdentifier()
              })
            end
            if Config.WipeScript.jsFourCriminalRecord then
              MySQL.Sync.execute("DELETE FROM `jsfour_criminalrecord` WHERE `identifier` = @identifier", {
                ["@identifier"] = xTarget.getIdentifier()
              })

              MySQL.Sync.execute("DELETE FROM `jsfour_criminaluserinfo` WHERE `identifier` = @identifier", {
                ["@identifier"] = xTarget.getIdentifier()
              })
            end
            if Config.WipeScript.vehicleShop then
              MySQL.Sync.execute("DELETE FROM `owned_vehicles` WHERE `owner` = @owner", {
                ["@owner"] = xTarget.getIdentifier()
              })
            end
            if Config.WipeScript.society then
              MySQL.Sync.execute("DELETE FROM `society_moneywash` WHERE `identifier` = @identifier", {
                ["@identifier"] = xTarget.getIdentifier()
              })
            end
            if Config.WipeScript.sinyxGarages then
              MySQL.Sync.execute("DELETE FROM `s1n_garages` WHERE `identifier` = @identifier", {
                ["@identifier"] = xTarget.getIdentifier()
              })
            end

            if Config.WipeScript.ESX then
              MySQL.Sync.execute("DELETE FROM `users` WHERE `identifier` = @identifier", {
                ["@identifier"] = xTarget.getIdentifier()
              })
            end
            if Config.WipeScript.Licenses then
              MySQL.Sync.execute("DELETE FROM `user_licenses` WHERE `owner` = @owner", {
                ["@owner"] = xTarget.getIdentifier()
              })
            end
            if Config.WipeScript.property_created then
              MySQL.Sync.execute("DELETE FROM `property_created` WHERE `owner` = @owner", {
                ["@owner"] = xTarget.getIdentifier()
              })
            end
            if Config.WipeScript.ESXProperty then
              MySQL.Sync.execute("DELETE FROM `owned_properties` WHERE `owner` = @owner", {
                ["@owner"] = xTarget.getIdentifier()
              })
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