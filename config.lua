--[[
    This is the star_adminmenu global script's config.
    If you have trouble configuring the script, please open a ticket on the discord server https://discord.gg/8ecXhFXqR4

    To change the language, you just have to modify the name of the file on the fxmanifest.
]]


Config = {
    keyOpenMenu = "F9", -- Corresponds to the key to open the admin menu.
    useSteamIdentifier = false, -- Deals with ban, if set to true it will use the steam identifier to check with the database otherwise it will use the license
    esxLegacy = true, -- Are you using esx-legacy ? (if not put this to false)
    groupAccessMenu = { -- Groups that have access to the admin menu and its functions.
        ["superadmin"] = true,
        ["admin"] = true,
        ["modo"] = true,
        ["help"] = true
    },
    timeOptions = {
        -- If your using vSync you don't need to edit this options, edit this only if you don't use vSync and you put vSync = false in ScriptsWithAdmin
        -- you don't need to change this if you don't know what you're doing
        ["morning"] = {  -- Do not change this !
            time = "matin", -- Do not change this !
            hours = 8, -- hours in the game (do not put a hours above 23, will cause the game to crash)
            minutes = 0, -- minutes in the game
            seconds = 0 -- seconds in the game
        },
        ["afternoon"] = {  -- Do not change this !
            time = "midi",  -- Do not change this !
            hours = 14, -- hours in the game (do not put a hours above 23, will cause the game to crash)
            minutes = 0, -- minutes in the game
            seconds = 0 -- seconds in the game
        },
        ["evening"] = {  -- Do not change this !
            time = "dsoir",  -- Do not change this !
            hours = 19, -- hours in the game (do not put a hours above 23, will cause the game to crash)
            minutes = 0,  -- minutes in the game
            seconds = 0 -- seconds in the game
        },
        ["night"] = { -- Do not change this !
            time = "soir", -- Do not change this !
            hours = 22, -- hours in the game (do not put a hours above 23, will cause the game to crash
            minutes = 0, -- minutes in the game
            seconds = 0 -- seconds in the game
        }
    },
    maxUpgradesVeh = { -- Corresponds to the options of the max upgrades.
        modEngine = 4,
        modBrakes = 4,
        modTransmission = 4,
        modSuspension = 4,
        windowTint = 2,
        neonEnabled = {true, true, true, true},
        modXenon = true,
        modTurbo = true,
        modSmokeEnabled = true,
        neonColor = {15, 3, 255},
    },
    colorOptionsVeh = { -- https://pastebin.com/pwHci0xK
        {label = Translations["blackColor"], value = 0},
        {label = Translations["redColor"], value = 27},
        {label = Translations["colorPink"], value = 135},
        {label = Translations["colorYellow"], value = 88},
        {label = Translations["colorGreen"], value = 52},
        {label = Translations["colorBlue"], value = 64},
        {label = Translations["colorWhite"], value = 111},
        {label = Translations["colorPurple"], value = 145},        
    },
    discord = { -- webhook must be ENABLE !
        enable = true,
        webhookURL = "https://discord.com/api/webhooks/992816609720811620/YW4_znbjvDzU1rpPLOmfJkjWQA1Dy80hS3WmMgbeHpVsAA8p-285W0nBI_oBiVnMZUnP",
        username = "In-Game LOGS",
        color = 15844367,
        title = "Admin menu",
        description = "**Action:** %s\n **Type:** %s\n **Target:** %s\n **Triggered By:** %s"
    },
    triggers = { -- Name of the used events triggers (you don't need to change them if you don't know what you're doing)
        esxLoading = "esx:getSharedObject",
        esxPlayerLoaded = "esx:playerLoaded",
        esxStatusSet = "esx_status:set",
        esxRevivePlayer = "esx_ambulancejob:revive"
    },
    ScriptsWithAdmin = {
        -- Script who are compatible with the Admin menu.
         vSync = false,
         job2 = false -- if your es_extended is using a job2 system (job2 functions are : ESX.DoesJob2Exist and player.setJob2, if you have a problem with this, open a ticket.)
    },
    WipeScript = {
        -- (DO NOT USE THIS IF YOU DON'T HAVE THE SCRIPT !)
        ESX = true, -- wipe users table !
        Account = true, -- wipe addon_account (esx_addonaccount) tables
        billing = true, -- wipe billing table ! 
        characters = false, -- wipe characters table !
        datastore = true, -- datastore_data, etcc...
        dpEmotes = true, -- wipe dpEmotes keybinds table
        jsFourCriminalRecord = false, -- wipe jsFourCriminalRecord tables
        vehicleShop = true, -- based on the esx_vehicleshop FROM esx-legacy
        society = true, -- based on the esx_society FROM esx-legacy
        sinyxGarages = true -- based on https://forum.cfx.re/t/esx-qb-core-the-garage-system/4399450

    },
    functionsBlacklist = { -- Names of groups that don't have access to certain actions, if you set a action to true the group won't have access to this action.
    -- Not every action are in the blacklist system, i need to do it :(
        ["wipe"] = {
            ["admin"] = false,
            ["modo"] = true,
            ["help"] = true
        },

        ["freeze"] = {
            ["admin"] = false,
            ["modo"] = false,
            ["help"] = true
        },

        ["heal"] = {
            ["admin"] = false,
            ["modo"] = false,
            ["help"] = true
        },

        ["sprint"] = {
            ["admin"] = false,
            ["modo"] = true,
            ["help"] = true
        },

        ["jump"] = {
            ["admin"] = false,
            ["modo"] = true,
            ["help"] = true
        },

        ["swim"] = {
            ["admin"] = false,
            ["modo"] = true,
            ["help"] = true
        },

        ["giveall"] = {
            ["admin"] = false,
            ["modo"] = true,
            ["help"] = true
        },

        ["removeall"] = {
            ["admin"] = true,
            ["modo"] = true,
            ["help"] = true
        },

        ["armor"] = {
            ["admin"] = false,
            ["modo"] = true,
            ["help"] = true
        },

        ["revive"] = {
            ["admin"] = false,
            ["modo"] = false,
            ["help"] = true
        },

        ["reviveplayer"] = {
            ["admin"] = false,
            ["modo"] = false,
            ["help"] = true
        },

        ["blips"] = {
            ["admin"] = false,
            ["modo"] = false,
            ["help"] = true
        },

        ["givemoney"] = {
            ["admin"] = false,
            ["modo"] = true,
            ["help"] = true
        },

        ["freezeplay"] = {
            ["admin"] = false,
            ["modo"] = false,
            ["help"] = true
        },

        ["giveallplayer"] = {
            ["admin"] = true,
            ["modo"] = true,
            ["help"] = true
        },

        ["removeallplayer"] = {
            ["admin"] = true,
            ["modo"] = true,
            ["help"] = true
        },

        ["setjob"] = {
            ["admin"] = false,
            ["modo"] = true,
            ["help"] = true
        },

        ['setjob2'] = {
            ["admin"] = true,
            ["modo"] = true,
            ["help"] = true
        },

        ["givemoneyy"] = {
            ["admin"] = false,
            ["modo"] = true,
            ["help"] = true
        },

        ["crashPlayer"] = {
            ["admin"] = false,
            ["modo"] = true,
            ["help"] = true
        },

        ["rankk"] = {
            ["admin"] = true,
            ["modo"] = true,
            ["help"] = true
        },

        ["gwarn"] = {
            ["admin"] = false,
            ["modo"] = false,
            ["help"] = true
        },

        ["ban"] = {
            ["admin"] = false,
            ["modo"] = true,
            ["help"] = true
        },

        ["listrecord"] = {
            ["admin"] = false,
            ["modo"] = true,
            ["help"] = true
        },

        ["inventory"] = {
            ["admin"] = false,
            ["modo"] = false,
            ["help"] = true
        },

        ["godcar"] = {
            ["admin"] = false,
            ["modo"] = true,
            ["help"] = true
        },

        ["removecar"] = {
            ["admin"] = false,
            ["modo"] = false,
            ["help"] = true
        },

        ["modifplate"] = {
            ["admin"] = false,
            ["modo"] = true,
            ["help"] = true
        },

        ["perfs"] = {
            ["admin"] = false,
            ["modo"] = true,
            ["help"] = true 
        },

        ["kickplay"] = {
            ["admin"] = false,
            ["modo"] = false,
            ["help"] = true
        },

        ["cleararea"] = {
            ["admin"] = false,
            ["modo"] = false,
            ["help"] = true
        },

        ["announce"] = {
            ["admin"] = false,
            ["modo"] = false,
            ["help"] = true
        },

        ["teleportPoint"] = {
            ["admin"] = false,
            ["modo"] = false,
            ["help"] = true
        },

        ["kickall"] = {
            ["admin"] = false,
            ["modo"] = true,
            ["help"] = true
        },

        ["blackout"] = {
            ["admin"] = true,
            ["modo"] = true,
            ["help"] = true
        },


        ["weather"] = {
            ["admin"] = true,
            ["modo"] = true,
            ["help"] = true
        },

        ["settime"] = {
            ["admin"] = true,
            ["modo"] = true,
            ["help"] = true
        },

        ["autorepair"] = {
            ["admin"] = false,
            ["modo"] = true,
            ["help"] = true
        },

        ["fixcar"] = {
            ["admin"] = false,
            ["modo"] = true,
            ["help"] = true
        },

        ["sendMsgToPlayer"] = {
            ["admin"] = false,
            ["modo"] = false,
            ["help"] = true
        },

        ["kickPlayerFromAVehicle"] = {
            ["admin"] = false,
            ["modo"] = true,
            ["help"] = true
        },

        ["maxUpgradesVeh"] = {
            ["admin"] = false,
            ["modo"] = true,
            ["help"] = true
        },

        ["setVehicleColor"] = {
            ["admin"] = false,
            ["modo"] = true,
            ["help"] = true
        },
        
            ["godmod"] = {
                ["admin"] = false,
                ["mod"] = true,
                ["help"] = true
            }
    },
    actions = {
        ["healPlayer"] = {
            ["hunger"] = 1000000,
            ["thirst"] = 1000000,
            ["drunk"] = 0
        },
        ["noclip"] = {
            ["controls"] = {
                adjustSpeed = 21,
                forward = 32,
                backward = 269
            },
            ["speed"] = {
                { 
                    label = "Très lent",
                    speed = 0.25
                },
                { 
                    label = "Lent", 
                    speed = 0.50
                },
                { 
                    label = "Normal", 
                    speed = 2
                },
                { 
                    label = "Rapide", 
                    speed = 4
                },
                { 
                    label = "Très Rapide", 
                    speed = 6
                },
                { 
                    label = "Extrèmement Rapide", 
                    speed = 10
                }
            }
        },
    },
    weaponsList = {
        -- Melee
        -1716189206, 1737195953, 1317494643, -1786099057, -2067956739, 1141786504, -102323637, -102323637,
          -102973651, -656458692, -581044007, -1951375401, -538741184, -1810795771, 419712736, -853065399,
    
        -- Handguns
        453432689, 1593441988, -1716589765, -1076751822, -771403250, 137902532,
          -598887786, -1045183535, 584646201, 911657153, 1198879012, 3219281620,
    
        -- MachineGuns
        324215364,  -619010992, 736523883, -270015777, 171789620, -1660422300, 2144741730,
          1627465347, -1121678507, 2024373456, 3686625920,
    
        -- Assault Rifles
        -1074790547, -2084633992, -1357824103, -1063057011, 2132975508, 1649403952,
        961495388, 4208062921,
    
        -- Sniper Rifles
        100416529, 205991906, -952879014, 177293209,
    
        -- Shotguns
        487013001, 2017895192, -1654528753, -494615257, -1466123874, 984333226, -275439685, 317205821,
    
        -- Heavy weapons
        -1568386805, -1312131151, 1119849093, 2138347493, 1834241177, 1672152130, 125959754,
    
        -- Thrown weapons
        -1813897027, 741814745, -1420407917, -1600701090, 615608432, 101631238, 883325847, 1233104067,
        600439132, 126349499, -37975472, -1169823560,
    }
}

--[[
    If you want to custom the notification function, here it is.
]]

function NotifyAction(type, activate, custom)
    if custom then
        return ESX.ShowNotification(custom, false, false, 140)    
    end

    if activate ~= true and activate ~= false then 
        return ESX.ShowNotification(("%s: %s"):format(type, Translations["notificationUsed"]), false, false, 140)
    end
   
    ESX.ShowNotification(("%s: %s"):format(type, activate and Translations["notificationOn"] or Translations["notificationOff"]), false, false, 140)
end